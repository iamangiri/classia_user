import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/WithoutLogin/auth_login_check_service.dart';
import 'basket_model.dart';

class BasketApiService {
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

  // 🔥 Helper: Builds URI without accessToken query param
  Uri _buildUri(String path, Map<String, dynamic> params) {
    return Uri.parse("${AppConstant.API_URL}/basket/$path")
        .replace(queryParameters: params);
  }

  // ================================
  // 1️⃣ Fetch All Baskets
  // ================================
  Future<List<Basket>> fetchBaskets({
    int page = 1,
    int sizePerPage = 100, // kept arg name for compatibility, mapped to limit
  }) async {
    final uri = _buildUri("list", {
      "page": page.toString(),
      "limit": sizePerPage.toString(),
    });

    print("Fetch Baskets URL: $uri");

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${UserConstants.TOKEN}'},
    );

    print("Fetch Baskets Response: ${response.body}");
    print("Status Code: ${response.statusCode}");
    await checkValidUserWithRouter(response.statusCode);
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
    // Assuming /list supports filtering by id or there's no specific detail endpoint mentioned yet.
    // Preserving behavior of filtering list by ID.
    final uri = _buildUri("list", {
      "id": basketId.toString(),
    });

    print("Fetch Basket By ID URL: $uri");

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${UserConstants.TOKEN}'},
    );

    print("Fetch Basket By ID Response: ${response.body}");
    print("Status Code: ${response.statusCode}");
    await checkValidUserWithRouter(response.statusCode);
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
    // Updated endpoint to my-basket from my-basket
    final uri = _buildUri("my-subscriptions", {});

    print("Fetch My Baskets URL: $uri");

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${UserConstants.TOKEN}'},
    );

    print("Fetch My Baskets Response: ${response.body}");
    print("Status Code: ${response.statusCode}");
    await checkValidUserWithRouter(response.statusCode);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // The new API return structure is wrapped in data -> subscriptions
      // We rely on BasketResponse / BasketData to parse this
      if (json['data'] != null && json['data']['subscriptions'] != null) {
        return BasketResponse.fromJson(json).data.basketList;
      }

      // Fallback: if structure is different or direct list
      // existing code logic was: return dataList.map((i) => Basket.fromJson(i)).toList();
      // But now we use our updated model logic
      return BasketResponse.fromJson(json).data.basketList;
    } else {
      throw Exception("Failed to load my baskets: ${response.statusCode}");
    }
  }

  // ================================
  // 4️⃣ Fetch My Basket Subscriptions (NEW)
  // ================================
  Future<Map<String, dynamic>> fetchMyBasket() async {
    final uri = Uri.parse('${AppConstant.API_URL}/basket/my-basket');

    print("Fetch My Basket URL: $uri");

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${UserConstants.TOKEN}'},
    );

    print("Fetch My Basket Response: ${response.body}");
    print("Status Code: ${response.statusCode}");
    await checkValidUserWithRouter(response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load my basket: ${response.statusCode}");
    }
  }

  // ================================
  // Subscribe
  // ================================
  Future<Map<String, dynamic>> subscribeBasket(int basketId,
      {String period = "MONTHLY"}) async {
    // Updated endpoint to subscribe (was subscribe-basket)
    final uri = Uri.parse('${AppConstant.API_URL}/basket/subscribe');

    print("Subscribe URL: $uri");
    final payload = {"basketId": basketId, "period": period};
    print("Subscribe Payload: ${jsonEncode(payload)}");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${UserConstants.TOKEN}',
        'Content-Type': 'application/json', // Payload is JSON now
      },
      // Updated body to be JSON string
      body: jsonEncode(payload),
    );

    print("Subscribe Response: ${response.body}");
    return jsonDecode(response.body);
  }
}