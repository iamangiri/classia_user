import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthFingerprintService {
  final LocalAuthentication _auth = LocalAuthentication();
  int _failedAttempts = 0;
  static const int maxAttempts = 3;
  bool _isLocked = false;
  DateTime? _lockEndTime;

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      print("Error checking biometrics: $e");
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print("Error getting available biometrics: $e");
      return [];
    }
  }

  // Authenticate user using fingerprint or PIN
  Future<bool> authenticate() async {
    try {
      // Check if lockout period has expired
      if (isLockedOut()) {
        print("Locked out. Try again in ${getRemainingLockTime()} seconds.");
        return false;
      }

      // Check if biometric authentication is available
      bool isBiometricAvailable = await this.isBiometricAvailable();

      // If no biometric authentication is available, return true to skip authentication
      if (!isBiometricAvailable) {
        print("Biometric authentication not available. Skipping authentication.");
        return true;
      }

      // Check if there are any biometric methods available
      List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        print("No biometric methods available. Skipping authentication.");
        return true;
      }

      bool authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow PIN, password, or pattern as a fallback
          useErrorDialogs: true, // Show default system error dialogs
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _failedAttempts = 0; // Reset failed attempts on success
        return true;
      } else {
        _failedAttempts++;
        if (_failedAttempts >= maxAttempts) {
          _isLocked = true;
          _lockEndTime = DateTime.now().add(const Duration(seconds: 30));
          print("Too many failed attempts. Try again in 30 seconds.");
        }
        return false;
      }
    } on PlatformException catch (e) {
      print("PlatformException during authentication: ${e.code} - ${e.message}");

      // Handle specific error codes
      switch (e.code) {
        case "LockedOut":
        case "PermanentlyLockedOut":
          _isLocked = true;
          _lockEndTime = DateTime.now().add(const Duration(seconds: 30));
          print("Too many failed attempts. Try again in 30 seconds.");
          return false;

        case "BiometricOnlyNotSupported":
        case "NotAvailable":
        case "NotEnrolled":
          print("Biometric authentication not available or not enrolled. Skipping authentication.");
          return true;

        case "UserCancel":
        case "SystemCancel":
          print("Authentication cancelled by user or system.");
          return false;

        default:
          print("Unknown authentication error. Skipping authentication.");
          return true; // Allow access for unknown errors to prevent blank screen
      }
    } catch (e) {
      print("Unexpected error during authentication: $e");
      // For any unexpected errors, allow access to prevent blank screen
      return true;
    }
  }

  // Check if authentication is currently locked
  bool isLockedOut() {
    if (_isLocked && _lockEndTime != null) {
      if (DateTime.now().isAfter(_lockEndTime!)) {
        _isLocked = false;
        _failedAttempts = 0; // Reset failed attempts
        return false;
      }
      return true;
    }
    return false;
  }

  // Get remaining lockout time in seconds
  int getRemainingLockTime() {
    if (_lockEndTime == null) return 0;
    int remainingTime = _lockEndTime!.difference(DateTime.now()).inSeconds;
    return remainingTime > 0 ? remainingTime : 0;
  }

  // Reset authentication state
  void resetAuthState() {
    _isLocked = false;
    _failedAttempts = 0;
    _lockEndTime = null;
  }
}