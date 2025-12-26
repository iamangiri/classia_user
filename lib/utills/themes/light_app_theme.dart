import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryDarkBlue = Color(0xFF0A1F3A);
  static const Color primaryGold = Color(0xFFDAA520);

  // Background Colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF0A1F3A);
  static const Color textSecondary = Color(0xFF6B7280);

  // Action Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);

  // Theme Data
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryDarkBlue,
    hintColor: primaryGold,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: primaryDarkBlue,
      ),
      bodyLarge: TextStyle(
        color: primaryDarkBlue,
      ),
    ),
  );
}