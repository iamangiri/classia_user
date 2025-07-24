



import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:classia_amc/service/apiservice/user_service.dart';

class AddBankScreen extends StatefulWidget {
  final Function(Map<String, String>) onSave;
  final Map<String, String>? initialData;

  const AddBankScreen({
    Key? key,
    required this.onSave,
    this.initialData,
  }) : super(key: key);

  @override
  _AddBankScreenState createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _accountHolderController =
  TextEditingController();
  final TextEditingController _accountNumberController =
  TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  String _accountType = 'savings'; // Default as per backend

  late UserService _userService;

  @override
  void initState() {
    super.initState();
// Initialize UserService with JWT token
    _initializeUserService();
  }

  Future<void> _initializeUserService() async {

    setState(() {
      _userService = UserService(token: '${UserConstants.TOKEN}');
    });
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _branchController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _submitBankData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final bankData = {
          'bankName': _bankNameController.text,
          'branchName': _branchController.text,
          'holderName': _accountHolderController.text,
          'accountNo': _accountNumberController.text,
          'ifscCode': _ifscController.text,
          'accountType': _accountType,
        };

        await _userService.addBankAccount(bankData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bank account added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Add Bank Account',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    return 'Please enter a valid IFSC code';
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _accountType,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration(
                    'Account Type', 'Select account type',
                    prefixIcon: Icons.account_balance_wallet),
                items: ['savings', 'current'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.capitalize(),
                        style: TextStyle(
                            color: AppColors.primaryText, fontSize: 16.sp)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _accountType = value!;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select account type' : null,
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
                  onPressed: _isLoading ? null : _submitBankData,
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
                        'Add Bank Account',
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
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 16.sp,
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

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
