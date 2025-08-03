import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

import '../../service/apiservice/can_service.dart';

class CamsCreationScreen extends StatefulWidget {
  const CamsCreationScreen({Key? key}) : super(key: key);

  @override
  _CamsCreationScreenState createState() => _CamsCreationScreenState();
}

class _CamsCreationScreenState extends State<CamsCreationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<GlobalKey<FormState>> _stepFormKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  int _currentStep = 0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form field controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _panController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthCityController = TextEditingController();
  final _resAddr1Controller = TextEditingController();
  final _resAddr2Controller = TextEditingController();
  final _resAddr3Controller = TextEditingController();
  final _resCityController = TextEditingController();
  final _resPincodeController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _nomineeNameController = TextEditingController();
  final _nomineeDobController = TextEditingController();
  final _nomineePiNoController = TextEditingController();
  final _nomineeMobileController = TextEditingController();
  final _nomineeEmailController = TextEditingController();
  final _nomineeAddr1Controller = TextEditingController();
  final _nomineeAddr2Controller = TextEditingController();
  final _nomineeAddr3Controller = TextEditingController();
  final _nomineeCityController = TextEditingController();
  final _nomineePincodeController = TextEditingController();
  final _netWorthController = TextEditingController();
  final _netDateController = TextEditingController();

  // Dropdown selections
  String? _birthCountry;
  String? _citizenship;
  String? _nationality;
  String? _taxResFlag;
  String? _resState;
  String? _resCountry;
  String? _grossIncome;
  String? _sourceOfWealth;
  String? _occupation;
  String? _pep;

  late CamService _camService;

  // Sample dropdown options
  final Map<String, String> countryOptions = {
    '101': 'India',
    '102': 'USA',
    '103': 'UK',
  };
  final Map<String, String> stateOptions = {
    '010': 'Bihar',
    '011': 'Delhi',
    '012': 'Maharashtra',
  };
  final Map<String, String> grossIncomeOptions = {
    '01': 'Below 1 Lakh',
    '05': '1-5 Lakh',
    '10': '5-10 Lakh',
  };
  final Map<String, String> sourceOfWealthOptions = {
    '01': 'Salary',
    '02': 'Business',
    '03': 'Investments',
  };
  final Map<String, String> occupationOptions = {
    '01': 'Professional',
    '02': 'Business',
    '03': 'Retired',
  };
  final Map<String, String> pepOptions = {
    'NA': 'Not Applicable',
    'Y': 'Yes',
    'N': 'No',
  };
  final Map<String, String> taxResFlagOptions = {
    'Y': 'Yes',
    'N': 'No',
  };

  @override
  void initState() {
    super.initState();
    _camService = CamService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _panController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthCityController.dispose();
    _resAddr1Controller.dispose();
    _resAddr2Controller.dispose();
    _resAddr3Controller.dispose();
    _resCityController.dispose();
    _resPincodeController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _nomineeNameController.dispose();
    _nomineeDobController.dispose();
    _nomineePiNoController.dispose();
    _nomineeMobileController.dispose();
    _nomineeEmailController.dispose();
    _nomineeAddr1Controller.dispose();
    _nomineeAddr2Controller.dispose();
    _nomineeAddr3Controller.dispose();
    _nomineeCityController.dispose();
    _nomineePincodeController.dispose();
    _netWorthController.dispose();
    _netDateController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _stepFormKeys[0].currentState?.validate() ?? false &&
            _birthCountry != null &&
            _citizenship != null &&
            _nationality != null &&
            _taxResFlag != null;
      case 1:
        return _stepFormKeys[1].currentState?.validate() ?? false &&
            _resState != null &&
            _resCountry != null;
      case 2:
        return _stepFormKeys[2].currentState?.validate() ?? false;
      case 3:
        return _stepFormKeys[3].currentState?.validate() ?? false &&
            _grossIncome != null &&
            _sourceOfWealth != null &&
            _occupation != null &&
            _pep != null;
      case 4:
        return _stepFormKeys[4].currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 4) {
        setState(() {
          _currentStep += 1;
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        _submitForm();
      }
    } else {
      _showValidationError();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Please fill all required fields correctly',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    try {
      final payload = {
        "holdingType": "SI",
        "investorCategory": "I",
        "taxStatus": "RI",
        "holders": [
          {
            "type": "PR",
            "name": _nameController.text,
            "dob": _dobController.text,
            "panExemptFlag": "N",
            "panPekrnNo": _panController.text,
            "contactDetail": {
              "resIsd": "+91",
              "resStd": "0612",
              "resPhoneNo": _phoneController.text,
              "mobIsdCode": "+91",
              "priMobNo": _phoneController.text,
              "priMobBelongsTo": "SE",
              "priEmail": _emailController.text,
            },
            "kycData": {
              "kycStatus": "KRG",
              "sourceKra": "CAMS",
              "resAddrDetail": {
                "addr1": _resAddr1Controller.text,
                "addr2": _resAddr2Controller.text,
                "addr3": _resAddr3Controller.text,
                "city": _resCityController.text,
                "pincode": _resPincodeController.text,
                "state": _resState,
                "country": _resCountry,
              },
              "perAddrDetail": {
                "addr1": _resAddr1Controller.text,
                "addr2": _resAddr2Controller.text,
                "addr3": _resAddr3Controller.text,
                "city": _resCityController.text,
                "pincode": _resPincodeController.text,
                "state": _resState,
                "country": _resCountry,
              },
            },
            "otherDetail": {
              "grossIncome": _grossIncome,
              "netWorth": _netWorthController.text,
              "netDate": _netDateController.text,
              "sourceOfWealth": _sourceOfWealth,
              "kraAddrType": "1",
              "occupation": _occupation,
              "pep": _pep,
            },
            "fatcaDetail": {
              "birthCity": _birthCityController.text,
              "birthCountry": _birthCountry,
              "citizenship": _citizenship,
              "nationality": _nationality,
              "taxResFlag": _taxResFlag,
              "taxRecords": [{"seqNum": "1"}],
            },
          },
        ],
        "bankDetails": [
          {
            "seqNum": 1,
            "defaultAccFlag": "Y",
            "accountNo": _bankAccountController.text,
            "accountType": "SB",
            "bankId": "0065",
            "micrCode": "400065002",
            "ifscCode": _ifscController.text,
            "proof": "14",
          },
        ],
        "nomineeDetails": {
          "nomDeclLvl": "C",
          "nominOptFlag": "Y",
          "nomFolioSoa": "Y",
          "nomineesRecords": [
            {
              "seqNum": 1,
              "nomineeName": _nomineeNameController.text,
              "relation": "MFU01",
              "percentage": "100",
              "dob": _nomineeDobController.text,
              "nomPiType": "DL",
              "nomPiNo": _nomineePiNoController.text,
              "nomMobile": _nomineeMobileController.text,
              "nomEmail": _nomineeEmailController.text,
              "nomAddr1": _nomineeAddr1Controller.text,
              "nomAddr2": _nomineeAddr2Controller.text,
              "nomAddr3": _nomineeAddr3Controller.text,
              "nomPincode": _nomineePincodeController.text,
              "nomCity": _nomineeCityController.text,
              "nomCountry": "101",
            },
          ],
        },
        "arnDetails": {
          "arnNo": "ARN-325802",
          "euinCode": "E618071",
        },
        "consentDetails": [
          {"dataSet": "PD", "enabledConsent": "Y"},
          {"dataSet": "CD", "enabledConsent": "Y"},
          {"dataSet": "MF", "enabledConsent": "N"},
          {"dataSet": "HD", "enabledConsent": "N"},
        ],
        "dpDetails": {
          "nsdlDpId": "IN123456",
          "nsdlClientId": "12345678",
          "nsdlProofId": "34",
          "nsdlVerFlag": "Y",
        },
      };

      final response = await _camService.createCams(payload);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'CAMS account created successfully!',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Error: ${e.toString()}',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Create CAMS Account',
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    height: 4.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.r),
                      color: index <= _currentStep
                          ? AppColors.buttonBackground
                          : AppColors.disabledText.withOpacity(0.3),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Step Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: _buildCurrentStepContent(),
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 10.w),
                      child: ElevatedButton(
                        onPressed: _previousStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.buttonBackground,
                          elevation: 0,
                          side: BorderSide(
                            color: AppColors.buttonBackground,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_ios, size: 16.sp),
                            SizedBox(width: 4.w),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: _currentStep > 0 ? 1 : 2,
                  child: Container(
                    margin: EdgeInsets.only(left: _currentStep > 0 ? 10.w : 0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonBackground,
                        foregroundColor: AppColors.buttonText,
                        elevation: 2,
                        shadowColor: AppColors.buttonBackground.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.buttonText),
                          strokeWidth: 2,
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 4 ? 'Submit' : 'Next',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentStep < 4) ...[
                            SizedBox(width: 4.w),
                            Icon(Icons.arrow_forward_ios, size: 16.sp),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    final stepTitles = [
      'Personal Details',
      'Address Information',
      'Bank Details',
      'Financial Information',
      'Nominee Details',
    ];

    final stepIcons = [
      Icons.person_outline,
      Icons.location_on_outlined,
      Icons.account_balance_outlined,
      Icons.monetization_on_outlined,
      Icons.people_outline,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.buttonBackground.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    stepIcons[_currentStep],
                    color: AppColors.buttonBackground,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of 5',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        stepTitles[_currentStep],
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Form(
              key: _stepFormKeys[_currentStep],
              child: _getStepContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalDetails();
      case 1:
        return _buildAddressDetails();
      case 2:
        return _buildBankDetails();
      case 3:
        return _buildOtherDetails();
      case 4:
        return _buildNomineeDetails();
      default:
        return Container();
    }
  }

  Widget _buildPersonalDetails() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          validator: (value) =>
          value!.isEmpty ? 'Please enter your name' : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _dobController,
          label: 'Date of Birth',
          hint: 'YYYY-MM-DD',
          icon: Icons.calendar_today_outlined,
          validator: (value) => value!.isEmpty
              ? 'Please enter your date of birth'
              : RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)
              ? null
              : 'Enter date in YYYY-MM-DD format',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _panController,
          label: 'PAN Number',
          hint: 'Enter your PAN number',
          icon: Icons.credit_card_outlined,
          validator: (value) => value!.isEmpty
              ? 'Please enter your PAN number'
              : RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)
              ? null
              : 'Enter a valid PAN number',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) => value!.isEmpty
              ? 'Please enter your phone number'
              : RegExp(r'^\d{10}$').hasMatch(value)
              ? null
              : 'Enter a valid 10-digit phone number',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value!.isEmpty
              ? 'Please enter your email'
              : RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)
              ? null
              : 'Enter a valid email address',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _birthCityController,
          label: 'Birth City',
          hint: 'Enter your city of birth',
          icon: Icons.location_city_outlined,
          validator: (value) =>
          value!.isEmpty ? 'Please enter your birth city' : null,
        ),
        SizedBox(height: 16.h),
        _buildDropdownField(
          label: 'Birth Country',
          value: _birthCountry,
          items: countryOptions,
          icon: Icons.flag_outlined,
          onChanged: (value) => setState(() => _birthCountry = value),
        ),
        SizedBox(height: 16.h),
        _buildDropdownField(
          label: 'Citizenship',
          value: _citizenship,
          items: countryOptions,
          icon: Icons.password_outlined,
          onChanged: (value) => setState(() => _citizenship = value),
        ),
        SizedBox(height: 16.h),
        _buildDropdownField(
          label: 'Nationality',
          value: _nationality,
          items: countryOptions,
          icon: Icons.public_outlined,
          onChanged: (value) => setState(() => _nationality = value),
        ),
        SizedBox(height: 16.h),
        _buildDropdownField(
          label: 'Tax Residency',
          value: _taxResFlag,
          items: taxResFlagOptions,
          icon: Icons.receipt_long_outlined,
          onChanged: (value) => setState(() => _taxResFlag = value),
        ),
      ],
    );
  }

  Widget _buildAddressDetails() {
    return Column(
      children: [
        _buildTextField(
          controller: _resAddr1Controller,
          label: 'Address Line 1',
          hint: 'Enter address line 1',
          icon: Icons.home_outlined,
          validator: (value) =>
          value!.isEmpty ? 'Please enter address line 1' : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _resAddr2Controller,
          label: 'Address Line 2',
          hint: 'Enter address line 2 (optional)',
          icon: Icons.home_work_outlined,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _resAddr3Controller,
          label: 'Address Line 3',
          hint: 'Enter address line 3 (optional)',
          icon: Icons.home_work_outlined,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _resCityController,
          label: 'City',
          hint: 'Enter city',
          icon: Icons.location_city_outlined,
          validator: (value) => value!.isEmpty ? 'Please enter city' : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _resPincodeController,
          label: 'Pincode',
          hint: 'Enter pincode',
          icon: Icons.pin_drop_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty
              ? 'Please enter pincode'
              : RegExp(r'^\d{6}$').hasMatch(value)
              ? null
              : 'Enter a valid 6-digit pincode',
        ),
        SizedBox(height: 16.h),
        _buildDropdownField(
          label: 'State',
          value: _resState,
          items: stateOptions,
          icon: Icons.map_outlined,
          onChanged: (value) => setState(() => _resState = value),
        ),
        SizedBox(height: 16.h),
        _buildDropdownField(
          label: 'Country',
          value: _resCountry,
          items: countryOptions,
          icon: Icons.flag_outlined,
          onChanged: (value) => setState(() => _resCountry = value),
        ),
      ],
    );
  }

  Widget _buildBankDetails() {
    return Column(
      children: [
        _buildTextField(
          controller: _bankAccountController,
          label: 'Bank Account Number',
          hint: 'Enter bank account number',
          icon: Icons.account_balance_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty
              ? 'Please enter bank account number'
              : RegExp(r'^\d{9,18}$').hasMatch(value)
              ? null
              : 'Enter a valid account number',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _ifscController,
          label: 'IFSC Code',
          hint: 'Enter IFSC code',
          icon: Icons.code_outlined,
          validator: (value) => value!.isEmpty
              ? 'Please enter IFSC code'
              : RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)
              ? null
              : 'Enter a valid IFSC code',
        ),
      ],
    );
  }

  Widget _buildOtherDetails() {
    return Column(
      children: [
        _buildDropdownField(
          label: 'Gross Annual Income',
          value: _grossIncome,
          items: grossIncomeOptions,
          icon: Icons.monetization_on_outlined,
          onChanged: (value) => setState(() => _grossIncome = value),
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _netWorthController,
          label: 'Net Worth',
          hint: 'Enter net worth (in INR)',
          icon: Icons.account_balance_wallet_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty
              ? 'Please enter net worth'
              : double.tryParse(value) == null
              ? 'Enter a valid number'
              : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _netDateController,
          label: 'Net Worth Date',
          hint: 'YYYY-MM-DD',
          icon: Icons.calendar_today_outlined,
          validator: (value) => value!.isEmpty
              ? 'Please enter net worth date'
              : RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)
              ? null
              : 'Enter date in YYYY-MM-DD format',
        ),
        SizedBox(height: 16.h),
        _buildDropdownField(
          label: 'Source of Wealth',
          value: _sourceOfWealth,
          items: sourceOfWealthOptions,
          icon: Icons.source_outlined,
          onChanged: (value) => setState(() => _sourceOfWealth = value),
        ),
        SizedBox(height: 16.h),
        _buildDropdownField(
          label: 'Occupation',
          value: _occupation,
          items: occupationOptions,
          icon: Icons.work_outline,
          onChanged: (value) => setState(() => _occupation = value),
        ),
        SizedBox(height: 16.h),
        _buildDropdownField(
          label: 'Politically Exposed Person',
          value: _pep,
          items: pepOptions,
          icon: Icons.verified_user_outlined,
          onChanged: (value) => setState(() => _pep = value),
        ),
      ],
    );
  }


  Widget _buildNomineeDetails() {
    return Column(
      children: [
        _buildTextField(
          controller: _nomineeNameController,
          label: 'Nominee Name',
          hint: 'Enter nominee name',
          icon: Icons.person_add_outlined,
          validator: (value) =>
          value!.isEmpty ? 'Please enter nominee name' : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _nomineeDobController,
          label: 'Nominee Date of Birth',
          hint: 'YYYY-MM-DD',
          icon: Icons.calendar_today_outlined,
          validator: (value) => value!.isEmpty
              ? 'Please enter nominee date of birth'
              : RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)
              ? null
              : 'Enter date in YYYY-MM-DD format',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _nomineePiNoController,
          label: 'Nominee PAN/ID Number',
          hint: 'Enter nominee PAN or ID number',
          icon: Icons.credit_card_outlined,
          validator: (value) =>
          value!.isEmpty ? 'Please enter nominee PAN/ID' : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _nomineeMobileController,
          label: 'Nominee Mobile',
          hint: 'Enter nominee mobile number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) => value!.isEmpty
              ? 'Please enter nominee mobile number'
              : RegExp(r'^\d{10}$').hasMatch(value)
              ? null
              : 'Enter a valid 10-digit mobile number',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _nomineeEmailController,
          label: 'Nominee Email',
          hint: 'Enter nominee email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value!.isEmpty
              ? 'Please enter nominee email'
              : RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)
              ? null
              : 'Enter a valid email address',
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _nomineeAddr1Controller,
          label: 'Nominee Address Line 1',
          hint: 'Enter nominee address line 1',
          icon: Icons.home_outlined,
          validator: (value) =>
          value!.isEmpty ? 'Please enter nominee address line 1' : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _nomineeAddr2Controller,
          label: 'Nominee Address Line 2',
          hint: 'Enter nominee address line 2 (optional)',
          icon: Icons.home_work_outlined,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _nomineeAddr3Controller,
          label: 'Nominee Address Line 3',
          hint: 'Enter nominee address line 3 (optional)',
          icon: Icons.home_work_outlined,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _nomineeCityController,
          label: 'Nominee City',
          hint: 'Enter nominee city',
          icon: Icons.location_city_outlined,
          validator: (value) =>
          value!.isEmpty ? 'Please enter nominee city' : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _nomineePincodeController,
          label: 'Nominee Pincode',
          hint: 'Enter nominee pincode',
          icon: Icons.pin_drop_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty
              ? 'Please enter nominee pincode'
              : RegExp(r'^\d{6}$').hasMatch(value)
              ? null
              : 'Enter a valid 6-digit pincode',
        ),
      ],
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.only(left: 12.w, right: 8.w),
            child: Icon(
              icon,
              color: AppColors.secondaryText,
              size: 20.sp,
            ),
          ),
          labelStyle: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: AppColors.disabledText,
            fontSize: 14.sp,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.buttonBackground,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          errorStyle: TextStyle(
            color: AppColors.error,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required Map<String, String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: EdgeInsets.only(left: 12.w, right: 8.w),
            child: Icon(
              icon,
              color: AppColors.secondaryText,
              size: 20.sp,
            ),
          ),
          labelStyle: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.buttonBackground,
              width: 2,
            ),
          ),
        ),
        style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.secondaryText,
          size: 24.sp,
        ),
        items: items.entries
            .map((entry) => DropdownMenuItem<String>(
          value: entry.key,
          child: Text(
            entry.value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ))
            .toList(),
        onChanged: onChanged,
        dropdownColor: AppColors.cardBackground,
        elevation: 8,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
}