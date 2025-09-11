// import 'package:classia_amc/widget/common_app_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:classia_amc/themes/app_colors.dart';
// import '../../service/apiservice/can_service.dart';
//
// class PayZeeRegistrationScreen extends StatefulWidget {
//   const PayZeeRegistrationScreen({Key? key}) : super(key: key);
//
//   @override
//   _PayZeeRegistrationScreenState createState() => _PayZeeRegistrationScreenState();
// }
//
// class _PayZeeRegistrationScreenState extends State<PayZeeRegistrationScreen>
//     with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   // Form field controllers
//   final _maxAmountController = TextEditingController();
//
//   // Dropdown selections
//
//
//   late CamService _camService;
//
//   // Dropdown options
//
//   @override
//   void initState() {
//     super.initState();
//     _camService = CamService();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//
//     // Set default values
//
//     _maxAmountController.text = '10000';
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _maxAmountController.dispose();
//     super.dispose();
//   }
//
//   bool _validateForm() {
//     return _formKey.currentState?.validate() ?? false && _regMode != null;
//   }
//
//   void _showValidationError() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white),
//             SizedBox(width: 8.w),
//             Expanded(
//               child: Text(
//                 'Please fill all required fields correctly',
//                 style: TextStyle(fontSize: 14.sp),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppColors.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//         margin: EdgeInsets.all(16.w),
//       ),
//     );
//   }
//
//   Future<void> _submitForm() async {
//     if (!_validateForm()) {
//       _showValidationError();
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final payload = {
//         "regMode": "PN",
//         "maxAmt": int.tryParse(_maxAmountController.text) ?? 10000,
//       };
//
//       final response = await _camService.registerPayZee(payload);
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.white),
//               SizedBox(width: 8.w),
//               Expanded(
//                 child: Text(
//                   'PayZee registration successful!',
//                   style: TextStyle(fontSize: 14.sp),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppColors.success,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           margin: EdgeInsets.all(16.w),
//         ),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(Icons.error_outline, color: Colors.white),
//               SizedBox(width: 8.w),
//               Expanded(
//                 child: Text(
//                   'Error: ${e.toString()}',
//                   style: TextStyle(fontSize: 14.sp),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppColors.error,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           margin: EdgeInsets.all(16.w),
//         ),
//       );
//     } finally {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.screenBackground,
//       appBar: CommonAppBar(
//         title: 'PayZee Registration',
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             children: [
//               // Header Section
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(24.w),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       AppColors.buttonBackground,
//                       AppColors.buttonBackground.withOpacity(0.8),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(16.r),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.buttonBackground.withOpacity(0.3),
//                       blurRadius: 20,
//                       spreadRadius: 0,
//                       offset: Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(16.w),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(50.r),
//                       ),
//                       child: Icon(
//                         Icons.payment_outlined,
//                         color: Colors.white,
//                         size: 48.sp,
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     Text(
//                       'PayZee Registration',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Text(
//                       'Configure your PayZee payment gateway settings',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 24.h),
//
//               // Form Section
//               Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.cardBackground,
//                   borderRadius: BorderRadius.circular(16.r),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       spreadRadius: 0,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(24.w),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: EdgeInsets.all(8.w),
//                               decoration: BoxDecoration(
//                                 color: AppColors.buttonBackground.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               child: Icon(
//                                 Icons.settings_outlined,
//                                 color: AppColors.buttonBackground,
//                                 size: 20.sp,
//                               ),
//                             ),
//                             SizedBox(width: 12.w),
//                             Text(
//                               'Registration Details',
//                               style: TextStyle(
//                                 color: AppColors.primaryText,
//                                 fontSize: 18.sp,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 24.h),
//
//                         _buildDropdownField(
//                           label: 'Registration Mode',
//                           value: _regMode,
//                           items: regModeOptions,
//                           icon: Icons.app_registration_outlined,
//                           onChanged: (value) => setState(() => _regMode = value),
//                           isRequired: true,
//                         ),
//                         SizedBox(height: 20.h),
//
//                         _buildTextField(
//                           controller: _maxAmountController,
//                           label: 'Maximum Amount',
//                           hint: 'Enter maximum transaction amount',
//                           icon: Icons.currency_rupee_outlined,
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter maximum amount';
//                             }
//                             final amount = int.tryParse(value);
//                             if (amount == null) {
//                               return 'Enter a valid amount';
//                             }
//                             if (amount <= 0) {
//                               return 'Amount must be greater than 0';
//                             }
//                             if (amount > 100000) {
//                               return 'Amount cannot exceed ₹1,00,000';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         SizedBox(height: 32.h),
//
//                         // Info Section
//                         Container(
//                           padding: EdgeInsets.all(16.w),
//                           decoration: BoxDecoration(
//                             color: AppColors.buttonBackground.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12.r),
//                             border: Border.all(
//                               color: AppColors.buttonBackground.withOpacity(0.3),
//                               width: 1,
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.info_outline,
//                                 color: AppColors.buttonBackground,
//                                 size: 20.sp,
//                               ),
//                               SizedBox(width: 12.w),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Important Information',
//                                       style: TextStyle(
//                                         color: AppColors.buttonBackground,
//                                         fontSize: 14.sp,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     SizedBox(height: 4.h),
//                                     Text(
//                                       '• Registration mode determines your primary verification method\n• Maximum amount sets the transaction limit for your account\n• You can modify these settings later from your profile',
//                                       style: TextStyle(
//                                         color: AppColors.secondaryText,
//                                         fontSize: 12.sp,
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 32.h),
//
//               // Submit Button
//               Container(
//                 width: double.infinity,
//                 height: 56.h,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.buttonBackground,
//                     foregroundColor: AppColors.buttonText,
//                     elevation: 8,
//                     shadowColor: AppColors.buttonBackground.withOpacity(0.4),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? SizedBox(
//                     width: 24.w,
//                     height: 24.h,
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                           AppColors.buttonText),
//                       strokeWidth: 2.5,
//                     ),
//                   )
//                       : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.app_registration,
//                         size: 20.sp,
//                       ),
//                       SizedBox(width: 8.w),
//                       Text(
//                         'Register PayZee Account',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 8,
//             spreadRadius: 0,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         style: TextStyle(
//           color: AppColors.primaryText,
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           prefixIcon: Container(
//             margin: EdgeInsets.only(left: 12.w, right: 8.w),
//             child: Icon(
//               icon,
//               color: AppColors.secondaryText,
//               size: 20.sp,
//             ),
//           ),
//           labelStyle: TextStyle(
//             color: AppColors.secondaryText,
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//           ),
//           hintStyle: TextStyle(
//             color: AppColors.disabledText,
//             fontSize: 14.sp,
//           ),
//           filled: true,
//           fillColor: AppColors.cardBackground,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 16.w,
//             vertical: 18.h,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.border.withOpacity(0.3),
//               width: 1.5,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.border.withOpacity(0.3),
//               width: 1.5,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.buttonBackground,
//               width: 2,
//             ),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.error,
//               width: 1.5,
//             ),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.error,
//               width: 2,
//             ),
//           ),
//           errorStyle: TextStyle(
//             color: AppColors.error,
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         validator: validator,
//       ),
//     );
//   }
//
//   Widget _buildDropdownField({
//     required String label,
//     required String? value,
//     required Map<String, String> items,
//     required IconData icon,
//     required void Function(String?) onChanged,
//     bool isRequired = false,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 8,
//             spreadRadius: 0,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           labelText: label + (isRequired ? ' *' : ''),
//           prefixIcon: Container(
//             margin: EdgeInsets.only(left: 12.w, right: 8.w),
//             child: Icon(
//               icon,
//               color: AppColors.secondaryText,
//               size: 20.sp,
//             ),
//           ),
//           labelStyle: TextStyle(
//             color: AppColors.secondaryText,
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//           ),
//           filled: true,
//           fillColor: AppColors.cardBackground,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 16.w,
//             vertical: 18.h,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.border.withOpacity(0.3),
//               width: 1.5,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.border.withOpacity(0.3),
//               width: 1.5,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.buttonBackground,
//               width: 2,
//             ),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.error,
//               width: 1.5,
//             ),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.error,
//               width: 2,
//             ),
//           ),
//         ),
//         style: TextStyle(
//           color: AppColors.primaryText,
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w500,
//         ),
//         icon: Icon(
//           Icons.keyboard_arrow_down_rounded,
//           color: AppColors.secondaryText,
//           size: 24.sp,
//         ),
//         items: items.entries
//             .map((entry) => DropdownMenuItem<String>(
//           value: entry.key,
//           child: Text(
//             entry.value,
//             style: TextStyle(
//               color: AppColors.primaryText,
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ))
//             .toList(),
//         onChanged: onChanged,
//         validator: isRequired
//             ? (value) => value == null ? 'Please select $label' : null
//             : null,
//         dropdownColor: AppColors.cardBackground,
//         elevation: 8,
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//     );
//   }
// }




