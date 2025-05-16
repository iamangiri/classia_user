import 'package:classia_amc/screen/auth/moblie_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screen/auth/login_screen.dart';
import '../screen/auth/otp_verify_screen.dart';
import '../screen/auth/email_verification_screen.dart';   // ← import it
import '../screen/auth/registration_screen.dart';
import '../screen/base/main_screen.dart';
import '../screen/onBoarding/onBoarding_screen.dart';
import '../screen/onBoarding/splash_screen.dart';
import '../screenutills/horse_riding_screen.dart';

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
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => RegistrationScreen(),
    ),

    GoRoute(
      path: '/horse_riding',
      name: 'horse_riding',
      builder: (context, state) => HorseRidingScreen(),
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
      path: '/email_verify',
      name: 'email_verify',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;

        return EmailVerificationScreen(
          initialEmail: extra?['email'],
          initialPhone: extra?['phone'],
        );
      },
    ),


    GoRoute(
      path: '/mobile_verify',
      name: 'mobile_verify',
      builder: (context, state) {
        // state.extra is whatever you passed in extra: …
        final phone = state.extra as String?;
        return MobileVerificationScreen(
          initialPhone: phone,
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
