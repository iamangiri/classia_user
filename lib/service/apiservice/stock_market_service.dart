import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utills/constent/app_constant.dart';
import '../../utills/constent/user_constant.dart';


class MarketApiService {
  final String _base = AppConstant.NODE_API_URL;

  // Fetch all stocks with search support
  Future<List<Map<String, dynamic>>> fetchStocks({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final token = UserConstants.TOKEN;
    if (token == null) throw Exception('No auth token');

    // Build query parameters
    final queryParams = <String, String>{
      'page': page.toString(),
      'sizePerPage': limit.toString(),
    };

    // Add search parameter if provided
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse('$_base/basket/stocks-list')
        .replace(queryParameters: queryParams);

    final resp = await http.get(uri, headers: {'Authorization': token});

    if (resp.statusCode != 200) throw Exception('Failed to load stocks');

    final json = jsonDecode(resp.body);
    final stocksList = json['data']['stocksList'] as List<dynamic>?;

    if (stocksList == null) return [];

    return stocksList.map((item) => item as Map<String, dynamic>).toList();
  }

  // Fetch all baskets
  Future<Map<String, dynamic>> fetchBaskets() async {
    final token = UserConstants.TOKEN;
    if (token == null) throw Exception('No auth token');

    final uri = Uri.parse(
        '$_base/basket/admin-list?status=ACTIVE&page=1&sizePerPage=50');

    final resp = await http.get(uri, headers: {'Authorization': token});
    if (resp.statusCode != 200) throw Exception('Failed to load baskets');

    return jsonDecode(resp.body);
  }

  // Add stock to basket with correct parameter names
  Future<void> addStockToBasket({
    required int basketId,
    required int stockId,
    required String holdinPercentage,
    required String slPrice,
    required String tgtPrice,
    required String orderType,
    required String units,
    required String symbol,
    required int token,
  }) async {
    final authToken = UserConstants.TOKEN;
    if (authToken == null) throw Exception('No auth token');

    final resp = await http.post(
      Uri.parse('$_base/basket/add-stocks'),
      headers: {
        'Authorization': authToken,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'basketId': basketId.toString(),
        'stockId': stockId.toString(),
        'holdinPercentage': holdinPercentage,
        'slPrice': slPrice,
        'tgtPrice': tgtPrice,
        'orderType': orderType,
        'units': units,
        'symbol': symbol,
        'token': token.toString(),
      },
    );

    if (resp.statusCode != 200) {
      throw Exception('Add stock failed: ${resp.body}');
    }
  }

  // Remove stock from basket
  Future<void> removeStockFromBasket({
    required int basketId,
    required int stockId,
  }) async {
    final token = UserConstants.TOKEN;
    if (token == null) throw Exception('No auth token');

    final resp = await http.post(
      Uri.parse('$_base/basket/remove-stocks'),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'basketId': basketId.toString(),
        'stockId': stockId.toString(),
      },
    );

    if (resp.statusCode != 200) throw Exception('Remove stock failed');
  }
}