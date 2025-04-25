import 'package:classia_amc/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../service/apiservice/auth_service.dart';
import '../../themes/app_colors.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int currentStep = 0; // 0: Mobile, 1: OTP, 2: Reset Password
  String? token;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      final response = await AuthService.forgotPasswordSendOtp(_mobileController.text);
      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP sent successfully!',
              style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          currentStep = 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send OTP.',
              style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      final response = await AuthService.forgotPasswordVerifyOtp(_mobileController.text, _otpController.text);
      if (response['status'] == true) {
        setState(() {
          token = response['data']['token'];
          currentStep = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP verified! You can reset your password.',
              style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid OTP.',
              style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate() && token != null) {
      if (_passwordController.text == _confirmPasswordController.text) {
        final response = await AuthService.resetPassword(token!, _passwordController.text);
        if (response['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password reset successfully!',
                style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp),
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to reset password.',
                style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp),
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Passwords do not match.',
              style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CustomAppBar(
        title: 'Forgot Password',),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProgressIndicator(),
                SizedBox(height: 24.h),
                Text(
                  'Jockey Trading',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Forgot Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Reset your password with ease.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 24.h),
                if (currentStep == 0)
                  _buildInputField(
                    label: 'Mobile Number',
                    hintText: 'Enter your mobile number',
                    prefixIcon: Icon(Icons.phone, color: AppColors.secondaryText, size: 20.sp),
                    controller: _mobileController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your mobile number';
                      if (value.length != 10) return 'Mobile number must be 10 digits';
                      return null;
                    },
                  ),
                if (currentStep == 1)
                  _buildInputField(
                    label: 'OTP',
                    hintText: 'Enter OTP',
                    prefixIcon: Icon(Icons.lock, color: AppColors.secondaryText, size: 20.sp),
                    controller: _otpController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter OTP';
                      if (value.length != 6) return 'OTP must be 6 digits';
                      return null;
                    },
                  ),
                if (currentStep == 2)
                  Column(
                    children: [
                      _buildInputField(
                        label: 'New Password',
                        hintText: 'Enter new password',
                        prefixIcon: Icon(Icons.lock, color: AppColors.secondaryText, size: 20.sp),
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter new password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      _buildInputField(
                        label: 'Confirm Password',
                        hintText: 'Confirm new password',
                        prefixIcon: Icon(Icons.lock, color: AppColors.secondaryText, size: 20.sp),
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please confirm password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: 342.w,
                  height: 56.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (currentStep == 0) _sendOtp();
                      else if (currentStep == 1) _verifyOtp();
                      else if (currentStep == 2) _resetPassword();
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryGold, const Color(0xFFFFA500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          currentStep == 0
                              ? 'Send OTP'
                              : currentStep == 1
                              ? 'Verify OTP'
                              : 'Reset Password',
                          style: TextStyle(
                            color: AppColors.buttonText,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressCircle(currentStep >= 0),
        SizedBox(width: 8.w),
        _buildProgressCircle(currentStep >= 1),
        SizedBox(width: 8.w),
        _buildProgressCircle(currentStep >= 2),
      ],
    );
  }

  Widget _buildProgressCircle(bool isActive) {
    return Container(
      width: 32.r,
      height: 32.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primaryGold : AppColors.border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isActive
          ? Icon(
        Icons.check,
        color: AppColors.buttonText,
        size: 20.sp,
      )
          : null,
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required Widget prefixIcon,
    TextEditingController? controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 16.sp,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14.sp,
          ),
          hintStyle: TextStyle(
            color: AppColors.secondaryText.withOpacity(0.7),
            fontSize: 14.sp,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12.w, right: 8.w),
            child: prefixIcon,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide(color: AppColors.primaryGold, width: 2.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide(color: AppColors.primaryGold, width: 2.w),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide(color: AppColors.error, width: 2.w),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide(color: AppColors.error, width: 2.w),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          errorStyle: TextStyle(
            color: AppColors.error,
            fontSize: 12.sp,
            height: 0.5,
          ),
        ),
        validator: validator,
      ),
    );
  }
}