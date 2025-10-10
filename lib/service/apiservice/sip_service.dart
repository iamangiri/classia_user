import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/screen/sip/sip_model.dart';

class SipService {
  static const String _sipEndpoint = '/payez/sip';

  Future<Map<String, dynamic>> registerSip({
    required double totalAmount,
    required List<Fund> funds,
    required Map<Fund, double> fundPercentages,
    required String frequency,
    required int endMonth,
    required int endYear,
  }) async {
    try {
      // ✅ Calculate start date with +7 days
      final today = DateTime.now();
      final startDate = today.add(const Duration(days: 7));

      final int startDay = startDate.day;
      final int startMonth = startDate.month;
      final int startYear = startDate.year;
      print(startDay);
      print(startMonth);
      print(startYear);
      // Prepare sysSchList for the API
      final sysSchList = funds.map((fund) {
        return {
          'rtaAmcCode': fund.fundCode,
          'rtaSchCode': fund.schemeCode,
          'folio': 'NEW',
          'divOpt': 'N',
          'vol': (totalAmount * (fundPercentages[fund]! / 100)).toDouble(),
          'frequency': frequency == 'daily' ? 'D' : 'M',
          'day': startDay,
          'startMonth': startMonth,
          'startYear': startYear,
          // 'day': 10,
          // 'startMonth': 11,
          // 'startYear': 2025,
          'endMonth': endMonth,
          'endYear': endYear,
        };
      }).toList();

      // Prepare request body
      final body = {
        'totAmt': totalAmount,
        'sysSchList': sysSchList,
        'paySecFlag': 'N',
      };

      // Make API call
      final response = await http.post(
        Uri.parse(AppConstant.NODE_API_URL + _sipEndpoint),
        headers: {
          'Authorization': '${UserConstants.TOKEN}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to register SIP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error registering SIP: $e');
    }
  }
}
