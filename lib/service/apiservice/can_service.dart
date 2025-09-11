// import 'dart:convert';
// import 'package:classia_amc/utills/constent/app_constant.dart';
// import 'package:classia_amc/utills/constent/user_constant.dart';
// import 'package:http/http.dart' as http;
//
// import '../WithoutLogin/auth_login_check_service.dart';
//
//
// class CamService {
//
//   CamService();
//
//   Future<dynamic> createCams(Map<String, dynamic> payload) async {
//     print(payload);
//     final response = await http.post(
//       Uri.parse('${AppConstant.NODE_API_URL}/can/create'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': '${UserConstants.TOKEN}',
//       },
//
//       body: jsonEncode(payload),
//     );
//
//      print('can api response');
//      print(response.body);
//      print(response.statusCode);
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to create CAMS: ${response.body}');
//     }
//   }
//
//
//
//
//   Future<Map<String, dynamic>> registerPayZee(Map<String, dynamic> payload) async {
//     try {
//       const String url = '${AppConstant.API_URL}/payez/register';
//
//       // Get the authorization token (you may need to modify this based on your token storage)
//
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': '${UserConstants.TOKEN}',
//         },
//         body: json.encode(payload),
//       );
//
//       print('PayZee Registration Request: ${json.encode(payload)}');
//       print('PayZee Registration Response Status: ${response.statusCode}');
//       print('PayZee Registration Response Body: ${response.body}');
//       await checkValidUserWithRouter(response.statusCode);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = json.decode(response.body);
//         return responseData;
//       } else if (response.statusCode == 400) {
//         final errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Invalid request data');
//       } else if (response.statusCode == 401) {
//         throw Exception('Unauthorized. Please check your authentication token.');
//       } else if (response.statusCode == 403) {
//         throw Exception('Access forbidden. You don\'t have permission to perform this action.');
//       } else if (response.statusCode == 404) {
//         throw Exception('Service not found. Please try again later.');
//       } else if (response.statusCode == 500) {
//         throw Exception('Server error. Please try again later.');
//       } else {
//         throw Exception('Failed to register PayZee account. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in PayZee Registration: $e');
//       if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
//         throw Exception('Network error. Please check your internet connection.');
//       } else if (e.toString().contains('FormatException')) {
//         throw Exception('Invalid response format from server.');
//       } else {
//         rethrow;
//       }
//     }
//   }
//
// }

import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;

class CamService {
  CamService();

  Future<dynamic> createCams(Map<String, dynamic> payload) async {
    print(payload);
    final response = await http.post(
      Uri.parse('${AppConstant.NODE_API_URL}/can/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '${UserConstants.TOKEN}',
      },
      body: jsonEncode(payload),
    );

    print('can api response');
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create CAMS: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCanStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.NODE_API_URL}/can/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${UserConstants.TOKEN}',
        },
      );

      print('CAN Status Response Status: ${response.statusCode}');
      print('CAN Status Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to retrieve CAN status: ${response.body}');
      }
    } catch (e) {
      print('Error in CAN Status: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid response format from server.');
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> registerPayZee(Map<String, dynamic> payload) async {
    try {
      const String url = '${AppConstant.NODE_API_URL}/payez/register';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${UserConstants.TOKEN}',
        },
        body: json.encode(payload),
      );

      print('PayZee Registration Request: ${json.encode(payload)}');
      print('PayZee Registration Response Status: ${response.statusCode}');
      print('PayZee Registration Response Body: ${response.body}');
      // Assuming checkValidUserWithRouter is defined elsewhere
      // await checkValidUserWithRouter(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid request data');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please check your authentication token.');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden. You don\'t have permission to perform this action.');
      } else if (response.statusCode == 404) {
        throw Exception('Service not found. Please try again later.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Failed to register PayZee account. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in PayZee Registration: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid response format from server.');
      } else {
        rethrow;
      }
    }
  }


  Future<Map<String, dynamic>> getPayZeeStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.NODE_API_URL}/payez/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${UserConstants.TOKEN}',
        },
      );

      print('PayZee Status Response Status: ${response.statusCode}');
      print('PayZee Status Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to retrieve PayZee status: ${response.body}');
      }
    } catch (e) {
      print('Error in PayZee Status: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid response format from server.');
      } else {
        rethrow;
      }
    }
  }

}