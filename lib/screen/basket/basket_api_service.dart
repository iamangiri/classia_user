import 'dart:convert';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'basket_model.dart';

class BasketApiService {
  static const String _baseUrl = 'https://nodeapi.classiacapital.com/basket';
  static const String _tokenKey = 'bajaj_auth_token';

  // Get Bajaj access token from SharedPreferences
  static Future<String?> _getBajajAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting Bajaj access token: $e');
      return null;
    }
  }

  // Fetch all baskets
  Future<List<Basket>> fetchBaskets({
    int page = 1,
    int sizePerPage = 10,
  }) async {
    final uri = Uri.parse('$_baseUrl/list').replace(queryParameters: {
      'page': page.toString(),
      'sizePerPage': sizePerPage.toString(),
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': '${UserConstants.TOKEN}'},
    );

    print('Fetch Baskets Response: ${response.body}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final basketResp = BasketResponse.fromJson(json);
      return basketResp.data.basketList;
    } else {
      throw Exception('Failed to load baskets: ${response.statusCode}');
    }
  }

  // Fetch single basket by ID with accessToken
  Future<Basket> fetchBasketById(int basketId) async {
    final bajajToken = await _getBajajAccessToken();

    if (bajajToken == null) {
      throw Exception('Bajaj access token not found. Please login to Bajaj.');
    }

    final uri = Uri.parse('$_baseUrl/list').replace(queryParameters: {
      'id': basketId.toString(),
      'accessToken': bajajToken,
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': '${UserConstants.TOKEN}'},
    );

    print('Fetch Basket By ID Response: ${response.body}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final basketResp = BasketResponse.fromJson(json);

      if (basketResp.data.basketList.isEmpty) {
        throw Exception('Basket not found');
      }

      return basketResp.data.basketList.first;
    } else {
      throw Exception('Failed to load basket: ${response.statusCode}');
    }
  }
}