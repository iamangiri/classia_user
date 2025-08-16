import 'dart:convert';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;


class CamService {

  CamService();

  Future<dynamic> createCams(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('https://classiahealth.com/can/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '${UserConstants.TOKEN}',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create CAMS: ${response.body}');
    }
  }
}