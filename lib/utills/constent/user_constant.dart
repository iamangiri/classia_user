// lib/constants/user_constants.dart

import 'package:shared_preferences/shared_preferences.dart';

class UserConstants {
  //–– SharedPreferences KEYS ––//
  static const String AUTH_TOKEN_KEY     = 'authToken';
  static const String USER_ID_KEY        = 'userId';
  static const String NAME_KEY           = 'name';
  static const String EMAIL_KEY          = 'email';
  static const String PHONE_KEY          = 'phone';
  static const String PROFILE_IMAGE_KEY  = 'profileImage';
  static const String BANK_DETAILS_KEY   = 'bankDetails';
  static const String KYC_STATUS_KEY     = 'userKYC';
  static const String MOBILE_VERIFIED_KEY= 'isMobileVerified';
  static const String EMAIL_VERIFIED_KEY = 'isEmailVerified';
  static const String MAIN_BALANCE_KEY   = 'mainBalance';

  //–– In-memory cache ––//
  static String? TOKEN;
  static String? USER_ID;
  static String  NAME          = '';
  static String  EMAIL         = '';
  static String  PHONE         = '';
  static String  PROFILE_IMAGE = '';
  static int?    BANK_DETAILS;
  static int?    KYC_STATUS;
  static bool?   IS_MOBILE_VERIFIED;
  static bool?   IS_EMAIL_VERIFIED;
  static num?    MAIN_BALANCE;

  /// Load everything from SharedPreferences into the static fields.
  static Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    TOKEN               = prefs.getString(AUTH_TOKEN_KEY);
    USER_ID             = prefs.getString(USER_ID_KEY);
    NAME                = prefs.getString(NAME_KEY)           ?? '';
    EMAIL               = prefs.getString(EMAIL_KEY)          ?? '';
    PHONE               = prefs.getString(PHONE_KEY)          ?? '';
    PROFILE_IMAGE       = prefs.getString(PROFILE_IMAGE_KEY)  ?? '';
    BANK_DETAILS        = prefs.getInt(BANK_DETAILS_KEY);
    KYC_STATUS          = prefs.getInt(KYC_STATUS_KEY);
    IS_MOBILE_VERIFIED  = prefs.getBool(MOBILE_VERIFIED_KEY);
    IS_EMAIL_VERIFIED   = prefs.getBool(EMAIL_VERIFIED_KEY);
    MAIN_BALANCE        = prefs.getDouble(MAIN_BALANCE_KEY)   ?? prefs.getInt(MAIN_BALANCE_KEY);
  }

  /// Persist the `{ "token": ..., "user": { ... } }` map into SharedPreferences
  /// and then mirror it into our in-memory fields.
  static Future<void> storeUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // top-level token
    await prefs.setString(AUTH_TOKEN_KEY, data['token'] as String);

    // nested user object
    final user = data['user'] as Map<String, dynamic>;
    await prefs.setString(USER_ID_KEY,        user['ID'].toString());
    await prefs.setString(NAME_KEY,           user['Name'] as String);
    await prefs.setString(EMAIL_KEY,          user['Email'] as String);
    await prefs.setString(PHONE_KEY,          user['Mobile'] as String);
    await prefs.setString(PROFILE_IMAGE_KEY,  user['ProfileImage'] as String);

    // non‐String fields
    await prefs.setInt   (BANK_DETAILS_KEY,   user['BankDetails'] as int);
    await prefs.setInt   (KYC_STATUS_KEY,     user['UserKYC']     as int);
    await prefs.setBool  (MOBILE_VERIFIED_KEY,user['IsMobileVerified'] as bool);
    await prefs.setBool  (EMAIL_VERIFIED_KEY, user['IsEmailVerified']  as bool);
    await prefs.setDouble(MAIN_BALANCE_KEY,   (user['MainBalance'] as num).toDouble());

    // finally, mirror into memory
    await loadUserData();
  }
}
