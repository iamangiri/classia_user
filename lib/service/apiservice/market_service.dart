
import 'dart:convert';

import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;

import '../WithoutLogin/auth_login_check_service.dart';

class MarketService {

  static Future<Map<String, dynamic>> getMutualFunds({int page = 1, int sizePerPage = 50}) async {
    final uri = Uri.parse('${AppConstant.NODE_API_URL}/mutual-fund/prod-list?page=$page&sizePerPage=$sizePerPage');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': "${UserConstants.TOKEN}",
        'Content-Type': 'application/json',
      },
    );
    print(response.body);
    print(response.statusCode);
    await checkValidUserWithRouter(response.statusCode);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load mutual funds: ${response.statusCode}');
    }
  }
}
