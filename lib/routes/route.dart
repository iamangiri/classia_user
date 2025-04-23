import 'package:classia_amc/screen/auth/moblie_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screen/auth/login_screen.dart';
import '../screen/auth/otp_verify_screen.dart';
import '../screen/auth/email_verification_screen.dart';   // ← import it
import '../screen/base/main_screen.dart';
import '../screen/onBoarding/onBoarding_screen.dart';
import '../screen/onBoarding/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
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
        final contact = state.extra as String?;
        return OTPScreen(contact: contact ?? '');
      },
    ),

    GoRoute(
      path: '/email_verify',         // ← new path
      name: 'email_verify',          // ← give it a name
      builder: (context, state) {
        final email = state.extra as String?;
        return EmailVerificationScreen(
          // optionally, you could add a constructor param to pre-fill:
          // initialEmail: email ?? '',
        );
      },
    ),


    GoRoute(
      path: '/mobile_verify',         // ← new path
      name: 'mobile_verify',          // ← give it a name
      builder: (context, state) {
        final email = state.extra as String?;
        return MobileVerificationScreen(
          // optionally, you could add a constructor param to pre-fill:
          // initialEmail: email ?? '',
        );
      },
    ),

    GoRoute(
      path: '/main',
      name: 'main',
      builder: (context, state) => MainScreen(),
    ),
  ],
);
