import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../service/apiservice/auth_service.dart';
import '../../utills/themes/light_app_theme.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for user registration fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController phoneController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    // call the service
    final result = await AuthService.registerUser(
      name:     fullNameController.text.trim(),
      email:    emailController.text.trim(),
      mobile:   phoneController.text.trim(),
      password: passwordController.text,
    );

    final msg = result['message'] as String;
    final ok  = result['status']  as bool;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) {
      // registration succeeded (statusCode == 201 && status == true)
      // e.g. navigate to login or home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160), // Adjust height as needed
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFD700), // Golden color
                Color(0xFFFFA500), // Orange-Gold gradient
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50), // For status bar spacing
              Text(
                "Register",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white, // White text for dark mode
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildTextField("Full Name", "Enter your full name", fullNameController),
              _buildEmailField(),
              _buildPhoneNumberField(),
              _buildPasswordField(),
              _buildConfirmPasswordField(),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFA500),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text("Register",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Already have an account? Login.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      // You can also use GoRouter's context.go() if you're using named routes
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFFFFD700), // Golden color for accent
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white), // White text
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white), // White label
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70), // Lighter white for hint
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.amber),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          if (value.trim().length < 5) {
            return "Name must be at least 5 characters long";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: emailController,
        style: TextStyle(color: Colors.white), // White text
        decoration: InputDecoration(
          labelText: "Email",
          labelStyle: TextStyle(color: Colors.white),
          hintText: "Enter email",
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.amber),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your email";
          }
          if (!RegExp(
              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
              .hasMatch(value)) {
            return "Enter a valid email";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: phoneController,
        style: TextStyle(color: Colors.white), // White text
        decoration: InputDecoration(
          labelText: "Phone Number",
          labelStyle: TextStyle(color: Colors.white),
          hintText: "Enter phone number",
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.amber),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your phone number";
          }
          if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
            return "Enter a valid 10-digit phone number";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: passwordController,
        obscureText: !isPasswordVisible,
        style: TextStyle(color: Colors.white), // White text
        decoration: InputDecoration(
          labelText: "Password",
          labelStyle: TextStyle(color: Colors.white),
          hintText: "Enter password",
          hintStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.amber),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your password";
          }
          if (value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: confirmPasswordController,
        obscureText: !isConfirmPasswordVisible,
        style: TextStyle(color: Colors.white), // White text
        decoration: InputDecoration(
          labelText: "Confirm Password",
          labelStyle: TextStyle(color: Colors.white),
          hintText: "Re-enter password",
          hintStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.amber),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isConfirmPasswordVisible = !isConfirmPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please confirm your password";
          }
          if (value != passwordController.text) {
            return "Passwords do not match";
          }
          return null;
        },
      ),
    );
  }
}
