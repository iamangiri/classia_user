import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
// Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

// Navigate after 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
// Navigate based on authToken
      if (authToken == null || authToken.isEmpty) {
        context.go('/onboarding');
      } else {
        context.go('/main');
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
            'assets/images/logo.png', // Make sure this image looks good on white
            width: 160,
          ),
        ),
      ),
    );
  }
}
