import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:classia_amc/screen/sip/sip_portfolio_tab.dart';
import 'package:classia_amc/screen/sip/sip_explore_tab.dart';
import 'package:classia_amc/screen/calcutator/sip_calcutator.dart';
import 'package:classia_amc/screen/main/profile_screen.dart';
import 'package:classia_amc/screen/profile/customer_support_screen.dart';
import '../../themes/app_colors.dart';

class Goal {
  final int id;
  final String name;
  final IconData icon;
  final double target;
  final double current;
  final double monthlyPayment;
  final Color color;
  final double progress;
  final String lottieAsset;

  Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.target,
    required this.current,
    required this.monthlyPayment,
    required this.color,
    required this.progress,
    required this.lottieAsset,
  });
}

class Fund {
  final String name;
  final String returnRate;
  final String risk;
  final Color color;

  Fund({
    required this.name,
    required this.returnRate,
    required this.risk,
    required this.color,
  });
}

class JockeySipScreen extends StatefulWidget {
  const JockeySipScreen({super.key});

  @override
  _JockeySipScreenState createState() => _JockeySipScreenState();
}

class _JockeySipScreenState extends State<JockeySipScreen> with TickerProviderStateMixin {
  int _currentIndex = 1; // Changed to 1 to select "Buy SIP" by default
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isProfileHovered = false;
  bool _isCalcHovered = false;
  bool _isSupportHovered = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
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
              backgroundColor: isDarkMode ? const Color(0xFF121212) : AppColors.primaryColor ?? Colors.blue,
              elevation: 2,
              flexibleSpace: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Actions (Profile)
                      MouseRegion(
                        onEnter: (_) => setState(() => _isProfileHovered = true),
                        onExit: (_) => setState(() => _isProfileHovered = false),
                        child: IconButton(
                          icon: Icon(
                            Icons.person,
                            color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                            size: 24.sp,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          ),
                          tooltip: 'Profile',
                          padding: EdgeInsets.all(8.w),
                          splashRadius: 20.r,
                          color: _isProfileHovered
                              ? (AppColors.primaryGold?.withOpacity(0.8) ?? const Color(0xFFDAA520).withOpacity(0.8))
                              : (AppColors.primaryGold ?? const Color(0xFFDAA520)),
                        ),
                      ),
                      // Tab Bar
                      Container(
                        height: 36.h,
                        width: 200.w,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
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
                                      AppColors.success?.withOpacity(0.8) ?? Colors.green.withOpacity(0.8),
                                    ]
                                        : [
                                      AppColors.error ?? Colors.red,
                                      AppColors.error?.withOpacity(0.8) ?? Colors.red.withOpacity(0.8),
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
                                    onTap: () => setState(() => _currentIndex = 1),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Buy SIP',
                                          style: TextStyle(
                                            color: _currentIndex == 1
                                                ? AppColors.buttonText ?? Colors.white
                                                : AppColors.primaryGold ?? const Color(0xFFDAA520),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _currentIndex = 0),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Sell SIP',
                                          style: TextStyle(
                                            color: _currentIndex == 0
                                                ? AppColors.buttonText ?? Colors.white
                                                : AppColors.primaryGold ?? const Color(0xFFDAA520),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.sp,
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
                      // Right Actions (Calculator, Support)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MouseRegion(
                            onEnter: (_) => setState(() => _isCalcHovered = true),
                            onExit: (_) => setState(() => _isCalcHovered = false),
                            child: IconButton(
                              icon: Icon(
                                Icons.calculate,
                                color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                                size: 24.sp,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  InvestmentCalculator()),
                              ),
                              tooltip: 'Calculator',
                              padding: EdgeInsets.all(8.w),
                              splashRadius: 20.r,
                              color: _isCalcHovered
                                  ? (AppColors.primaryGold?.withOpacity(0.8) ?? const Color(0xFFDAA520).withOpacity(0.8))
                                  : (AppColors.primaryGold ?? const Color(0xFFDAA520)),
                            ),
                          ),
                          MouseRegion(
                            onEnter: (_) => setState(() => _isSupportHovered = true),
                            onExit: (_) => setState(() => _isSupportHovered = false),
                            child: IconButton(
                              icon: Icon(
                                Icons.support_agent,
                                color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                                size: 24.sp,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  CustomerSupportScreen()),
                              ),
                              tooltip: 'Support',
                              padding: EdgeInsets.all(8.w),
                              splashRadius: 20.r,
                              color: _isSupportHovered
                                  ? (AppColors.primaryGold?.withOpacity(0.8) ?? const Color(0xFFDAA520).withOpacity(0.8))
                                  : (AppColors.primaryGold ?? const Color(0xFFDAA520)),
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
                  color: isDarkMode ? const Color(0xFF121212) : AppColors.backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentIndex == 0 ?  PortfolioTab() :  ExploreTab(),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
          onPressed: () {
            // TODO: Implement add new SIP functionality
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold ?? const Color(0xFFDAA520),
                  AppColors.primaryColor?.withOpacity(0.8) ?? Colors.blue.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        )
            : null,
      ),
    );
  }
}