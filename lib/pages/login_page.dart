import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './shops_page.dart';
import './owner_page.dart';
 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
 
  @override
  State<LoginPage> createState() => _LoginPageState();
}
 
class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
 
  bool isLoading = false;
  bool isBarberLogin = false;
  bool isRegister = false; // Toggle between Login and Register
 
  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
 
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }
 
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://172.210.139.244:8000/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "role": isBarberLogin ? "owner" : "customer"
        }),
      );
 
      setState(() => isLoading = false);
 
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
 
        if (data["msg"] == "Login successful") {
          final role = data["role"];
          final ownerId = data["user_id"];
 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome, $role!")),
          );
 
          if (role == "customer") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShopsPage()),
            );
          } else if (role == "owner") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OwnerPage(ownerId: ownerId),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["msg"] ?? "Invalid credentials")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    }
  }
 
  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
 
    if (username.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }
 
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://172.210.139.244:8000/users/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "phone_number": phone,
          "role": isBarberLogin ? "owner" : "customer"
        }),
      );
 
      setState(() => isLoading = false);
 
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
        setState(() => isRegister = false); // Switch to login after registration
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to register: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
 
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Icon(Icons.cut_outlined, size: 100, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      "HairCare Hub",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),
 
                    // Login / Register Card
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isRegister) ...[
                                TextField(
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    labelText: "Username",
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (isRegister) ...[
                                TextField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "Phone Number",
                                    prefixIcon: const Icon(Icons.phone),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
 
                              // Role Toggle
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ChoiceChip(
                                    label: const Text("Customer"),
                                    selected: !isBarberLogin,
                                    selectedColor: Colors.blueAccent,
                                    onSelected: (_) {
                                      setState(() => isBarberLogin = false);
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  ChoiceChip(
                                    label: const Text("Barber"),
                                    selected: isBarberLogin,
                                    selectedColor: Colors.blueAccent,
                                    onSelected: (_) {
                                      setState(() => isBarberLogin = true);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
 
                              // Button
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: isRegister
                                            ? registerUser
                                            : loginUser,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          backgroundColor:
                                              const Color(0xFF6A11CB),
                                          foregroundColor: Colors.white,
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        child: Text(
                                            isRegister ? "Create Account" : "Login"),
                                      ),
                                    ),
 
                              const SizedBox(height: 20),
 
                              // Toggle Login/Register
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isRegister = !isRegister;
                                  });
                                },
                                child: Text(
                                  isRegister
                                      ? "Already have an account? Login"
                                      : "Don't have an account? Create one",
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
 
                    const SizedBox(height: 30),
                    const Text(
                      "© 2025 HairCare Hub",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
 
