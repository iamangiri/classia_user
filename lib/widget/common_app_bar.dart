import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utills/themes/light_app_theme.dart';


class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool isTransparent;
  final double elevation;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.isTransparent = false,
    this.elevation = 0,
    this.flexibleSpace,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDarkBlue,
            AppTheme.primaryDarkBlue.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDarkBlue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: elevation,
        centerTitle: centerTitle,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: flexibleSpace ??
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryDarkBlue,
                    AppTheme.primaryDarkBlue.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -30.w,
                    top: -20.h,
                    child: Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.03),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20.w,
                    bottom: -30.h,
                    child: Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryGold.withOpacity(0.08),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        leading: leading ??
            (showBackButton
                ? Padding(
              padding: EdgeInsets.all(8.w),
              child: GestureDetector(
                onTap: onBackPressed ?? () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            )
                : null),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: actions ??
            [
              // Default spacing to balance the back button
              SizedBox(width: 56.w),
            ],
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

// Extended version with more features
class CommonAppBarExtended extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool centerTitle;
  final Widget? titleWidget;
  final double expandedHeight;
  final Widget? bottomWidget;

  const CommonAppBarExtended({
    Key? key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.centerTitle = true,
    this.titleWidget,
    this.expandedHeight = 120,
    this.bottomWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: expandedHeight.h + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDarkBlue,
            AppTheme.primaryDarkBlue.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDarkBlue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorations
          Positioned(
            right: -40.w,
            top: -30.h,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            left: -30.w,
            bottom: -40.h,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withOpacity(0.1),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  // Top row with back button and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (showBackButton)
                        GestureDetector(
                          onTap: onBackPressed ?? () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        )
                      else
                        SizedBox(width: 44.w),
                      if (actions != null)
                        Row(children: actions!)
                      else
                        SizedBox(width: 44.w),
                    ],
                  ),
                  const Spacer(),
                  // Title section
                  if (titleWidget != null)
                    titleWidget!
                  else
                    Column(
                      crossAxisAlignment: centerTitle
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        if (centerTitle)
                          Center(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                        else
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        if (subtitle != null) ...[
                          SizedBox(height: 6.h),
                          if (centerTitle)
                            Center(
                              child: Text(
                                subtitle!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            )
                          else
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ],
                    ),
                  SizedBox(height: 16.h),
                  if (bottomWidget != null) bottomWidget!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(expandedHeight.h);
}

// Simple variant for minimal screens
class CommonAppBarSimple extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CommonAppBarSimple({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryDarkBlue;
    final fgColor = foregroundColor ?? Colors.white;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: showBackButton
          ? IconButton(
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: fgColor,
          size: 22.sp,
        ),
      )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          color: fgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// App bar with search functionality
class CommonAppBarWithSearch extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CommonAppBarWithSearch({
    Key? key,
    required this.title,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.onSearchClear,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<CommonAppBarWithSearch> createState() => _CommonAppBarWithSearchState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 60.h);
}

class _CommonAppBarWithSearchState extends State<CommonAppBarWithSearch> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDarkBlue,
            AppTheme.primaryDarkBlue.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDarkBlue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Main app bar
            SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  if (widget.showBackButton)
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: GestureDetector(
                        onTap: widget.onBackPressed ?? () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (widget.actions != null)
                    ...widget.actions!
                  else
                    SizedBox(width: 56.w),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 22.sp,
                    ),
                    suffixIcon: _isSearching
                        ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _isSearching = false);
                        widget.onSearchClear?.call();
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 20.sp,
                      ),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _isSearching = value.isNotEmpty);
                    widget.onSearchChanged?.call(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Action button helper widget
class AppBarActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
  final Color? iconColor;

  const AppBarActionButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.badge,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: iconColor ?? Colors.white,
                size: 22.sp,
              ),
              if (badge != null)
                Positioned(
                  right: -6.w,
                  top: -6.h,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 16.h,
                    ),
                    child: Center(
                      child: Text(
                        badge!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
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