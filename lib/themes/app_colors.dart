


import 'package:flutter/material.dart';

class AppColors {

AppColors._(); // Private constructor to prevent instantiation


  static const Color primaryColor = Colors.amber;
  static const Color primaryVariantColor = Color(0xFF3700B3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariantColor = Color(0xFF018786);
  static const Color backgroundColor = Color(0xFFF6F6F6);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFB00020);
  static const Color onPrimaryColor = Color(0xFFFFFFFF);
  static const Color onSecondaryColor = Color(0xFF000000);
  static const Color onBackgroundColor = Color(0xFF000000);
  static const Color onSurfaceColor = Color(0xFF000000);
  static const Color onErrorColor = Color(0xFFFFFFFF);

  // Primary theme color (Gold)
  //static const Color primaryGold = Color(0xFFd7b56d);
   static const Color primaryGold = 		Color(0xFF00004D)
;
  // Background colors
  static const Color screenBackground = Colors.white; // White background for the screen
  static const Color cardBackground = Color(0xFFE8F0FE); // Light blue for card background

  // Text colors
  static const Color primaryText = Color(0xFFd7b56d); // Dark gray for body text
  static const Color secondaryText = Color(0xFF666666); // Lighter gray for subtitles or secondary text
  static const Color headingText = Colors.white; // Near-black for headings

  // Border colors
  static const Color border = Color(0xFFE0E0E0); // Light gray for borders
  static const Color focusedBorder = primaryGold; // Gold for focused or highlighted borders

  // Accent and button colors
  static const Color accent =primaryGold ; // Royal blue as a complementary accent
  static const Color buttonBackground = primaryGold; // Gold for buttons
  static const Color buttonText = Colors.white; // White text on buttons

  // Success, Error, and Warning colors
  static const Color success = Color(0xFF28A745); // Green for success states
  static const Color error = Color(0xFFDC3545); // Red for error states
  static const Color warning = Color(0xFFFFC107); // Amber for warning states

  // Disabled state colors
  static const Color disabled = Color(0xFFB0B0B0); // Gray for disabled elements
  static const Color disabledText = Color(0xFF999999); // Lighter gray for disabled text
}
