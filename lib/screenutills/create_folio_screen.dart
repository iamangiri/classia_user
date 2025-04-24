import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

class CreateFolioScreen extends StatefulWidget {
  const CreateFolioScreen({Key? key}) : super(key: key);

  @override
  _CreateFolioScreenState createState() => _CreateFolioScreenState();
}

class _CreateFolioScreenState extends State<CreateFolioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _panController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, String hint, {IconData? prefixIcon, IconData? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
      hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.secondaryText, size: 20.sp) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.secondaryText, size: 20.sp) : null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Create New Folio'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Folio Creation Process'),
              SizedBox(height: 20.h),

              // Personal Details
              _buildInputField(
                controller: _fullNameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person,
                validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
              ),
              _buildInputField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Invalid email';
                  return null;
                },
              ),
              _buildInputField(
                controller: _mobileController,
                label: 'Mobile Number',
                hint: '10-digit phone number',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (value) => value!.length != 10 ? 'Invalid mobile number' : null,
              ),

              // PAN Card Input
              _buildInputField(
                controller: _panController,
                label: 'PAN Number',
                hint: 'ABCDE1234F',
                suffixIcon: Icons.credit_card,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                ],
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter PAN number';
                  if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) return 'Invalid PAN number';
                  return null;
                },
              ),
              _buildGuidelineText('• 10-character alphanumeric PAN'),
              SizedBox(height: 20.h),

              // Bank Details
              _buildInputField(
                controller: _accountNumberController,
                label: 'Bank Account Number',
                hint: 'Enter your account number',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter account number';
                  if (value.length < 8) return 'Account number must be at least 8 digits';
                  return null;
                },
              ),
              _buildInputField(
                controller: _ifscController,
                label: 'IFSC Code',
                hint: 'ABCD0123456',
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter IFSC code';
                  if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) return 'Invalid IFSC code';
                  return null;
                },
              ),

              // Investment Details
              _buildSectionTitle('Investment Information'),
              _buildInputField(
                controller: _amountController,
                label: 'Investment Amount (₹)',
                hint: 'Minimum ₹500',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter amount';
                  final amount = int.tryParse(value);
                  if (amount == null || amount < 500) return 'Minimum ₹500';
                  return null;
                },
              ),
              _buildGuidelineText('• Minimum investment amount: ₹500'),

              SizedBox(height: 30.h),
              ElevatedButton.icon(
                icon: Icon(Icons.fingerprint, color: AppColors.buttonText, size: 20.sp),
                label: Text(
                  _isLoading ? 'Processing...' : 'Verify and Create Folio',
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  minimumSize: Size(double.infinity, 48.h),
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    _submitFolioRequest();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fix the errors in the form'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
          decoration: _inputDecoration(label, hint, prefixIcon: prefixIcon, suffixIcon: suffixIcon),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.primaryText,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildGuidelineText(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, left: 12.w),
      child: Text(
        text,
        style: TextStyle(color: AppColors.secondaryText, fontSize: 12.sp),
      ),
    );
  }

  Future<void> _submitFolioRequest() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Folio creation request submitted successfully'),
        backgroundColor: AppColors.success,
      ),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'Verification',
          style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
        ),
        content: Text(
          'Processing your folio creation request...',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to ManageFolioScreen
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
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}