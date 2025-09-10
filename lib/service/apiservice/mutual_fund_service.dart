import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MutualFundService {

  static Future<Map<String, dynamic>> getTransactionList({int page = 1, int sizePerPage = 10}) async {
    final url = Uri.parse('${AppConstant.NODE_API_URL}/payez/transaction-list?page=$page&sizePerPage=$sizePerPage');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': "${UserConstants.TOKEN}",
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }
}