import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../themes/app_colors.dart';
import 'sip_goal_based_fund_screen.dart';

class SipExploreGoalGrid extends StatelessWidget {
  final List<ExploreGoal> exploreGoals = [
    ExploreGoal(
      name: 'Buying a Home',
      icon: Icons.home,
      description: 'Own your dream house',
      color: Colors.blueAccent,
      lottieAsset: 'assets/anim/sip_anim_6.json',
    ),
    ExploreGoal(
      name: 'Buying a Car',
      icon: Icons.directions_car,
      description: 'Drive your dream car',
      color: Colors.green,
      lottieAsset: 'assets/anim/sip_anim_7.json',
    ),
    ExploreGoal(
      name: 'Travel or Vacation',
      icon: Icons.flight_takeoff,
      description: 'Explore the world',
      color: Colors.pink,
      lottieAsset: 'assets/anim/sip_anim_5.json',
    ),
    ExploreGoal(
      name: 'Child’s Education',
      icon: Icons.school,
      description: 'Secure their future',
      color: Colors.indigo,
      lottieAsset: 'assets/anim/sip_anim_4.json',
    ),
    ExploreGoal(
      name: 'Wedding',
      icon: Icons.favorite,
      description: 'Plan your big day',
      color: Colors.purple,
      lottieAsset: 'assets/anim/sip_anim_2.json',
    ),
    ExploreGoal(
      name: 'Emergency Fund',
      icon: Icons.security,
      description: 'Build your safety net',
      color: Colors.red,
      lottieAsset: 'assets/anim/sip_anim_1.json',
    ),
  ];

   SipExploreGoalGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9, // Increased from 0.85 to provide more vertical space
      ),
      itemCount: exploreGoals.length,
      itemBuilder: (context, index) {
        ExploreGoal goal = exploreGoals[index];
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SipGoalBasedFundScreen(goal: goal),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12), // Reduced from 16 to 12
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor?.withOpacity(0.9) ?? const Color(0xFFF5F5F5).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        goal.lottieAsset,
                        height: 60, // Reduced from 80 to 60
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8), // Reduced from 12 to 8
                      Flexible(
                        child: Text(
                          goal.name,
                          style: TextStyle(
                            fontSize: 14, // Reduced from 16 to 14
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor ?? Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4), // Reduced from 8 to 4
                      Flexible(
                        child: Text(
                          goal.description,
                          style: TextStyle(
                            fontSize: 10, // Reduced from 12 to 10
                            color: AppColors.secondaryText ?? Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

