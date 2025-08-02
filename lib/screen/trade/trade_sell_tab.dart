import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';

class TradeSellTab extends StatelessWidget {
  final List<Map<String, dynamic>> amcList;
  final Function(Map<String, dynamic>) onSell;

  const TradeSellTab({
    Key? key,
    required this.amcList,
    required this.onSell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
            const Color(0xFF1A1A1A),
            const Color(0xFF121212),
            const Color(0xFF0F0F0F),
          ]
              : [
            Colors.white,
            const Color(0xFFFAFAFA),
            const Color(0xFFF5F5F5),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Stack(
        children: [
          // Subtle background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    isDarkMode
                        ? 'data:image/svg+xml,<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse"><path d="M 20 0 L 0 0 0 20" fill="none" stroke="%23ffffff" stroke-width="0.5" opacity="0.05"/></pattern></defs><rect width="100%" height="100%" fill="url(%23grid)"/></svg>'
                        : 'data:image/svg+xml,<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse"><path d="M 20 0 L 0 0 0 20" fill="none" stroke="%23000000" stroke-width="0.5" opacity="0.03"/></pattern></defs><rect width="100%" height="100%" fill="url(%23grid)"/></svg>',
                  ),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon container with glassmorphism
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.15),
                                (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 80.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.trending_up_rounded,
                                size: 40.sp,
                                color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 32.h),

                  // Main title with modern typography
                  Text(
                    'Ready to Invest?',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Subtitle with better spacing
                  Text(
                    'No holdings found in your portfolio',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'Start your investment journey by exploring\navailable mutual funds and building your portfolio',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Modern CTA button
                  Container(
                    width: double.infinity,
                    height: 56.h,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold ?? const Color(0xFFDAA520),
                          (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: () {
                          // Navigate to explore funds
                        },
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.explore_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Explore Funds',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Secondary action button
                  Container(
                    width: double.infinity,
                    height: 48.h,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.3),
                        width: 1.5,
                      ),
                      color: isDarkMode
                          ? Colors.transparent
                          : Colors.white,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () {
                          // Navigate to portfolio overview
                        },
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'View Market Overview',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating decorative elements
          Positioned(
            top: 40.h,
            right: 30.w,
            child: Container(
              width: 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            top: 80.h,
            right: 60.w,
            child: Container(
              width: 4.w,
              height: 4.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            bottom: 100.h,
            left: 30.w,
            child: Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}