import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../themes/app_colors.dart';
import 'sip_explore_goal_grid.dart';
import 'sip_goal_based_fund_screen.dart';
import 'dart:ui';

class ExploreTab extends StatefulWidget {
  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with TickerProviderStateMixin {
  late AnimationController _horseAnimationController;
  late Animation<double> _horseAnimation;

  @override
  void initState() {
    super.initState();
    _horseAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _horseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _horseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _horseAnimationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedHorse() {
    return AnimatedBuilder(
      animation: _horseAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 5 * (0.5 - (_horseAnimation.value - 0.5).abs())),
          child: Transform.rotate(
            angle: 0.1 * (0.5 - (_horseAnimation.value - 0.5).abs()),
            child: Container(
              width: 150,
              height: 100,
              child: Center(
                child: Image.asset(
                  'assets/images/jt1.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                _buildAnimatedHorse(),
                SizedBox(height: 16),
                Text(
                  'Explore New Goals',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor ?? Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Discover investment opportunities',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SipExploreGoalGrid(),
        ],
      ),
    );
  }
}