import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../service/apiservice/auth_service.dart';
import '../../utills/constent/user_constant.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isOtpSent = false;

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final id = _identifierController.text.trim();
    final isEmail = id.contains('@');

    final result = await AuthService.loginOTPUser(
      email: isEmail ? id : null,
      mobile: !isEmail ? id : null,
    );

    setState(() => _isLoading = false);

    final ok = result['status'] as bool;
    final msg = result['message'] as String;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) {
      setState(() => _isOtpSent = true);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final id = _identifierController.text.trim();
    final isEmail = id.contains('@');

    final result = await AuthService.verifyLoginOtp(
      email: isEmail ? id : null,
      mobile: !isEmail ? id : null,
      code: _otpController.text.trim(),
    );

    setState(() => _isLoading = false);

    final ok = result['status'] as bool;
    final msg = result['message'] as String;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) {
      // Data is already stored in AuthService.verifyLoginOtp
      // Just navigate to main screen
      print('User logged in successfully!');
      print('Token: ${UserConstants.TOKEN}');
      print('User ID: ${UserConstants.USER_ID}');
      print('Email: ${UserConstants.EMAIL}');
      print('Phone: ${UserConstants.PHONE}');
      print('Main Balance: ${UserConstants.MAIN_BALANCE}');
      print('KYC Status - Aadhaar: ${UserConstants.IS_AADHAAR_VERIFIED}, PAN: ${UserConstants.IS_PAN_VERIFIED}');

      context.goNamed('main');
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: Center(
                  child: Lottie.asset(
                    'assets/anim/anim_2.json',
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // Identifier Field
                      TextFormField(
                        controller: _identifierController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Email or Phone',
                          hintText: 'you@example.com or 0123456789',
                          prefixIcon: const Icon(Icons.person, color: Colors.grey),
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintStyle: const TextStyle(color: Colors.black45),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.amber, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.amber, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter email or phone';
                          }
                          final t = val.trim();
                          if (t.contains('@')) {
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(t)) {
                              return 'Enter a valid email';
                            }
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(t)) {
                            return 'Enter a valid 10-digit phone';
                          }
                          return null;
                        },
                        enabled: !_isOtpSent,
                      ),
                      const SizedBox(height: 16),
                      // OTP Field
                      if (_isOtpSent)
                        TextFormField(
                          controller: _otpController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                            labelStyle: const TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.amber, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.amber, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      const SizedBox(height: 24),
                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                _isOtpSent ? 'Verify OTP' : 'Send OTP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Login with Password link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Login with Id/Password ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () => context.goNamed('loginwithpassword'),
                            child: const Text(
                              "Click here",
                              style: TextStyle(
                                color: Color(0xFFFFA500),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}