import 'package:classia_amc/screen/auth/email_verification_screen.dart';
import 'package:flutter/material.dart';
import '../../service/apiservice/auth_service.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await AuthService.registerUser(
      name: fullNameController.text.trim(),
      email: emailController.text.trim(),
      mobile: phoneController.text.trim(),
      password: passwordController.text,
    );

    final msg = result['message'] as String;
    final ok = result['status'] as bool;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EmailVerificationScreen(initialPhone: phoneController.text.trim(),initialEmail: emailController.text.trim(),)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Text(
                "Register",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
              _buildTextField("Full Name", "Enter full name", fullNameController),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text("Register", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFFFFD700),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: _inputDecoration(label, hint),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          if (label == "Full Name" && value.trim().length < 5) {
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
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: _inputDecoration("Email", "Enter email"),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) return "Please enter your email";
          if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
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
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: _inputDecoration("Phone Number", "Enter phone number"),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) return "Please enter your phone number";
          if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) return "Enter a valid 10-digit number";
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
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: _inputDecoration("Password", "Enter password").copyWith(
          suffixIcon: IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            color: Theme.of(context).iconTheme.color,
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Please enter your password";
          if (value.length < 6) return "Password must be at least 6 characters";
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
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: _inputDecoration("Confirm Password", "Re-enter password").copyWith(
          suffixIcon: IconButton(
            icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
            color: Theme.of(context).iconTheme.color,
            onPressed: () {
              setState(() {
                isConfirmPasswordVisible = !isConfirmPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Please confirm your password";
          if (value != passwordController.text) return "Passwords do not match";
          return null;
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white : Colors.black54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.amber),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
