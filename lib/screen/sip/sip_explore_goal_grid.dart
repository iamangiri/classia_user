import 'package:classia_amc/screen/sip/sip_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/app_colors.dart';
import 'sip_goal_based_fund_screen.dart';
import 'dart:convert';




class SipExploreGoalGrid extends StatefulWidget {
  const SipExploreGoalGrid({Key? key}) : super(key: key);

  @override
  _SipExploreGoalGridState createState() => _SipExploreGoalGridState();
}

class _SipExploreGoalGridState extends State<SipExploreGoalGrid> {
  final List<ExploreGoal> predefinedGoals = [
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

  List<ExploreGoal> customGoals = [];
  final ExploreGoal addCustomGoal = ExploreGoal(
    name: 'Add Custom Goal',
    icon: Icons.add,
    description: 'Create your own goal',
    color: Colors.teal,
    lottieAsset: null,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomGoals();
  }

  Future<void> _loadCustomGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? goalsJson = prefs.getString('custom_goals');
    if (goalsJson != null) {
      final List<dynamic> decoded = jsonDecode(goalsJson);
      setState(() {
        customGoals = decoded.map((item) => ExploreGoal.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveCustomGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String goalsJson = jsonEncode(customGoals.map((goal) => goal.toJson()).toList());
    await prefs.setString('custom_goals', goalsJson);
  }

  void _showAddGoalDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppColors.surfaceColor ?? const Color(0xFFF5F5F5),
        child: Container(
          padding: EdgeInsets.all(16.w),
          width: 300.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Custom Goal',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor ?? Colors.blue,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: nameController,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  labelStyle: TextStyle(
                    color: AppColors.secondaryText ?? Colors.grey,
                    fontSize: 12.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: AppColors.border ?? Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor ?? Colors.blue,
                      width: 2.w,
                    ),
                  ),
                ),
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: subtitleController,
                maxLength: 30,
                decoration: InputDecoration(
                  labelText: 'Subtitle',
                  labelStyle: TextStyle(
                    color: AppColors.secondaryText ?? Colors.grey,
                    fontSize: 12.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: AppColors.border ?? Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor ?? Colors.blue,
                      width: 2.w,
                    ),
                  ),
                ),
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.secondaryText ?? Colors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty && subtitleController.text.isNotEmpty) {
                        setState(() {
                          customGoals.add(ExploreGoal(
                            name: nameController.text,
                            description: subtitleController.text,
                            color: Colors.teal,
                            lottieAsset: 'assets/anim/sip_anim_1.json',
                          ));
                          _saveCustomGoals();
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor ?? Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: AppColors.buttonText ?? Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Combine and sort goals, keeping Add Custom Goal at the end
    final List<ExploreGoal> sortedGoals = [...predefinedGoals, ...customGoals]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final List<ExploreGoal> allGoals = [...sortedGoals, addCustomGoal];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: allGoals.length,
      itemBuilder: (context, index) {
        ExploreGoal goal = allGoals[index];
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: GestureDetector(
                onTap: () {
                  if (goal.name == 'Add Custom Goal') {
                    _showAddGoalDialog(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SipGoalBasedFundScreen(goal: goal),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                      goal.lottieAsset != null
                          ? Lottie.asset(
                        goal.lottieAsset!,
                        height: 60.h,
                        width: 60.w,
                        fit: BoxFit.contain,
                      )
                          : Icon(
                        goal.icon,
                        size: 60.sp,
                        color: goal.color,
                      ),
                      SizedBox(height: 8.h),
                      Flexible(
                        child: Text(
                          goal.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor ?? Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Flexible(
                        child: Text(
                          goal.description,
                          style: TextStyle(
                            fontSize: 10.sp,
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