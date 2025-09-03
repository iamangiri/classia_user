import 'dart:convert';
import 'package:classia_amc/service/apiservice/api_service.dart';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;


class CamService {

  CamService();

  Future<dynamic> createCams(Map<String, dynamic> payload) async {
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




  Future<Map<String, dynamic>> registerPayZee(Map<String, dynamic> payload) async {
    try {
      const String url = '${AppConstant.API_URL}/payez/register';

      // Get the authorization token (you may need to modify this based on your token storage)

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

}