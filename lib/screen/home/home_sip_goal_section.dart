import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../sip/sip_explore_goal_grid.dart';
import 'dart:ui';

class HomeSipGoalSection extends StatefulWidget {
  const HomeSipGoalSection({Key? key}) : super(key: key);

  @override
  _HomeSipGoalSectionState createState() => _HomeSipGoalSectionState();
}

class _HomeSipGoalSectionState extends State<HomeSipGoalSection> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.primaryColor ?? Colors.blue,
                        AppColors.primaryGold ?? Color(0xFFDAA520),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Plan Your Financial Future',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Shader will override this
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose a goal to start your investment journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText?.withOpacity(0.8) ?? Colors.grey.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold ?? Color(0xFFDAA520),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 24),
                  SipExploreGoalGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

