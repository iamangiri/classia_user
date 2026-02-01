import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BajajApiService {
  // Singleton instance
  static final BajajApiService _instance = BajajApiService._internal();
  factory BajajApiService() => _instance;
  BajajApiService._internal();

  // API Configuration
  static const String _baseUrl = 'https://bridgelink.bajajbroking.in/api';
  static const String _clientId = '54F97FA8-A45C-48FC-BC5A-F6A6AC81D1A7';
  static const String _clientSecret = 'T039SWyFe6BGyRyQoeVGOA==';
  static const String _redirectUri = 'https://classiacapital.com/'; // Must match OAuth URL

  // Storage Keys
  static const String _tokenKey = 'bajaj_auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryTimeKey = 'token_expiry_time';

  /// Exchange authorization code for access token
  Future<TokenResponse> exchangeCodeForToken(String code) async {
    try {
      debugPrint('=== Token Exchange Request ===');
      debugPrint('Code: $code');
      debugPrint('Client ID: $_clientId');

      final requestBody = {
        "grant_type": "authorization_code",
        "code": code,
        "client_id": _clientId,
        "client_secret": _clientSecret,
      };

      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('https://bridgelink.bajajbroking.in/api/user/token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('=== Token Exchange Response ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['statusCode'] == 0 && data['data'] != null) {
          final tokenData = data['data'];

          await _saveTokens(
            accessToken: tokenData['access_token'],
            refreshToken: tokenData['refresh_token'],
            expiresIn: tokenData['expires_in'],
          );

          debugPrint('✅ Token exchange successful');

          return TokenResponse.success(
            accessToken: tokenData['access_token'],
            refreshToken: tokenData['refresh_token'],
            expiresIn: tokenData['expires_in'],
          );
        } else {
          return TokenResponse.error(
            data['message'] ?? 'Login failed',
          );
        }
      } else {
        return TokenResponse.error(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      return TokenResponse.error('Network error: $e');
    }
  }




  /// Get current access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Check if token is valid (not expired)
  Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final expiryTime = prefs.getInt(_expiryTimeKey);

      if (token == null || expiryTime == null) {
        debugPrint('Token validation: No token or expiry time found');
        return false;
      }

      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final isValid = expiryTime > currentTime;

      if (isValid) {
        final remainingSeconds = expiryTime - currentTime;
        debugPrint('Token is valid. Expires in $remainingSeconds seconds');
      } else {
        debugPrint('Token has expired');
      }

      return isValid;
    } catch (e) {
      debugPrint('Error checking token validity: $e');
      return false;
    }
  }

  /// Get token info (remaining time, user ID, etc.)
  Future<TokenInfo?> getTokenInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final expiryTime = prefs.getInt(_expiryTimeKey);

      if (token == null || expiryTime == null) {
        return null;
      }

      // Decode JWT to get user info
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final data = jsonDecode(decoded);

        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final remainingSeconds = expiryTime - currentTime;

        return TokenInfo(
          accessToken: token,
          userId: data['userId'],
          expiryTime: expiryTime,
          remainingSeconds: remainingSeconds,
          isValid: remainingSeconds > 0,
        );
      }
    } catch (e) {
      debugPrint('Error getting token info: $e');
    }
    return null;
  }

  /// Clear all stored tokens and logout
  Future<void> bajallogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_expiryTimeKey);
      debugPrint('✅ User logged out successfully');
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
    }
  }

  /// Make authenticated API call
  Future<http.Response> makeAuthenticatedRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await getAccessToken();

    if (token == null) {
      throw Exception('No access token available');
    }

    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };

    final uri = Uri.parse('$_baseUrl/$endpoint');

    debugPrint('Making authenticated $method request to: $endpoint');

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: defaultHeaders);
      case 'POST':
        return await http.post(
          uri,
          headers: defaultHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          uri,
          headers: defaultHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(uri, headers: defaultHeaders);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  /// Private method to save tokens
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiryTime = currentTime + expiresIn;

    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(_expiryTimeKey, expiryTime);

    debugPrint('✅ Tokens saved successfully');
    debugPrint('   Access token length: ${accessToken.length}');
    debugPrint('   Expires in: $expiresIn seconds (${expiresIn ~/ 60} minutes)');
    debugPrint('   Expiry time: ${DateTime.fromMillisecondsSinceEpoch(expiryTime * 1000)}');
  }

  /// Get redirect URI (for consistency with OAuth flow)
  static String get redirectUri => _redirectUri;
}

/// Token Response Model
class TokenResponse {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? error;

  TokenResponse._({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.error,
  });

  factory TokenResponse.success({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) {
    return TokenResponse._(
      success: true,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );
  }

  factory TokenResponse.error(String error) {
    return TokenResponse._(
      success: false,
      error: error,
    );
  }
}

/// Token Info Model
class TokenInfo {
  final String accessToken;
  final String userId;
  final int expiryTime;
  final int remainingSeconds;
  final bool isValid;

  TokenInfo({
    required this.accessToken,
    required this.userId,
    required this.expiryTime,
    required this.remainingSeconds,
    required this.isValid,
  });

  String get formattedRemainingTime {
    if (remainingSeconds <= 0) return 'Expired';

    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes min';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }
}