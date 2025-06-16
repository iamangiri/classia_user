import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../utills/constent/app_constant.dart';
import '../../utills/constent/user_constant.dart';

class SupportService {

  Future<bool> createSupportTicket(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstant.API_URL}/support/create'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
        },
        body: {
          'title': title,
          'description': description,
        },
      );

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error creating support ticket: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSupportTicketList({required int page, required int limit}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.API_URL}/support/list?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}