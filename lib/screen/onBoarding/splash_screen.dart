import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utills/constent/user_constant.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Load user data from SharedPreferences
    await UserConstants.loadUserData();

    // Navigate after 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Navigate based on auth token and verification status
      if (UserConstants.TOKEN == null || UserConstants.TOKEN!.isEmpty) {
        context.goNamed('onboarding');
      } else {
        context.goNamed('main');
        // if (UserConstants.IS_EMAIL_VERIFIED == false) {
        //   context.goNamed('email_verify');
        // } else if (UserConstants.IS_MOBILE_VERIFIED == false) {
        //   context.goNamed('mobile_verify');
        // } else {
        //   context.goNamed('main');
        // }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light mode background color
      body: Center(
        child: TweenAnimationBuilder(
          duration: const Duration(seconds: 3),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(scale: value, child: child),
            );
          },
          child: Image.asset(
            'assets/logo/logo.jpg', // Make sure this image looks good on white
            width: 160,
          ),
        ),
      ),
    );
  }
}