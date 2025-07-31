import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../service/apiservice/auth_service.dart';
import '../../utills/constent/user_constant.dart'; // Corrected import path

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
        SnackBar(
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) {
      // Store user data using UserConstants
      await UserConstants.storeUserData({
        'token': result['data']['token'],
        'user': result['data']['user'],
      });

      // Navigate based on verification status
      if (UserConstants.IS_EMAIL_VERIFIED == false) {
        context.goNamed('email_verify');
      } else if (UserConstants.IS_MOBILE_VERIFIED == false) {
        context.goNamed('mobile_verify');
      } else {
        context.goNamed('main');
      }
    }
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
                decoration: BoxDecoration(
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
                      SizedBox(height: 60),
                      // Identifier Field
                      TextFormField(
                        controller: _identifierController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Email or Phone',
                          hintText: 'you@example.com or 0123456789',
                          prefixIcon: Icon(Icons.person, color: Colors.grey),
                          labelStyle: TextStyle(color: Colors.grey),
                          hintStyle: TextStyle(color: Colors.black45),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.amber, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.amber, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.redAccent, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter email or phone';
                          }
                          final t = val.trim();
                          if (t.contains('@')) {
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(t))
                              return 'Enter a valid email';
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(t)) {
                            return 'Enter a valid 10-digit phone';
                          }
                          return null;
                        },
                        enabled: !_isOtpSent, // Disable after OTP sent
                      ),
                      SizedBox(height: 16),
                      // OTP Field (shown after OTP is sent)
                      if (_isOtpSent)
                        TextFormField(
                          controller: _otpController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.amber, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.amber, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.redAccent, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      SizedBox(height: 24),
                      // Send OTP or Verify OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                _isOtpSent ? 'Verify OTP' : 'Send OTP',
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
                      SizedBox(height: 16),
                      // Signup link
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       "Don't have an account? ",
                      //       style: TextStyle(color: Colors.black54),
                      //     ),
                      //     GestureDetector(
                      //       onTap: () {
                      //         context.goNamed('register');
                      //       },
                      //       child: Text(
                      //         "Signup",
                      //         style: TextStyle(
                      //           color: Color(0xFFFFA500),
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 20),
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