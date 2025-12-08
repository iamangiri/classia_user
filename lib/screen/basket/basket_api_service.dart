import 'dart:convert';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'basket_model.dart';

class BasketApiService {
  static const String _baseUrl = 'https://nodeapi.classiacapital.com/basket';
  static const String _tokenKey = 'bajaj_auth_token';

  // Get Bajaj access token
  static Future<String?> _getBajajAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting Bajaj access token: $e');
      return null;
    }
  }

  // 🔥 Helper: Builds URI with or without accessToken
  Future<Uri> _buildUri(String path, Map<String, dynamic> params) async {
    final token = await _getBajajAccessToken();

    if (token != null) {
      params['accessToken'] = token;
    } else {
      print("Bajaj access token not found → calling API without token");
    }

    return Uri.parse("$_baseUrl/$path").replace(queryParameters: params);
  }

  // ================================
  // 1️⃣ Fetch All Baskets
  // ================================
  Future<List<Basket>> fetchBaskets({
    int page = 1,
    int sizePerPage = 100,
  }) async {
    final uri = await _buildUri("list", {
      "page": page.toString(),
      "sizePerPage": sizePerPage.toString(),
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': '${UserConstants.TOKEN}'},
    );

    print("Fetch Baskets Response: ${response.body}");
    print("Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BasketResponse.fromJson(json).data.basketList;
    } else {
      throw Exception("Failed to load baskets: ${response.statusCode}");
    }
  }

  // ================================
  // 2️⃣ Fetch Basket By ID
  // ================================
  Future<Basket> fetchBasketById(int basketId) async {
    final uri = await _buildUri("list", {
      "id": basketId.toString(),
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': '${UserConstants.TOKEN}'},
    );

    print("Fetch Basket By ID Response: ${response.body}");
    print("Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final basketList = BasketResponse.fromJson(json).data.basketList;

      if (basketList.isEmpty) throw Exception("Basket not found");

      return basketList.first;
    } else {
      throw Exception("Failed to load basket: ${response.statusCode}");
    }
  }

  // ================================
  // 3️⃣ Fetch My Subscribed Baskets
  // ================================
  Future<List<Basket>> fetchMyBaskets() async {
    final uri = await _buildUri("my-basket", {});

    final response = await http.get(
      uri,
      headers: {'Authorization': '${UserConstants.TOKEN}'},
    );

    print("Fetch My Baskets Response: ${response.body}");
    print("Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> dataList = json['data'];
      return dataList.map((i) => Basket.fromJson(i)).toList();
    } else {
      throw Exception("Failed to load my baskets: ${response.statusCode}");
    }
  }

  // ================================
  // Subscribe
  // ================================
  Future<Map<String, dynamic>> subscribeBasket(int basketId) async {
    final uri = Uri.parse('$_baseUrl/subscribe-basket');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': '${UserConstants.TOKEN}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {"basketId": basketId.toString()},
    );

    print("Subscribe Response: ${response.body}");

    return jsonDecode(response.body);
  }

  // ================================
  // Unsubscribe
  // ================================
  Future<Map<String, dynamic>> unsubscribeBasket(int basketId) async {
    final uri = Uri.parse('$_baseUrl/unsubscribe-basket');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': '${UserConstants.TOKEN}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {"basketId": basketId.toString()},
    );

    print("Unsubscribe Response: ${response.body}");

    return jsonDecode(response.body);
  }
}
