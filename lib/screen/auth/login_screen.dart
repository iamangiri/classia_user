import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _phoneController = TextEditingController();
    bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: SafeArea(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align content to the top
          children: [
            // Golden Space above the Lottie Animation
            Container(
              width: double.infinity,
              height: 60, // Height of the golden space
              color: Color(0xFFFFD700), // Golden color
            ),

            // Lottie Animation with gradient and rounded corners
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // Gold color
                    Color(0xFFFFA500), // Orange-Gold gradient
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/anim/anim_2.json',
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ],
              ),
            ),

            const SizedBox(
                height: 90), // Adjusted space between animation and logo

            // Phone Number Input Field (Modern design with smooth edges)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                    borderSide: BorderSide(
                        color: Colors.amber, width: 2), // Amber border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.amber, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.amber, width: 2),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),

            const SizedBox(height: 30),

            // Get Started Button with modern design and rounded corners
        

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        String contact = _phoneController.text.trim();
                        if (contact.isNotEmpty) {
                          // Use GoRouter for navigation
                          context.go('/otp_verify', extra: contact);
                        } else {
                          // Show an error message if no phone number is entered
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please enter a valid phone number'),
                            ),
                          );
                        }
                      },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFA500),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
