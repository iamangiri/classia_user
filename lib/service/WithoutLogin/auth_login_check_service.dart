import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Add this import
import '../../routes/route.dart';
import '../../screen/auth/login_screen.dart';

// If you need UserPoints class, add it here
class UserPoints extends ChangeNotifier {
  int _points = 0;

  int get points => _points;

  void addPoints(int value) {
    _points += value;
    notifyListeners();
  }

  void setPoints(int value) {
    _points = value;
    notifyListeners();
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  // Add this method to get current context from GoRouter
  static BuildContext? getCurrentContext() {
    return navigatorKey.currentContext;
  }
}

Future<void> checkValidUser(BuildContext context, int statusCode) async {
  if (statusCode == 401) {
    // Show toast message
    Fluttertoast.showToast(
      msg: "We detected that your account is already logged in on another device. Please log in again.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      fontSize: 12.0,
    );

    // Clear user session
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Use GoRouter navigation instead
    if (context.mounted) {
      context.go('/login');
    }
  }
}

// Alternative method using router reference
Future<void> checkValidUserWithRouter(int statusCode) async {
  if (statusCode == 401) {
    // Show toast message
    Fluttertoast.showToast(
      msg: "We detected that your account is already logged in on another device. Please log in again.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      fontSize: 12.0,
    );

    // Clear user session
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Use the router directly
    router.go('/login');
  }
}