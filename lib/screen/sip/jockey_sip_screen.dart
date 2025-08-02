import 'package:classia_amc/screen/sip/sip_explore_tab.dart';
import 'package:classia_amc/screen/sip/sip_model.dart';
import 'package:classia_amc/screen/sip/sip_portfolio_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';
import '../../themes/app_colors.dart';




// JockeySipScreen (Unchanged)
class JockeySipScreen extends StatefulWidget {
  const JockeySipScreen({super.key});

  @override
  _JockeySipScreenState createState() => _JockeySipScreenState();
}

class _JockeySipScreenState extends State<JockeySipScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 1;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isProfileHovered = false;
  bool _isCalcHovered = false;
  bool _isSupportHovered = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: 70.h,
              pinned: true,
              backgroundColor: isDarkMode
                  ? const Color(0xFF121212)
                  : AppColors.primaryColor ?? Colors.blue,
              elevation: 2,
              flexibleSpace: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MouseRegion(
                        onEnter: (_) =>
                            setState(() => _isProfileHovered = true),
                        onExit: (_) =>
                            setState(() => _isProfileHovered = false),
                        child: IconButton(
                          icon: Icon(Icons.person,
                              color: AppColors.primaryGold ??
                                  const Color(0xFFDAA520),
                              size: 24.sp),
                          onPressed: () {},
                          tooltip: 'Profile',
                        ),
                      ),
                      Container(
                        height: 36.h,
                        width: 200.w,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8.r,
                                offset: Offset(0, 2.h))
                          ],
                        ),
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              left: _currentIndex == 1 ? 0 : 100.w,
                              child: Container(
                                width: 100.w,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _currentIndex == 1
                                        ? [
                                            AppColors.success ?? Colors.green,
                                            AppColors.success
                                                    ?.withOpacity(0.8) ??
                                                Colors.green.withOpacity(0.8)
                                          ]
                                        : [
                                            AppColors.error ?? Colors.red,
                                            AppColors.error?.withOpacity(0.8) ??
                                                Colors.red.withOpacity(0.8)
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _currentIndex = 1),
                                    child: Center(
                                      child: Text(
                                        'Buy SIP',
                                        style: TextStyle(
                                          color: _currentIndex == 1
                                              ? AppColors.buttonText ??
                                                  Colors.white
                                              : AppColors.primaryGold ??
                                                  const Color(0xFFDAA520),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _currentIndex = 0),
                                    child: Center(
                                      child: Text(
                                        'Sell SIP',
                                        style: TextStyle(
                                          color: _currentIndex == 0
                                              ? AppColors.buttonText ??
                                                  Colors.white
                                              : AppColors.primaryGold ??
                                                  const Color(0xFFDAA520),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MouseRegion(
                            onEnter: (_) =>
                                setState(() => _isCalcHovered = true),
                            onExit: (_) =>
                                setState(() => _isCalcHovered = false),
                            child: IconButton(
                              icon: Icon(Icons.calculate,
                                  color: AppColors.primaryGold ??
                                      const Color(0xFFDAA520),
                                  size: 24.sp),
                              onPressed: () {},
                              tooltip: 'Calculator',
                            ),
                          ),
                          MouseRegion(
                            onEnter: (_) =>
                                setState(() => _isSupportHovered = true),
                            onExit: (_) =>
                                setState(() => _isSupportHovered = false),
                            child: IconButton(
                              icon: Icon(Icons.support_agent,
                                  color: AppColors.primaryGold ??
                                      const Color(0xFFDAA520),
                                  size: 24.sp),
                              onPressed: () {},
                              tooltip: 'Support',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF121212)
                      : AppColors.backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r)),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentIndex == 0
                      ? const PortfolioTab()
                      : const ExploreTab(),
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }
}




