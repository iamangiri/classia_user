import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BajajApiService {
  static const String baseUrl = 'https://bridgelink.bajajbroking.in/api';

  // Store and retrieve auth token
  static Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('bajaj_auth_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  static Future<void> _saveAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bajaj_auth_token', token);
    } catch (e) {
      print('Error saving auth token: $e');
    }
  }

  // Get OrderBook API
  static Future<Map<String, dynamic>> getOrderBook() async {
    try {
      final token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        return {
          'statusCode': -1,
          'message': 'Authentication token not found',
          'data': null,
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reports/orderbook'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Bajaj OrderBook API Response Status: ${response.statusCode}');
      print('Bajaj OrderBook API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else if (response.statusCode == 401) {
        return {
          'statusCode': -1,
          'message': 'Unauthorized - Please login again',
          'data': null,
        };
      } else {
        return {
          'statusCode': -1,
          'message': 'Failed to load orderbook data. Status: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print('Error in getOrderBook: $e');
      return {
        'statusCode': -1,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Get TradeBook API
  static Future<Map<String, dynamic>> getTradeBook() async {
    try {
      final token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        return {
          'statusCode': -1,
          'message': 'Authentication token not found',
          'data': null,
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reports/tradebook'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Bajaj TradeBook API Response Status: ${response.statusCode}');
      print('Bajaj TradeBook API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else if (response.statusCode == 401) {
        return {
          'statusCode': -1,
          'message': 'Unauthorized - Please login again',
          'data': null,
        };
      } else {
        return {
          'statusCode': -1,
          'message': 'Failed to load tradebook data. Status: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print('Error in getTradeBook: $e');
      return {
        'statusCode': -1,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Get Funds API
  static Future<Map<String, dynamic>> getFunds() async {
    try {
      final token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        return {
          'statusCode': -1,
          'message': 'Authentication token not found',
          'data': null,
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reports/funds'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Bajaj Funds API Response Status: ${response.statusCode}');
      print('Bajaj Funds API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else if (response.statusCode == 401) {
        return {
          'statusCode': -1,
          'message': 'Unauthorized - Please login again',
          'data': null,
        };
      } else {
        return {
          'statusCode': -1,
          'message': 'Failed to load funds data. Status: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print('Error in getFunds: $e');
      return {
        'statusCode': -1,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Optional: Login method to get token
  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'password': password,
        }),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Bajaj Login API Response Status: ${response.statusCode}');
      print('Bajaj Login API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Save token if login successful
        if (jsonResponse['statusCode'] == 0 && jsonResponse['data'] != null) {
          final token = jsonResponse['data']['token'] ?? jsonResponse['data']['accessToken'];
          if (token != null) {
            await _saveAuthToken(token);
          }
        }

        return jsonResponse;
      } else {
        return {
          'statusCode': -1,
          'message': 'Login failed. Status: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print('Error in login: $e');
      return {
        'statusCode': -1,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Get Holdings API (if available)
  static Future<Map<String, dynamic>> getHoldings() async {
    try {
      final token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        return {
          'statusCode': -1,
          'message': 'Authentication token not found',
          'data': null,
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reports/holdings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Bajaj Holdings API Response Status: ${response.statusCode}');
      print('Bajaj Holdings API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else if (response.statusCode == 401) {
        return {
          'statusCode': -1,
          'message': 'Unauthorized - Please login again',
          'data': null,
        };
      } else {
        return {
          'statusCode': -1,
          'message': 'Failed to load holdings data. Status: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print('Error in getHoldings: $e');
      return {
        'statusCode': -1,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Get Positions API (if available)
  static Future<Map<String, dynamic>> getPositions() async {
    try {
      final token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        return {
          'statusCode': -1,
          'message': 'Authentication token not found',
          'data': null,
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reports/positions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Bajaj Positions API Response Status: ${response.statusCode}');
      print('Bajaj Positions API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else if (response.statusCode == 401) {
        return {
          'statusCode': -1,
          'message': 'Unauthorized - Please login again',
          'data': null,
        };
      } else {
        return {
          'statusCode': -1,
          'message': 'Failed to load positions data. Status: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print('Error in getPositions: $e');
      return {
        'statusCode': -1,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Place Order API
  static Future<Map<String, dynamic>> placeOrder({
    required String orderType,
    required int qty,
    required String exchange,
    required String buySell,
    required String orderTag,
    required String orderTypeValue,
    required String product,
    required String validity,
    required String symbol,
    double slPrice = 0,
    double limitPrice = 0,
    String amo = 'NO',
    int discQty = 0,
  }) async {
    try {
      final token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        return {
          'statusCode': -1,
          'message': 'Authentication token not found',
          'data': null,
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderType'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'qty': qty,
          'exchange': exchange,
          'buy_sell': buySell,
          'order_tag': orderTag,
          'order_type': orderTypeValue,
          'product': product,
          'validity': validity,
          'sl_price': slPrice,
          'limit_price': limitPrice,
          'amo': amo,
          'disc_qty': discQty,
          'symbol': symbol,
        }),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Bajaj Place Order API Response Status: ${response.statusCode}');
      print('Bajaj Place Order API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else if (response.statusCode == 401) {
        return {
          'statusCode': -1,
          'message': 'Unauthorized - Please login again',
          'data': null,
        };
      } else {
        return {
          'statusCode': -1,
          'message': 'Failed to place order. Status: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print('Error in placeOrder: $e');
      return {
        'statusCode': -1,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Manual token setter for testing or direct token input
  static Future<void> setAuthToken(String token) async {
    await _saveAuthToken(token);
  }
}