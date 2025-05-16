// auth_service.dart

import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:http/http.dart' as http;

import '../../utills/constent/user_constant.dart';

class AuthService {

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    final url = Uri.parse('${AppConstant.API_URL}/auth/signup');

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
    final url  = Uri.parse('${AppConstant.API_URL}/auth/login');
    final body = <String, String>{ 'password': password };
    if (email?.isNotEmpty == true) {
      body['email'] = email!;
    } else if (mobile?.isNotEmpty == true) {
      body['mobile'] = mobile!;
    }

    final response = await http.post(
      url,
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body,
    );

    final jsonResp = jsonDecode(response.body) as Map<String, dynamic>;
    final data     = jsonResp['data'] as Map<String, dynamic>?;

    print(response.body);
    print(response.statusCode);
    // Persist only if login successful
    if ((jsonResp['status'] as bool? ?? false) && data != null) {
      await UserConstants.storeUserData(data);
    }

    return {
      'statusCode': response.statusCode,
      'status':     jsonResp['status']  ?? false,
      'message':    jsonResp['message'] ?? 'Unknown error',
      'data':       data,
    };
  }



  static Future<Map<String, dynamic>> sendOtp({
    String? mobile,
    String? email,
  }) async {
    final uri = Uri.parse('${AppConstant.API_URL}/auth/send/otp');
    final response = await http.post(
      uri,
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: {
        if (mobile != null) 'mobile': mobile,
        if (email  != null) 'email':  email,
      },
    );
    print(response.statusCode);
    print(response.body);
    final jsonBody = json.decode(response.body) as Map<String, dynamic>;

    // Always return the decoded JSON, regardless of status code.
    // jsonBody['status'] is your boolean, jsonBody['message'] is your server message.
    return {
      'statusCode': response.statusCode,
      'status':     jsonBody['status']  ?? false,
      'message':    jsonBody['message'] ?? 'Unknown error',
      'data':       jsonBody['data'],
    };
  }


  static Future<Map<String, dynamic>> verifyOtp({
    String? mobile,
    String? email,
    required String code,
  }) async {
    final uri = Uri.parse('${AppConstant.API_URL}/auth/verify/otp');
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        if (mobile != null) 'mobile': mobile,
        if (email  != null) 'email':  email,
        'code': code,
      },
    );

    print(response.statusCode);
    print(response.body);
    // Decode the body regardless of status code
    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    return {
      'statusCode': response.statusCode,
      'status':     jsonBody['status']  ?? false,
      'message':    jsonBody['message'] ?? 'Unknown error',
      'data':       jsonBody['data'],
    };
  }


  static Future<Map<String, dynamic>> forgotPasswordSendOtp(String mobile) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/auth/forgot/password/send/otp'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'mobile': mobile},
    );
    print(response.statusCode);
    print(response.body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> forgotPasswordVerifyOtp(String mobile, String code) async {
    final response = await http.patch(
      Uri.parse('${AppConstant.API_URL}/auth/forgot/password/verify/otp'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'mobile': mobile, 'code': code},
    );
    print(response.statusCode);
    print(response.body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    final response = await http.patch(
      Uri.parse('${AppConstant.API_URL}/auth/reset/password'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: {'password': password},
    );
    print(response.statusCode);
    print(response.body);
    return jsonDecode(response.body);
  }







}
