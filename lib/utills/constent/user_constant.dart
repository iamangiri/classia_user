import 'package:shared_preferences/shared_preferences.dart';

class UserConstants {
  //–– SharedPreferences KEYS ––//
  static const String AUTH_TOKEN_KEY        = 'authToken';
  static const String USER_ID_KEY           = 'userId';
  static const String NAME_KEY              = 'name';
  static const String EMAIL_KEY             = 'email';
  static const String PHONE_KEY             = 'phone';
  static const String PROFILE_IMAGE_KEY     = 'profileImage';
  static const String BANK_DETAILS_KEY      = 'bankDetails';
  static const String KYC_STATUS_KEY        = 'userKYC';
  static const String MOBILE_VERIFIED_KEY   = 'isMobileVerified';
  static const String EMAIL_VERIFIED_KEY    = 'isEmailVerified';
  static const String MAIN_BALANCE_KEY      = 'mainBalance';
  static const String PAN_NUMBER_KEY        = 'panNumber';
  static const String IS_AADHAAR_VERIFIED_KEY = 'isAadhaarVerified';
  static const String IS_PAN_VERIFIED_KEY   = 'isPanVerified';
  static const String ADDRESS_KEY           = 'address';
  static const String CITY_KEY              = 'city';
  static const String STATE_KEY             = 'state';
  static const String PIN_CODE_KEY          = 'pinCode';

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
  static String  PAN_NUMBER    = '';
  static bool?   IS_AADHAAR_VERIFIED;
  static bool?   IS_PAN_VERIFIED;
  static String  ADDRESS       = '';
  static String  CITY          = '';
  static String  STATE         = '';
  static String  PIN_CODE      = '';

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
    PAN_NUMBER          = prefs.getString(PAN_NUMBER_KEY)     ?? '';
    IS_AADHAAR_VERIFIED = prefs.getBool(IS_AADHAAR_VERIFIED_KEY);
    IS_PAN_VERIFIED     = prefs.getBool(IS_PAN_VERIFIED_KEY);
    ADDRESS             = prefs.getString(ADDRESS_KEY)        ?? '';
    CITY                = prefs.getString(CITY_KEY)           ?? '';
    STATE               = prefs.getString(STATE_KEY)          ?? '';
    PIN_CODE            = prefs.getString(PIN_CODE_KEY)       ?? '';
  }

  /// Persist the `{ "token": ..., "user": { ... } }` map into SharedPreferences
  /// and then mirror it into our in-memory fields.
  static Future<void> storeUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // top-level token
    await prefs.setString(AUTH_TOKEN_KEY, data['token'] as String);

    // nested user object
    final user = data['user'] as Map<String, dynamic>;
    await prefs.setString(USER_ID_KEY,            user['ID'].toString());
    await prefs.setString(NAME_KEY,               user['Name'] as String? ?? '');
    await prefs.setString(EMAIL_KEY,              user['Email'] as String? ?? '');
    await prefs.setString(PHONE_KEY,              user['Mobile'] as String? ?? '');
    await prefs.setString(PROFILE_IMAGE_KEY,      user['ProfileImage'] as String? ?? '');
    await prefs.setInt   (BANK_DETAILS_KEY,       user['BankDetails'] as int? ?? 0);
    await prefs.setInt   (KYC_STATUS_KEY,         user['UserKYC'] as int? ?? 0);
    await prefs.setBool  (MOBILE_VERIFIED_KEY,    user['IsMobileVerified'] as bool? ?? false);
    await prefs.setBool  (EMAIL_VERIFIED_KEY,     user['IsEmailVerified'] as bool? ?? false);
    await prefs.setDouble(MAIN_BALANCE_KEY,       (user['MainBalance'] as num?)?.toDouble() ?? 0.0);
    await prefs.setString(PAN_NUMBER_KEY,         user['PanNumber'] as String? ?? '');
    await prefs.setBool  (IS_AADHAAR_VERIFIED_KEY,user['IsAdharVerified'] as bool? ?? false);
    await prefs.setBool  (IS_PAN_VERIFIED_KEY,    user['IsPanVerified'] as bool? ?? false);
    await prefs.setString(ADDRESS_KEY,            user['Address'] as String? ?? '');
    await prefs.setString(CITY_KEY,               user['City'] as String? ?? '');
    await prefs.setString(STATE_KEY,              user['State'] as String? ?? '');
    await prefs.setString(PIN_CODE_KEY,           user['PinCode'] as String? ?? '');

    // finally, mirror into memory
    await loadUserData();
  }

  /// Clear all user data (useful for logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset in-memory variables
    TOKEN = null;
    USER_ID = null;
    NAME = '';
    EMAIL = '';
    PHONE = '';
    PROFILE_IMAGE = '';
    BANK_DETAILS = null;
    KYC_STATUS = null;
    IS_MOBILE_VERIFIED = null;
    IS_EMAIL_VERIFIED = null;
    MAIN_BALANCE = null;
    PAN_NUMBER = '';
    IS_AADHAAR_VERIFIED = null;
    IS_PAN_VERIFIED = null;
    ADDRESS = '';
    CITY = '';
    STATE = '';
    PIN_CODE = '';
  }

  /// Update a single field in SharedPreferences and memory
  static Future<void> updateField(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }

    // Reload to sync memory
    await loadUserData();
  }

  /// Check if user is logged in
  static bool get isLoggedIn => TOKEN != null && TOKEN!.isNotEmpty;

  /// Check if KYC is complete
  static bool get isKYCComplete =>
      (IS_AADHAAR_VERIFIED ?? false) && (IS_PAN_VERIFIED ?? false);

  /// Get formatted PAN number (XXXXX1234)
  static String get maskedPAN {
    if (PAN_NUMBER.isEmpty || PAN_NUMBER.length < 4) return '';
    return 'XXXXX${PAN_NUMBER.substring(PAN_NUMBER.length - 4)}';
  }

  /// Get user's full address
  static String get fullAddress {
    List<String> parts = [];
    if (ADDRESS.isNotEmpty) parts.add(ADDRESS);
    if (CITY.isNotEmpty) parts.add(CITY);
    if (STATE.isNotEmpty) parts.add(STATE);
    if (PIN_CODE.isNotEmpty) parts.add(PIN_CODE);
    return parts.join(', ');
  }
}