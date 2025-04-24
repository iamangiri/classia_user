import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';

class LearnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextEditingController? searchController;
  final bool showSearch;
  final List<Widget>? actions;

  const LearnAppBar({
    Key? key,
    required this.title,
    this.searchController,
    this.showSearch = false,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryGold,
      title: showSearch
          ? TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 16.sp,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondaryText,
            size: 20.sp,
          ),
          suffixIcon: searchController != null && searchController!.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: AppColors.secondaryText,
              size: 20.sp,
            ),
            onPressed: () => searchController!.clear(),
          )
              : null,
        ),
        style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 16.sp,
        ),
        onChanged: (value) {
          // Trigger search updates via controller listener
        },
      )
          : Text(
        title,
        style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: actions,
      leading: Navigator.canPop(context)
          ? IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.primaryText,
          size: 24.sp,
        ),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}