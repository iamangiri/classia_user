import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/mutual_fund_models.dart';


class ApiService {
  static const String _baseUrl = 'https://classiahealth.com';
  static const String _mutualFundEndpoint =
      '/mutual-fund/list?page=1&sizePerPage=100';

  Future<MutualFundResponse> fetchMutualFunds() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl + _mutualFundEndpoint),
        headers: {
          'Authorization': '', // Add your token here if required
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return MutualFundResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load mutual funds: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching mutual funds: $e');
    }
  }
}