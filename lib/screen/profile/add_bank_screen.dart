import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

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
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Populate fields if editing
    if (widget.initialData != null) {
      _bankNameController.text = widget.initialData!['bankName'] ?? '';
      _branchController.text = widget.initialData!['branch'] ?? '';
      _accountHolderController.text = widget.initialData!['accountHolder'] ?? '';
      _accountNumberController.text = widget.initialData!['accountNumber'] ?? '';
      _ifscController.text = widget.initialData!['ifsc'] ?? '';
    }
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);

      final bankData = {
        'bankName': _bankNameController.text,
        'branch': _branchController.text,
        'accountHolder': _accountHolderController.text,
        'accountNumber': _accountNumberController.text,
        'ifsc': _ifscController.text,
      };

      widget.onSave(bankData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.initialData == null ? "Bank added successfully" : "Bank updated successfully"),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fix the errors in the form"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
      hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
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
      appBar: CommonAppBar(
        title: widget.initialData == null ? 'Add Bank' : 'Edit Bank',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _bankNameController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration("Bank Name", "Enter bank name"),
                validator: (value) => value == null || value.isEmpty ? "Please enter bank name" : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _branchController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration("Branch", "Enter branch name"),
                validator: (value) => value == null || value.isEmpty ? "Please enter branch name" : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _accountHolderController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration("Account Holder Name", "Enter account holder name"),
                validator: (value) => value == null || value.isEmpty ? "Please enter account holder name" : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration("Account Number", "Enter account number"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter account number";
                  if (value.length < 8) return "Account number must be at least 8 digits";
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _ifscController,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
                decoration: _inputDecoration("IFSC Code", "Enter IFSC code"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter IFSC code";
                  if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) return "Please enter a valid IFSC code";
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitBankData,
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
                  widget.initialData == null ? "Add Bank" : "Update Bank",
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
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