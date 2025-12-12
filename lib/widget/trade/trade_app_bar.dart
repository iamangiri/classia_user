import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../screen/main/profile_screen.dart';
import '../../screen/profile/customer_support_screen.dart';
import '../../themes/app_colors.dart';

class TradeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(int) onTabSelected;
  final int currentTabIndex;

  const TradeAppBar({
    Key? key,
    required this.onTabSelected,
    required this.currentTabIndex,
  }) : super(key: key);

  @override
  State<TradeAppBar> createState() => _TradeAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(90.h);
}

class _TradeAppBarState extends State<TradeAppBar> {
  bool _isProfileHovered = false;
  bool _isSupportHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      toolbarHeight: 90.h,
      backgroundColor: isDarkMode ? Color(0xFF121212) : AppColors.primaryColor,
      elevation: 2,
      flexibleSpace: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: SafeArea(
          child: Column(
            children: [
              // Top section - Jockey Trading text with profile and support icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side - Profile icon
                  MouseRegion(
                    onEnter: (_) => setState(() => _isProfileHovered = true),
                    onExit: (_) => setState(() => _isProfileHovered = false),
                    child: IconButton(
                      icon: Icon(
                        Icons.person,
                        color: AppColors.primaryGold,
                        size: 22.sp,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      ),
                      tooltip: 'Profile',
                      padding: EdgeInsets.all(6.w),
                      splashRadius: 18.r,
                      color: _isProfileHovered
                          ? AppColors.primaryGold?.withOpacity(0.8)
                          : AppColors.primaryGold,
                    ),
                  ),

                  // Center - Jockey Trading text
                  Expanded(
                    child: Text(
                      'Jockey Trading',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryGold ?? Colors.amber,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  // Right side - Support icon
                  MouseRegion(
                    onEnter: (_) => setState(() => _isSupportHovered = true),
                    onExit: (_) => setState(() => _isSupportHovered = false),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _isSupportHovered
                            ? LinearGradient(
                          colors: [
                            AppColors.primaryGold?.withOpacity(0.2) ?? Colors.amber.withOpacity(0.2),
                            AppColors.primaryGold?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
                          ],
                        )
                            : null,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.support_agent,
                          color: _isSupportHovered
                              ? AppColors.primaryGold
                              : AppColors.primaryGold?.withOpacity(0.9),
                          size: 22.sp,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CustomerSupportScreen(showBackButton :true)),
                        ),
                        tooltip: 'Support',
                        padding: EdgeInsets.all(6.w),
                        splashRadius: 18.r,
                      ),
                    ),
                  ),
                ],
              ),



              // Bottom section - Buy/Sell tabs
              Center(
                child: Container(
                  height: 32.h,
                  width: 180.w,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: widget.currentTabIndex == 1 ? 0 : 90.w,
                        child: Container(
                          width: 90.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.currentTabIndex == 1
                                  ? [
                                AppColors.success ?? Colors.green,
                                AppColors.success?.withOpacity(0.8) ?? Colors.green.withOpacity(0.8),
                              ]
                                  : [
                                AppColors.error ?? Colors.red,
                                AppColors.error?.withOpacity(0.8) ?? Colors.red.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => widget.onTabSelected(1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Buy',
                                    style: TextStyle(
                                      color: widget.currentTabIndex == 1
                                          ? AppColors.buttonText ?? Colors.white
                                          : AppColors.primaryGold ?? const Color(0xFFDAA520),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => widget.onTabSelected(0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sell',
                                    style: TextStyle(
                                      color: widget.currentTabIndex == 0
                                          ? AppColors.buttonText ?? Colors.white
                                          : AppColors.primaryGold ?? const Color(0xFFDAA520),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
}