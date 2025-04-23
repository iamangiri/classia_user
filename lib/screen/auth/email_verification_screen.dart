import 'package:classia_amc/screen/auth/moblie_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../service/apiservice/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? initialEmail;
  final String? initialPhone;
  const EmailVerificationScreen({Key? key, this.initialEmail,this.initialPhone}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late final TextEditingController _emailController;
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isSending = false;
  bool _isVerifying = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: widget.initialEmail?.trim() ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSending = true;
      _statusMessage = '';
    });
    try {
      final res = await AuthService.sendOtp(email: _emailController.text.trim());
      setState(() {
        _otpSent = res['status'] as bool;
        _statusMessage = res['message'] as String;
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error: \$e');
    } finally {
      setState(() => _isSending = false);
    }
  }


  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() => _statusMessage = 'Enter OTP');
      return;
    }
    setState(() {
      _isVerifying = true;
      _statusMessage = '';
    });

    try {
      final res = await AuthService.verifyOtp(
        email: _emailController.text.trim(),
        code: _otpController.text.trim(),
      );
      final success = res['status'] as bool;
      setState(() {
        _otpVerified = success;
        _statusMessage = res['message'] as String;
      });

      if (success) {
        // Navigate to LoginScreen upon successful verification
        context.go('/mobile_verify');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error verifying OTP: \$e');
    } finally {
      setState(() => _isVerifying = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with gradient & animation
               SizedBox(height: 150,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        enabled: !_otpSent && widget.initialEmail == null,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
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
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter email';
                          if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(val)) return 'Invalid email';
                          return null;
                        },
                      ),
                      SizedBox(height: 50),

                      // Send OTP button or OTP + Verify
                      if (!_otpSent) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _sendOtp,
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
                                child: _isSending
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text('Send OTP', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _otpController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
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
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 50),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (_isVerifying || _otpVerified) ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [if (_otpVerified) Colors.green else Color(0xFFFFD700), if (!_otpVerified) Color(0xFFFFA500) else Colors.green],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: _isVerifying
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  _otpVerified ? 'OTP Verified' : 'Verify OTP',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 20),
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _otpVerified ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 150,),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: EdgeInsets.only(top: 60, bottom: 40),
                child: Center(
                  child: Lottie.asset(
                    'assets/anim/anim_1.json', // ensure you have a Lottie email animation
                    height: 200,
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