import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';

class KycAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch; // Optional search icon (from prior context, e.g., HomeScreen)
  final List<Widget>? actions; // Added to support KYCVerificationScreen
  final VoidCallback? onSearchPressed; // Optional callback for search

  const KycAppBar({
    Key? key,
    required this.title,
    this.showSearch = false,
    this.actions,
    this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryGold,
      elevation: 0, // Flat design for modern look
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Navigator.canPop(context)
          ? IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primaryText, size: 24.sp),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      actions: [
        // Include search icon if showSearch is true
        if (showSearch)
          IconButton(
            icon: Icon(Icons.search, color: AppColors.primaryText, size: 24.sp),
            onPressed: onSearchPressed,
          ),
        // Include custom actions if provided
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}