

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screen/auth/login_screen.dart';
import '../screen/auth/otp_verify_screen.dart';
import '../screen/base/main_screen.dart';
import '../screen/onBoarding/onBoarding_screen.dart';
import '../screen/onBoarding/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation:  '/' ,
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: OnBoardingScreen.routeName,
      name: 'onboarding',
      builder: (context, state) => OnBoardingScreen(onDone: () {}),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/otp_verify',
      name: 'otp_verify',
      builder: (context, state) {
        final contact = state.extra as String?; // Retrieve extra data safely
        return OTPScreen(contact: contact ?? '');
      },
    ),
    GoRoute(
      path: '/main',
      name: 'main',
      builder: (context, state) => MainScreen(),
    ),
  ],
);
