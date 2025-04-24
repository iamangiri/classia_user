import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CommonAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryGold,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 22.sp,
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 2,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.primaryText,
          size: 24.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: actions,
      shadowColor: AppColors.border.withOpacity(0.3),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}