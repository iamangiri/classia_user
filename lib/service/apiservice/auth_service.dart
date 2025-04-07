// auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    final url = Uri.parse('https://api.classiacapital.com/auth/signup');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'name': name,
        'email': email,
        'mobile': mobile,
        'password': password,
      },
    );

    // Decode whatever the server returns (200, 201, 422, 409, etc.)
    final Map<String, dynamic> json = jsonDecode(response.body);
    print(response.body);
    print(response.statusCode);
    return {
      'statusCode': response.statusCode,
      'status':    json['status'] ?? false,
      'message':   json['message'] ?? 'Unknown error',
      'data':      json['data'],
    };
  }


  static Future<Map<String, dynamic>> loginUser({
    String? email,
    String? mobile,
    required String password,
  }) async {
    final url = Uri.parse('https://api.classiacapital.com/auth/login');
    final body = <String, String>{ 'password': password };

    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    } else if (mobile != null && mobile.isNotEmpty) {
      body['mobile'] = mobile;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'statusCode': response.statusCode,
      'status':     json['status']  ?? false,
      'message':    json['message'] ?? 'Unknown error',
      'data':       json['data'],
    };
  }

}
