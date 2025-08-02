// import 'package:classia_amc/screen/sip/sip_wishlist_tab.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../../themes/app_colors.dart';
// import '../../widget/common_app_bar.dart';
// import 'jockey_sip_screen.dart';
//
//
// class AddEditGoalScreen extends StatefulWidget {
//   final Function(WishlistItem) onSave;
//   final WishlistItem? initialItem;
//
//   const AddEditGoalScreen({
//     Key? key,
//     required this.onSave,
//     this.initialItem,
//   }) : super(key: key);
//
//   @override
//   _AddEditGoalScreenState createState() => _AddEditGoalScreenState();
// }
//
// class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _targetAmountController = TextEditingController();
//   final TextEditingController _monthlySIPController = TextEditingController();
//   IconData _selectedIcon = Icons.star;
//   Color _selectedColor = Colors.blue;
//   bool _isLoading = false;
//
//   final List<Map<String, dynamic>> _iconOptions = [
//     {'icon': Icons.villa, 'name': 'Villa'},
//     {'icon': Icons.school, 'name': 'School'},
//     {'icon': Icons.directions_boat, 'name': 'Yacht'},
//     {'icon': Icons.flight, 'name': 'Travel'},
//     {'icon': Icons.car_rental, 'name': 'Car'},
//     {'icon': FontAwesomeIcons.gift, 'name': 'Gift'},
//   ];
//
//   final List<Color> _colorOptions = [
//     Colors.blue,
//     Colors.green,
//     Colors.purple,
//     Colors.red,
//     Colors.orange,
//     Colors.teal,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialItem != null) {
//       _nameController.text = widget.initialItem!.name;
//       _targetAmountController.text = widget.initialItem!.targetAmount.toString();
//       _monthlySIPController.text = widget.initialItem!.monthlySIP.toString();
//       _selectedIcon = widget.initialItem!.icon;
//       _selectedColor = widget.initialItem!.color;
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _targetAmountController.dispose();
//     _monthlySIPController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submitGoal() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
//       try {
//         final newItem = WishlistItem(
//           name: _nameController.text.trim(),
//           icon: _selectedIcon,
//           targetAmount: double.parse(_targetAmountController.text.trim()),
//           monthlySIP: double.parse(_monthlySIPController.text.trim()),
//           progress: widget.initialItem?.progress ?? 0,
//           color: _selectedColor,
//         );
//         widget.onSave(newItem);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(widget.initialItem == null ? 'Goal added successfully' : 'Goal updated successfully'),
//             backgroundColor: AppColors.success,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//           ),
//         );
//         Navigator.pop(context);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//           ),
//         );
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please fix the errors in the form'),
//           backgroundColor: AppColors.error,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//         ),
//       );
//     }
//   }
//
//   InputDecoration _inputDecoration(String label, String hint, {IconData? prefixIcon}) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
//       hintStyle: TextStyle(
//         color: AppColors.secondaryText?.withOpacity(0.7) ?? Colors.grey.withOpacity(0.7),
//         fontSize: 14.sp,
//       ),
//       prefixIcon: prefixIcon != null
//           ? Padding(
//         padding: EdgeInsets.only(left: 12.w, right: 8.w),
//         child: Icon(prefixIcon, color: AppColors.secondaryText, size: 20.sp),
//       )
//           : null,
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30.r),
//         borderSide: BorderSide(color: AppColors.primaryGold ?? Colors.amber, width: 2.w),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30.r),
//         borderSide: BorderSide(color: AppColors.primaryGold ?? Colors.amber, width: 2.w),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30.r),
//         borderSide: BorderSide(color: AppColors.error, width: 2.w),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30.r),
//         borderSide: BorderSide(color: AppColors.error, width: 2.w),
//       ),
//       contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//       errorStyle: TextStyle(color: AppColors.error, fontSize: 12.sp, height: 0.5),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.screenBackground,
//       appBar: CommonAppBar(
//         title: widget.initialItem == null ? 'Add New Goal' : 'Edit Goal',
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
//                 decoration: _inputDecoration('Goal Name', 'Enter goal name', prefixIcon: Icons.label),
//                 validator: (value) => value == null || value.trim().isEmpty ? 'Please enter goal name' : null,
//               ),
//               SizedBox(height: 16.h),
//               TextFormField(
//                 controller: _targetAmountController,
//                 keyboardType: TextInputType.number,
//                 style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
//                 decoration: _inputDecoration('Target Amount', 'Enter target amount (₹)', prefixIcon: Icons.monetization_on),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) return 'Please enter target amount';
//                   if (double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) return 'Please enter a valid amount';
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16.h),
//               TextFormField(
//                 controller: _monthlySIPController,
//                 keyboardType: TextInputType.number,
//                 style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
//                 decoration: _inputDecoration('Monthly SIP', 'Enter monthly SIP amount (₹)', prefixIcon: Icons.payments),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) return 'Please enter monthly SIP amount';
//                   if (double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) return 'Please enter a valid amount';
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16.h),
//               Text(
//                 'Select Icon',
//                 style: TextStyle(
//                   color: AppColors.primaryText,
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Wrap(
//                 spacing: 12.w,
//                 runSpacing: 12.h,
//                 children: _iconOptions.map((option) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedIcon = option['icon'];
//                       });
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(8.w),
//                       decoration: BoxDecoration(
//                         color: _selectedIcon == option['icon']
//                             ? (AppColors.primaryGold ?? Colors.amber).withOpacity(0.2)
//                             : Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8.r),
//                         border: Border.all(
//                           color: _selectedIcon == option['icon']
//                               ? AppColors.primaryGold ?? Colors.amber
//                               : Colors.grey,
//                         ),
//                       ),
//                       child: Icon(
//                         option['icon'],
//                         color: _selectedIcon == option['icon'] ? AppColors.primaryGold ?? Colors.amber : AppColors.secondaryText,
//                         size: 24.sp,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               SizedBox(height: 16.h),
//               Text(
//                 'Select Color',
//                 style: TextStyle(
//                   color: AppColors.primaryText,
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Wrap(
//                 spacing: 12.w,
//                 runSpacing: 12.h,
//                 children: _colorOptions.map((color) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedColor = color;
//                       });
//                     },
//                     child: Container(
//                       width: 40.w,
//                       height: 40.h,
//                       decoration: BoxDecoration(
//                         color: color,
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: _selectedColor == color
//                               ? AppColors.primaryGold ?? Colors.amber
//                               : Colors.transparent,
//                           width: 2.w,
//                         ),
//                       ),
//                       child: _selectedColor == color
//                           ? Icon(
//                         Icons.check,
//                         color: Colors.white,
//                         size: 20.sp,
//                       )
//                           : null,
//                     ),
//                   );
//                 }).toList(),
//               ),
//               SizedBox(height: 24.h),
//               SizedBox(
//                 width: double.infinity,
//                 height: 56.h,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//                     elevation: 2,
//                   ),
//                   onPressed: _isLoading ? null : _submitGoal,
//                   child: Ink(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           AppColors.primaryGold ?? Colors.amber,
//                           Color(0xFFFFA500),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Center(
//                       child: _isLoading
//                           ? SizedBox(
//                         width: 24.w,
//                         height: 24.h,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText ?? Colors.white),
//                         ),
//                       )
//                           : Text(
//                         widget.initialItem == null ? 'Add Goal' : 'Update Goal',
//                         style: TextStyle(
//                           color: AppColors.buttonText ?? Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.h),
//               Center(
//                 child: TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text(
//                     'Cancel',
//                     style: TextStyle(
//                       color: AppColors.secondaryText ?? Colors.grey,
//                       fontSize: 16.sp,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }