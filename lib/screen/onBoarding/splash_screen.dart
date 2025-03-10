import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onBoarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      // Use GoRouter's context.go() to navigate to the OnBoardingScreen
      context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: TweenAnimationBuilder(
          duration: Duration(seconds: 1),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(scale: value, child: child),
            );
          },
          child: Image.asset(
            'assets/images/splash-2.png', // Ensure this matches your asset path
            width: 150, // Adjust size if needed
          ),
        ),
      ),
    );
  }
}
