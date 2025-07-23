import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import '../../themes/app_colors.dart';
import '../profile/learn_screen.dart';

class HomeLearnSection extends StatefulWidget {
  const HomeLearnSection({super.key});

  @override
  _HomeLearnSectionState createState() => _HomeLearnSectionState();
}

class _HomeLearnSectionState extends State<HomeLearnSection> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isButtonTapped = false;
  bool _isHovered = false;

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
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(


          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Row
                    Row(
                      children: [


                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AppColors.primaryColor ?? Colors.blue,
                                    AppColors.primaryGold ?? const Color(0xFFDAA520),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  'Learn & Earn',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              SizedBox(height: 6.h),
                              Text(
                                'Earn 1000 points by learning about mutual funds, SIPs, and more. Redeem points for real money!',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : AppColors.secondaryText?.withOpacity(0.85) ?? Colors.grey,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                height: 3.h,
                                width: 100.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),

                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Lottie.asset(
                          'assets/anim/sip_anim_4.json',
                          height: 100.h,
                          width: 100.w,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.school,
                            size: 60.sp,
                            color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _isButtonTapped = true),
                        onTapUp: (_) {
                          setState(() => _isButtonTapped = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  LearnScreen()),
                          );
                        },
                        onTapCancel: () => setState(() => _isButtonTapped = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()..scale(_isButtonTapped ? 0.95 : 1.0),
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Text(
                            'Start Learning',
                            style: TextStyle(
                              color: AppColors.buttonText ?? Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}