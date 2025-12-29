import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utills/constent/user_constant.dart';
import '../../service/apiservice/user_service.dart';
import '../../utills/themes/light_app_theme.dart';


class KYCVerificationScreen extends StatefulWidget {
  const KYCVerificationScreen({Key? key}) : super(key: key);

  @override
  _KYCVerificationScreenState createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers for Aadhaar step
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _aadhaarOtpController = TextEditingController();

  // Controllers for PAN step
  final TextEditingController _panController = TextEditingController();

  // Controllers for Bank Info step
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isAadhaarOtpSent = false;
  String? _referenceId;
  late UserService _userService;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Aadhaar',
      'subtitle': 'Identity Verification',
      'icon': Icons.fingerprint_rounded,
    },
    {
      'title': 'PAN Card',
      'subtitle': 'Tax Verification',
      'icon': Icons.credit_card_rounded,
    },
    {
      'title': 'Bank Account',
      'subtitle': 'Payment Setup',
      'icon': Icons.account_balance_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _userService = UserService(token: '${UserConstants.TOKEN}');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _aadhaarController.dispose();
    _aadhaarOtpController.dispose();
    _panController.dispose();
    _accountHolderController.dispose();
    _ifscController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressSection(),
            Expanded(child: _buildStepContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16.h,
        left: 20.w,
        right: 20.w,
        bottom: 20.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDarkBlue,
            AppTheme.primaryDarkBlue.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background decorations
          Positioned(
            right: -50.w,
            top: -30.h,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -30.w,
            bottom: -20.h,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: AppTheme.primaryGold,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Step ${_currentStep + 1} of 3',
                          style: TextStyle(
                            color: AppTheme.primaryGold,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'KYC Verification',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Complete your verification to start investing',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: AppTheme.screenBackground,
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(_steps.length, (index) {
              return Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildStepIndicator(index)),
                    if (index < _steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 3.h,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            color: _currentStep > index
                                ? AppTheme.successGreen
                                : AppTheme.border,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 20.h),
          // Current step info card
          _buildCurrentStepCard(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int index) {
    bool isCompleted = _currentStep > index;
    bool isActive = _currentStep == index;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isCompleted || isActive
                ? LinearGradient(
              colors: isCompleted
                  ? [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.8)]
                  : [AppTheme.primaryGold, Color(0xFFB8860B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isCompleted || isActive ? null : AppTheme.lightBackground,
            border: Border.all(
              color: isCompleted
                  ? AppTheme.successGreen
                  : isActive
                  ? AppTheme.primaryGold
                  : AppTheme.border,
              width: 2,
            ),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: AppTheme.primaryGold.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : _steps[index]['icon'],
            color: isCompleted || isActive ? Colors.white : AppTheme.textSecondary,
            size: 24.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          _steps[index]['title'],
          style: TextStyle(
            color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCurrentStepCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGold.withOpacity(0.05),
            AppTheme.primaryGold.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.primaryGold.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _steps[_currentStep]['icon'],
              color: AppTheme.primaryGold,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _steps[_currentStep]['title'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _steps[_currentStep]['subtitle'],
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'In Progress',
              style: TextStyle(
                color: AppTheme.warningOrange,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildAadhaarStep(),
        _buildPanStep(),
        _buildBankInfoStep(),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppTheme.primaryGold, size: 16.sp),
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.5),
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: AppTheme.lightBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppTheme.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppTheme.primaryGold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppTheme.errorRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            errorStyle: TextStyle(color: AppTheme.errorRed, fontSize: 12.sp),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGold, Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: 26.w,
          height: 26.h,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAadhaarStep() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Info Card
            _buildInfoCard(
              icon: Icons.info_outline_rounded,
              title: 'Aadhaar Verification',
              description:
              'We\'ll send an OTP to your Aadhaar-linked mobile number for verification.',
            ),
            SizedBox(height: 24.h),

            // Aadhaar Input Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildModernTextField(
                    controller: _aadhaarController,
                    label: 'Aadhaar Number',
                    hint: 'Enter 12-digit Aadhaar number',
                    icon: Icons.credit_card_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Aadhaar number';
                      }
                      if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                        return 'Invalid Aadhaar number';
                      }
                      return null;
                    },
                  ),
                  if (_isAadhaarOtpSent) ...[
                    SizedBox(height: 20.h),
                    _buildOtpSentBanner(),
                    SizedBox(height: 20.h),
                    _buildModernTextField(
                      controller: _aadhaarOtpController,
                      label: 'OTP',
                      hint: 'Enter 6-digit OTP',
                      icon: Icons.lock_outline_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter OTP';
                        }
                        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                          return 'Invalid OTP';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 32.h),

            _buildPrimaryButton(
              text: _isAadhaarOtpSent ? 'Verify OTP' : 'Send OTP',
              isLoading: _isLoading,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (!_isAadhaarOtpSent) {
                    await _sendAadhaarOtp();
                  } else {
                    await _verifyAadhaarOtp();
                  }
                }
              },
            ),

            SizedBox(height: 16.h),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel Verification',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpSentBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successGreen,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OTP Sent Successfully',
                  style: TextStyle(
                    color: AppTheme.successGreen,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Check your Aadhaar-linked mobile',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _sendAadhaarOtp,
            child: Text(
              'Resend',
              style: TextStyle(
                color: AppTheme.primaryGold,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanStep() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Info Card
            _buildInfoCard(
              icon: Icons.link_rounded,
              title: 'PAN-Aadhaar Linking',
              description:
              'We\'ll verify that your PAN card is linked with your Aadhaar.',
            ),
            SizedBox(height: 24.h),

            // PAN Input Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildModernTextField(
                    controller: _panController,
                    label: 'PAN Number',
                    hint: 'Enter 10-character PAN (e.g., ABCDE1234F)',
                    icon: Icons.badge_rounded,
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter PAN number';
                      }
                      if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) {
                        return 'Invalid PAN number format';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Aadhaar display (from previous step)
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBackground,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.verified_rounded,
                            color: AppTheme.successGreen,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aadhaar Verified',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              'XXXX XXXX ${_aadhaarController.text.length >= 4 ? _aadhaarController.text.substring(_aadhaarController.text.length - 4) : '****'}',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            _buildPrimaryButton(
              text: 'Verify PAN',
              isLoading: _isLoading,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _checkPanAadhaarStatus();
                }
              },
            ),

            SizedBox(height: 16.h),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel Verification',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoStep() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Info Card
            _buildInfoCard(
              icon: Icons.account_balance_rounded,
              title: 'Bank Account Details',
              description:
              'Add your bank account for receiving payments and withdrawals.',
            ),
            SizedBox(height: 24.h),

            // Bank Info Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildModernTextField(
                    controller: _accountHolderController,
                    label: 'Account Holder Name',
                    hint: 'Enter name as per bank records',
                    icon: Icons.person_outline_rounded,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter account holder name'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  _buildModernTextField(
                    controller: _ifscController,
                    label: 'IFSC Code',
                    hint: 'e.g., SBIN0001234',
                    icon: Icons.code_rounded,
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter IFSC code';
                      }
                      if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) {
                        return 'Invalid IFSC code format';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildModernTextField(
                    controller: _bankNameController,
                    label: 'Bank Name',
                    hint: 'Enter bank name',
                    icon: Icons.account_balance_rounded,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter bank name'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  _buildModernTextField(
                    controller: _branchController,
                    label: 'Branch Name',
                    hint: 'Enter branch name',
                    icon: Icons.location_on_outlined,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter branch name'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  _buildModernTextField(
                    controller: _accountNumberController,
                    label: 'Account Number',
                    hint: 'Enter account number',
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter account number';
                      }
                      if (value.length < 8) {
                        return 'Account number must be at least 8 digits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            _buildPrimaryButton(
              text: 'Submit KYC',
              isLoading: _isLoading,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _submitKyc();
                }
              },
            ),

            SizedBox(height: 16.h),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel Verification',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDarkBlue.withOpacity(0.05),
            AppTheme.primaryGold.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppTheme.primaryGold, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // API Methods (Same logic as before)
  Future<void> _sendAadhaarOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _userService.sendAadhaarOtp(_aadhaarController.text);
        setState(() {
          _isAadhaarOtpSent = true;
          _referenceId = response.referenceId.toString();
        });
        _showSuccessSnackBar('OTP sent to your Aadhaar-linked mobile');
      } catch (e) {
        _showErrorSnackBar(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyAadhaarOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _userService.verifyAadhaarOtp(
          _aadhaarController.text,
          _referenceId!,
          _aadhaarOtpController.text,
        );
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep = 1);
        _showSuccessSnackBar('Aadhaar verified successfully!');
      } catch (e) {
        _showErrorSnackBar(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkPanAadhaarStatus() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _userService.checkPanAadhaarStatus(
          _aadhaarController.text,
          _panController.text,
        );
        if (response.isLinked) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() => _currentStep = 2);
          _showSuccessSnackBar('PAN-Aadhaar verified successfully!');
        } else {
          _showErrorSnackBar('PAN is not linked with Aadhaar');
        }
      } catch (e) {
        _showErrorSnackBar(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitKyc() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _userService.addBankAccount({
          'bankName': _bankNameController.text,
          'accountNo': _accountNumberController.text,
          'holderName': _accountHolderController.text,
          'ifscCode': _ifscController.text,
          'branchName': _branchController.text,
          'accountType': 'savings',
        });
        _showSuccessDialog();
      } catch (e) {
        _showErrorSnackBar(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation Container
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.successGreen,
                      AppTheme.successGreen.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successGreen.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 50.sp,
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                'KYC Submitted!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Your KYC verification has been submitted successfully. We\'ll notify you once it\'s approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGold, Color(0xFFB8860B)],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Exit KYC screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
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

// Helper class for uppercase text formatting
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}