import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import '../../service/apiservice/can_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PayZeeRegistrationScreen extends StatefulWidget {
  const PayZeeRegistrationScreen({Key? key}) : super(key: key);

  @override
  _PayZeeRegistrationScreenState createState() => _PayZeeRegistrationScreenState();
}

class _PayZeeRegistrationScreenState extends State<PayZeeRegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form field controllers
  final _maxAmountController = TextEditingController();

  late CamService _camService;

  // State for PayZee status
  Map<String, dynamic>? _payZeeStatus;
  bool _isCheckingStatus = true;
  bool _hasPayZee = false;

  @override
  void initState() {
    super.initState();
    _camService = CamService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Set default values
    _maxAmountController.text = '10000';

    _checkPayZeeStatus();
  }

  Future<void> _checkPayZeeStatus() async {
    setState(() => _isCheckingStatus = true);
    try {
      final response = await _camService.getPayZeeStatus();
      if (response['status'] == true) {
        final data = response['data'];
        setState(() {
          _payZeeStatus = data;
          // Adjust based on your API logic; here, assuming 'mmrnRegStatus' == 'PE' means registered
          _hasPayZee = data['mmrnRegStatus'] == 'PE';
        });
      }
    } catch (e) {
      print('Error checking PayZee status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking PayZee status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isCheckingStatus = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
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
    if (!_validateForm()) {
      _showValidationError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = {
        "regMode": "PN",
        "maxAmt": int.tryParse(_maxAmountController.text) ?? 10000,
      };

      final response = await _camService.registerPayZee(payload);
      if (!mounted) return;

      // Extract approveLink from response
      final approveLink = response['data']?['approveLink'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'PayZee registration successful!',
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

      // Launch approveLink if available
      if (approveLink != null && approveLink.isNotEmpty) {
        final Uri url = Uri.parse(approveLink);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch approval link'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }

      // Refresh status after registration
      await _checkPayZeeStatus();
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
        title: 'PayZee Registration',
      ),
      body: _isCheckingStatus
          ? const Center(child: CircularProgressIndicator())
          : _hasPayZee
          ? _buildStatusDisplay()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.buttonBackground,
                      AppColors.buttonBackground.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.buttonBackground.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: Icon(
                        Icons.payment_outlined,
                        color: Colors.white,
                        size: 48.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'PayZee Registration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Configure your PayZee payment gateway settings',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Form Section
              Container(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.buttonBackground.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.settings_outlined,
                                color: AppColors.buttonBackground,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Registration Details',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        _buildTextField(
                          controller: _maxAmountController,
                          label: 'Maximum Amount',
                          hint: 'Enter maximum transaction amount',
                          icon: Icons.currency_rupee_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter maximum amount';
                            }
                            final amount = int.tryParse(value);
                            if (amount == null) {
                              return 'Enter a valid amount';
                            }
                            if (amount <= 0) {
                              return 'Amount must be greater than 0';
                            }
                            if (amount > 100000) {
                              return 'Amount cannot exceed ₹1,00,000';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 32.h),

                        // Info Section
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.buttonBackground.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.buttonBackground.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.buttonBackground,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Important Information',
                                      style: TextStyle(
                                        color: AppColors.buttonBackground,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '• Maximum amount sets the transaction limit for your account\n• You can modify these settings later from your profile',
                                      style: TextStyle(
                                        color: AppColors.secondaryText,
                                        fontSize: 12.sp,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Submit Button
              Container(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    foregroundColor: AppColors.buttonText,
                    elevation: 8,
                    shadowColor: AppColors.buttonBackground.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.buttonText),
                      strokeWidth: 2.5,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.app_registration,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Register PayZee Account',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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

  Widget _buildStatusDisplay() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
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
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'Your PayZee Status',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              _buildStatusCard('Aggregate Status', _payZeeStatus?['mmrnAggrStatus'] ?? 'N/A'),
              SizedBox(height: 8.h),
              _buildStatusCard('Registration Status', _payZeeStatus?['mmrnRegStatus'] ?? 'N/A'),
              SizedBox(height: 8.h),
              _buildStatusCard('PRN', _payZeeStatus?['prn']?.trim() ?? 'N/A'),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  _checkPayZeeStatus(); // Refresh status
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: AppColors.buttonText,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                ),
                child: Text(
                  'Refresh Status',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.buttonBackground.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
}