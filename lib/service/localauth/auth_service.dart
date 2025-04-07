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

  // Authenticate user using fingerprint or PIN
  Future<bool> authenticate() async {
    // Check if lockout period has expired
    if (isLockedOut()) {
      print("Locked out. Try again in ${getRemainingLockTime()} seconds.");
      return false;
    }

    bool isBiometricAvailable = await this.isBiometricAvailable();
    try {
      bool authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: AuthenticationOptions(
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
          _lockEndTime = DateTime.now().add(Duration(seconds: 30));
          print("Too many failed attempts. Try again in 30 seconds.");
        }
        return false;
      }
    } on PlatformException catch (e) {
      if (e.code == "LockedOut") {
        _isLocked = true;
        _lockEndTime = DateTime.now().add(Duration(seconds: 30));
        print("Too many failed attempts. Try again in 30 seconds.");
      } else {
        print("Error during authentication: ${e.message}");
      }
      return false;
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
}