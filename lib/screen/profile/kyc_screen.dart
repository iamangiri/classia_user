import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

import '../../widget/kyc_app_bar.dart';

class KYCVerificationScreen extends StatefulWidget {
  const KYCVerificationScreen({Key? key}) : super(key: key);

  @override
  _KYCVerificationScreenState createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  XFile? _bankDocument;
  bool _isLoading = false;

  // Controllers for Aadhaar step
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _aadhaarOtpController = TextEditingController();

  // Controllers for PAN step
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _panOtpController = TextEditingController();

  // Controllers for Bank Info step
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Flags to show OTP field after sending OTP
  bool _isAadhaarOtpSent = false;
  bool _isPanOtpSent = false;

  @override
  void dispose() {
    _pageController.dispose();
    _aadhaarController.dispose();
    _aadhaarOtpController.dispose();
    _panController.dispose();
    _panOtpController.dispose();
    _accountHolderController.dispose();
    _ifscController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _bankDocument = pickedFile);
    }
  }

  void _showDocumentSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Document Source',
              style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primaryGold, size: 24.sp),
              title: Text('Camera', style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp)),
              onTap: () {
                Navigator.pop(context);
                _pickDocument(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryGold, size: 24.sp),
              title: Text('Gallery', style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp)),
              onTap: () {
                Navigator.pop(context);
                _pickDocument(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
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
    Color backgroundColor = isActiveOrCompleted ? AppColors.primaryGold : AppColors.disabled;
    Color iconColor = isActiveOrCompleted ? AppColors.buttonText : AppColors.secondaryText;

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
            color: isActiveOrCompleted ? AppColors.primaryText : AppColors.secondaryText,
            fontSize: 12.sp,
            fontWeight: isActiveOrCompleted ? FontWeight.bold : FontWeight.normal,
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

  InputDecoration _inputDecoration(String label, String hint, {IconData? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
      hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.secondaryText, size: 20.sp) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.cardBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryGold),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildAadhaarStep() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            TextFormField(
              controller: _aadhaarController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              decoration: _inputDecoration('Aadhaar Number', 'Enter 12-digit Aadhaar number', prefixIcon: Icons.credit_card),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter Aadhaar number';
                if (!RegExp(r'^\d{12}$').hasMatch(value)) return 'Invalid Aadhaar number';
                return null;
              },
            ),
            SizedBox(height: 20.h),
            if (!_isAadhaarOtpSent)
              ElevatedButton.icon(
                icon: Icon(Icons.send, color: AppColors.buttonText, size: 20.sp),
                label: Text(
                  _isLoading ? 'Sending...' : 'Send OTP',
                  style: TextStyle(color: AppColors.buttonText, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : () => _sendOtp('aadhaar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  minimumSize: Size(double.infinity, 48.h),
                ),
              ),
            if (_isAadhaarOtpSent) ...[
              SizedBox(height: 20.h),
              TextFormField(
                controller: _aadhaarOtpController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('Enter OTP', 'Enter 6-digit OTP', prefixIcon: Icons.lock),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter OTP';
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Invalid OTP';
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPanStep() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            TextFormField(
              controller: _panController,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              decoration: _inputDecoration('PAN Number', 'Enter 10-character PAN number', prefixIcon: Icons.credit_card),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter PAN number';
               // if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) return 'Invalid PAN number';
                return null;
              },
            ),
            SizedBox(height: 20.h),
            if (!_isPanOtpSent)
              ElevatedButton.icon(
                icon: Icon(Icons.send, color: AppColors.buttonText, size: 20.sp),
                label: Text(
                  _isLoading ? 'Sending...' : 'Send OTP',
                  style: TextStyle(color: AppColors.buttonText, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : () => _sendOtp('pan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  minimumSize: Size(double.infinity, 48.h),
                ),
              ),
            if (_isPanOtpSent) ...[
              SizedBox(height: 20.h),
              TextFormField(
                controller: _panOtpController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('Enter OTP', 'Enter 6-digit OTP', prefixIcon: Icons.lock),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter OTP';
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Invalid OTP';
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoStep() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _accountHolderController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('Account Holder Name', 'Enter account holder name', prefixIcon: Icons.person),
                validator: (value) => value == null || value.isEmpty ? 'Please enter account holder name' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _ifscController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration(
                  'IFSC Code',
                  'Enter IFSC code',
                  prefixIcon: Icons.code,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: AppColors.secondaryText, size: 20.sp),
                    onPressed: _isLoading ? null : _fetchBankDetails,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter IFSC code';
                  if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) return 'Invalid IFSC code';
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _bankNameController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('Bank Name', 'Bank name (auto-filled)', prefixIcon: Icons.account_balance),
                readOnly: true,
                validator: (value) => value == null || value.isEmpty ? 'Please fetch bank details' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _branchController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('Branch', 'Branch name (auto-filled)', prefixIcon: Icons.location_city),
                readOnly: true,
                validator: (value) => value == null || value.isEmpty ? 'Please fetch bank details' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration('Account Number', 'Enter account number', prefixIcon: Icons.numbers),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter account number';
                  if (value.length < 8) return 'Account number must be at least 8 digits';
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              InkWell(
                onTap: _isLoading ? null : _showDocumentSourceDialog,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 24.sp, color: AppColors.primaryGold),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _bankDocument != null ? _bankDocument!.name : 'Upload Bank Passbook/Cheque',
                          style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
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

  Future<void> _sendOtp(String type) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate OTP API call
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
        if (type == 'aadhaar') {
          _isAadhaarOtpSent = true;
        } else if (type == 'pan') {
          _isPanOtpSent = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to your registered mobile number'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _fetchBankDetails() async {
    if (_ifscController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      // Simulate IFSC lookup API
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isLoading = false;
        if (_ifscController.text.length == 11) {
          _bankNameController.text = 'Sample Bank';
          _branchController.text = 'Mumbai';
        } else {
          _bankNameController.clear();
          _branchController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid IFSC code'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });
    }
  }

  Future<void> _handleContinue() async {
    if (!(_formKey.currentState!.validate())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_currentStep == 0) {
      if (!_isAadhaarOtpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please send and verify Aadhaar OTP'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (!_isPanOtpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please send and verify PAN OTP'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_accountHolderController.text.isNotEmpty &&
          _ifscController.text.isNotEmpty &&
          _accountNumberController.text.isNotEmpty &&
          _bankNameController.text.isNotEmpty &&
          _branchController.text.isNotEmpty &&
          _bankDocument != null) {
        await _submitKyc();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all bank details and upload document'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitKyc() async {
    setState(() => _isLoading = true);
    // Simulate KYC submission API
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'KYC Submitted',
          style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
        ),
        content: Text(
          'Your KYC details have been submitted for verification.',
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
              style: TextStyle(color: AppColors.primaryGold, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
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
              icon: Icon(Icons.close, color: AppColors.primaryText, size: 24.sp),
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
            ElevatedButton(
              onPressed: _isLoading ? null : _handleContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                minimumSize: Size(double.infinity, 48.h),
              ),
              child: _isLoading
                  ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText),
                ),
              )
                  : Text(
                _currentStep == 2 ? 'Submit KYC' : 'Continue',
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_currentStep < 2) ...[
              SizedBox(height: 8.h),
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
          ],
        ),
      ),
    );
  }
}