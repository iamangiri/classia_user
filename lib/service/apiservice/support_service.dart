import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../utills/constent/app_constant.dart';
import '../../utills/constent/user_constant.dart';
import '../WithoutLogin/auth_login_check_service.dart';


class SupportService {
  Future<bool> createSupportTicket({
    required String title,
    required String message,
    required String description,
    String priority = 'MEDIUM',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstant.API_URL}/support/create'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
        },
        body: {
          'title': title,
          'message': message,
          'description': description,
          'priority': priority,
        },
      );

      print(response.statusCode);
      print(response.body);
      await checkValidUserWithRouter(response.statusCode);
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

  Future<Map<String, dynamic>?> getSupportTicketList({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.API_URL}/support/list?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
        },
      );

      print(response.statusCode);
      print(response.body);
      await checkValidUserWithRouter(response.statusCode);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching tickets: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTicketDetails(int ticketId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.API_URL}/support/details/$ticketId'),
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
        },
      );

      print(response.statusCode);
      print(response.body);
      await checkValidUserWithRouter(response.statusCode);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching ticket details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> replyToTicket(int ticketId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstant.API_URL}/support/user-replay'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
        },
        body: {
          'ticketId': ticketId.toString(),
          'message': message,
        },
      );

      print(response.statusCode);
      print(response.body);
      await checkValidUserWithRouter(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error replying to ticket: $e');
      return null;
    }
  }

  Future<bool> closeTicket(int ticketId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstant.API_URL}/support/user-close-ticket'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
        },
        body: {
          'ticketId': ticketId.toString(),
          'message': message,
        },
      );
      await checkValidUserWithRouter(response.statusCode);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error closing ticket: $e');
      return false;
    }
  }
}