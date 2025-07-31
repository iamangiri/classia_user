// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:go_router/go_router.dart';
//
// class OTPScreen extends StatefulWidget {
//   final String contact;
//
//   const OTPScreen({super.key, required this.contact});
//
//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }
//
// class _OTPScreenState extends State<OTPScreen> {
//   final _otpControllers = List.generate(6, (_) => TextEditingController());
//   int _timeRemaining = 60;
//   bool _isResendEnabled = false;
//   bool _isLoading = false;
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   void _startTimer() {
//     setState(() {
//       _timeRemaining = 60;
//       _isResendEnabled = false;
//     });
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_timeRemaining > 0) {
//         setState(() => _timeRemaining--);
//       } else {
//         timer.cancel();
//         setState(() => _isResendEnabled = true);
//       }
//     });
//   }
//
//   void _verifyOTP() {
//     setState(() {
//       _isLoading = true;
//     });
//
//     // Simulate OTP verification process
//     Future.delayed(const Duration(seconds: 2), () {
//       setState(() {
//         _isLoading = false;
//       });
//
//       // Once OTP is verified, navigate to the main screen
//       context.go('/main'); // Using GoRouter to navigate to the main screen
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Dark background
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         padding: EdgeInsets.zero,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 100),
//               const Text(
//                 "Verify OTP",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white, // White text for dark mode
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Enter the OTP sent to +91 ${widget.contact}",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 16, color: Colors.white70),
//               ),
//               const SizedBox(height: 20),
//               // OTP Input Container
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 margin: const EdgeInsets.symmetric(horizontal: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.black, // Dark container color
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black,
//                       blurRadius: 3,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: List.generate(6, (index) {
//                     return SizedBox(
//                       width: 50,
//                       height: 60,
//                       child: TextField(
//                         controller: _otpControllers[index],
//                         maxLength: 1,
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                         decoration: InputDecoration(
//                           counterText: '',
//                           border: OutlineInputBorder(
//                             borderSide: BorderSide(
//                               color: Colors.white,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 2,
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 2.5,
//                             ),
//                           ),
//                         ),
//                         onChanged: (value) {
//                           if (value.isNotEmpty) {
//                             FocusScope.of(context).nextFocus();
//                           }
//                         },
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "Resend OTP in $_timeRemaining seconds",
//                 style: TextStyle(
//                   color: _isResendEnabled ? Colors.amber : Colors.white70,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               GestureDetector(
//                 onTap: _isResendEnabled ? _startTimer : null,
//                 child: Text(
//                   "Resend OTP",
//                   style: TextStyle(
//                     color: _isResendEnabled ? Colors.amber : Colors.grey,
//                     fontWeight: FontWeight.bold,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: GestureDetector(
//                   onTap: _isLoading ? null : _verifyOTP,
//                   child: Container(
//                     width: double.infinity,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [
//                           Color(0xFFFFD700),
//                           Color(0xFFFFA500),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(30),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.3),
//                           blurRadius: 10,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: _isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text(
//                         "Verify OTP",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 110),
//               // Bottom Lottie Animation Container
//               Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xFFFFA500),
//                       Color(0xFFFFD700),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(50),
//                     topRight: Radius.circular(50),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Lottie.asset(
//                       'assets/anim/anim_1.json',
//                       height: MediaQuery.of(context).size.height * 0.4,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../../service/apiservice/auth_service.dart';

class OTPScreen extends StatefulWidget {
  final String contact;
  final String type; // 'email' or 'mobile'

  const OTPScreen({super.key, required this.contact, required this.type});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  int _timeRemaining = 60;
  bool _isResendEnabled = false;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timeRemaining = 60;
      _isResendEnabled = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        timer.cancel();
        setState(() => _isResendEnabled = true);
      }
    });
  }

  Future<void> _resendOTP() async {
    if (!_isResendEnabled) return;

    setState(() => _isLoading = true);

    final result = await AuthService.loginOTPUser(
      email: widget.type == 'email' ? widget.contact : null,
      mobile: widget.type == 'mobile' ? widget.contact : null,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['status'] ? Colors.green : Colors.red,
      ),
    );

    if (result['status']) {
      _startTimer();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.verifyLoginOtp(
      email: widget.type == 'email' ? widget.contact : null,
      mobile: widget.type == 'mobile' ? widget.contact : null,
      code: otp,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['status'] ? Colors.green : Colors.red,
      ),
    );

    if (result['status']) {
      context.goNamed('main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                    'assets/anim/anim_1.json',
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      "Verify OTP",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Enter the OTP sent to ${widget.type == 'email' ? widget.contact : '+91 ${widget.contact}'}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 50.w,
                            height: 60.h,
                            child: TextField(
                              controller: _otpControllers[index],
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(color: Colors.amber),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(color: Colors.amber, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(color: Colors.amber, width: 2.5),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Resend OTP in $_timeRemaining seconds",
                      style: TextStyle(
                        color: _isResendEnabled ? Colors.amber : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: _isResendEnabled ? _resendOTP : null,
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: _isResendEnabled ? Colors.amber : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              "Verify OTP",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}