import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../service/apiservice/auth_service.dart';

class MobileVerificationScreen extends StatefulWidget {
  final String? initialPhone;
  const MobileVerificationScreen({Key? key, this.initialPhone}) : super(key: key);

  @override
  State<MobileVerificationScreen> createState() => _MobileVerificationScreenState();
}

class _MobileVerificationScreenState extends State<MobileVerificationScreen> {
  late final TextEditingController _phoneController;
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
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSending = true;
      _statusMessage = '';
    });
    try {
      final res = await AuthService.sendOtp(mobile: _phoneController.text.trim());
      setState(() {
        _otpSent = res['status'] as bool;
        _statusMessage = res['message'] as String;
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error sending OTP: \$e');
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
        mobile: _phoneController.text.trim(),
        code: _otpController.text.trim(),
      );
      final success = res['status'] as bool;
      setState(() {
        _otpVerified = success;
        _statusMessage = res['message'] as String;
      });
      if (success) {
        if (success) {
          context.go('/main'); // <-- If using GoRouter
        }

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
              // Header with gradient & phone animation
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                padding: EdgeInsets.only(top: 60, bottom: 40),
                child: Center(
                  child: Lottie.asset(
                    'assets/anim/anim_1.json',
                    height: 200,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Phone field
                      TextFormField(
                        controller: _phoneController,
                        enabled: !_otpSent && widget.initialPhone == null,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone, color: Colors.grey),
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
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter phone number';
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(val)) return 'Invalid phone';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Send OTP or OTP + Verify
                      if (!_otpSent) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              padding: EdgeInsets.zero,
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
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (_isVerifying || _otpVerified) ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [if (_otpVerified) Colors.green else Color(0xFFFFD700), if (_otpVerified) Colors.green else Color(0xFFFFA500)],
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
            ],
          ),
        ),
      ),
    );
  }
}