import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/kyc_app_bar.dart';
import 'package:classia_amc/service/apiservice/user_service.dart';

class KYCVerificationScreen extends StatefulWidget {
  const KYCVerificationScreen({Key? key}) : super(key: key);

  @override
  _KYCVerificationScreenState createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false;

// Controllers for Aadhaar step
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _aadhaarOtpController = TextEditingController();

// Controllers for PAN step
  final TextEditingController _panController = TextEditingController();

// Controllers for Bank Info step
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isAadhaarOtpSent = false;
  String? _referenceId; // Store referenceId from send OTP
  late UserService _userService;

  @override
  void initState() {
    super.initState();
// Initialize UserService with JWT token (replace with actual token retrieval)
    _userService = UserService(token: '${UserConstants.TOKEN}');
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
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      color: AppColors.screenBackground,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepIcon(0, Icons.fingerprint, 'Aadhaar'),
              _buildStepIcon(1, Icons.credit_card, 'PAN'),
              _buildStepIcon(2, Icons.account_balance, 'Bank'),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            minHeight: 4.h,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(int stepIndex, IconData icon, String label) {
    bool isActiveOrCompleted = _currentStep >= stepIndex;
    Color backgroundColor =
        isActiveOrCompleted ? AppColors.primaryGold : AppColors.disabled;
    Color iconColor =
        isActiveOrCompleted ? AppColors.buttonText : AppColors.secondaryText;

    return Column(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: backgroundColor,
          child: Icon(icon, color: iconColor, size: 20.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: isActiveOrCompleted
                ? AppColors.primaryText
                : AppColors.secondaryText,
            fontSize: 12.sp,
            fontWeight:
                isActiveOrCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
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

  InputDecoration _inputDecoration(String label, String hint,
      {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
      hintStyle: TextStyle(
          color: AppColors.secondaryText.withOpacity(0.7), fontSize: 14.sp),
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: EdgeInsets.only(left: 12.w, right: 8.w),
              child:
                  Icon(prefixIcon, color: AppColors.secondaryText, size: 20.sp),
            )
          : null,
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
      errorStyle:
          TextStyle(color: AppColors.error, fontSize: 12.sp, height: 0.5),
    );
  }

  Widget _buildAadhaarStep() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            TextFormField(
              controller: _aadhaarController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              decoration: _inputDecoration(
                  'Aadhaar Number', 'Enter 12-digit Aadhaar number',
                  prefixIcon: Icons.credit_card),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter Aadhaar number';
                if (!RegExp(r'^\d{12}$').hasMatch(value))
                  return 'Invalid Aadhaar number';
                return null;
              },
            ),
            if (_isAadhaarOtpSent) ...[
              SizedBox(height: 16.h),
              TextFormField(
                controller: _aadhaarOtpController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('Enter OTP', 'Enter 6-digit OTP',
                    prefixIcon: Icons.lock),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter OTP';
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Invalid OTP';
                  return null;
                },
              ),
            ],
            SizedBox(height: 24.h),
            SizedBox(
              width: 342.w,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  elevation: 2,
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          if (!_isAadhaarOtpSent) {
                            await _sendAadhaarOtp();
                          } else {
                            await _verifyAadhaarOtp();
                          }
                        }
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
                    child: _isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.buttonText),
                            ),
                          )
                        : Text(
                            _isAadhaarOtpSent ? 'Verify OTP' : 'Send OTP',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPanStep() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            TextFormField(
              controller: _panController,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              decoration: _inputDecoration(
                  'PAN Number', 'Enter 10-character PAN number',
                  prefixIcon: Icons.credit_card),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter PAN number';
                if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value))
                  return 'Invalid PAN number';
                return null;
              },
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 342.w,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _checkPanAadhaarStatus,
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
                    child: _isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.buttonText),
                            ),
                          )
                        : Text(
                            'Verify PAN',
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
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoStep() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _accountHolderController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration(
                    'Account Holder Name', 'Enter account holder name',
                    prefixIcon: Icons.person),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter account holder name'
                    : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _ifscController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('IFSC Code', 'Enter IFSC code',
                    prefixIcon: Icons.code),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter IFSC code';
                  if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value))
                    return 'Invalid IFSC code';
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _bankNameController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('Bank Name', 'Enter bank name',
                    prefixIcon: Icons.account_balance),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter bank name'
                    : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _branchController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('Branch', 'Enter branch name',
                    prefixIcon: Icons.location_city),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter branch name'
                    : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration(
                    'Account Number', 'Enter account number',
                    prefixIcon: Icons.numbers),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter account number';
                  if (value.length < 8)
                    return 'Account number must be at least 8 digits';
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: 342.w,
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _submitKyc,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold,
                          const Color(0xFFFFA500)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.buttonText),
                              ),
                            )
                          : Text(
                              'Submit KYC',
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendAadhaarOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response =
            await _userService.sendAadhaarOtp(_aadhaarController.text);
        setState(() {
          _isAadhaarOtpSent = true;
          _referenceId = response.referenceId.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aadhaar OTP sent successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aadhaar OTP verified successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PAN-Aadhaar link verified successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PAN is not linked with Aadhaar'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
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
          'accountType': 'savings', // Default as per backend
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            title: Text(
              'KYC Submitted',
              style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
            ),
            content: Text(
              'Your KYC details have been submitted successfully.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Exit KYC screen
                },
                child: Text(
                  'OK',
                  style:
                      TextStyle(color: AppColors.primaryGold, fontSize: 14.sp),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: KycAppBar(
        title: 'KYC Verification',
        actions: [
          if (_currentStep < 2)
            IconButton(
              icon:
                  Icon(Icons.close, color: AppColors.primaryText, size: 24.sp),
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(child: _buildStepContent()),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        color: AppColors.screenBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentStep < 2)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
