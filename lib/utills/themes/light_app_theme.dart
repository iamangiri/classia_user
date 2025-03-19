import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF0A1F3A), // Dark Blue
    hintColor: const Color(0xFFFFD700), // Golden
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: Color(0xFF0A1F3A),
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF0A1F3A),
      ),
    ),
  );
}