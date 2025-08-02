import 'package:classia_amc/screen/sip/sip_explore_goal_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../themes/app_colors.dart';
import 'jockey_sip_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with TickerProviderStateMixin {
  late AnimationController _horseAnimationController;
  late Animation<double> _horseAnimation;

  @override
  void initState() {
    super.initState();
    _horseAnimationController =
    AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat();
    _horseAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _horseAnimationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _horseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Column(
            children: [
              AnimatedBuilder(
                animation: _horseAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0, 5.h * (0.5 - (_horseAnimation.value - 0.5).abs())),
                    child: Transform.rotate(
                      angle: 0.1 * (0.5 - (_horseAnimation.value - 0.5).abs()),
                      child: SizedBox(
                        width: 150.w,
                        height: 100.h,
                        child: Center(
                            child: Image.asset('assets/images/jt1.gif',
                                fit: BoxFit.contain)),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),
              Text(
                'Explore New Goals',
                style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor ?? Colors.blue),
              ),
              SizedBox(height: 8.h),
              Text(
                'Discover investment opportunities',
                style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.secondaryText ?? Colors.grey),
              ),
            ],
          ),
          const SipExploreGoalGrid(),
        ],
      ),
    );
  }
}