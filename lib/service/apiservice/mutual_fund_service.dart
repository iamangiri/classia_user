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
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  // Mock method to fetch fund name based on rtaAmcCode and rtaSchCode
  // Mock implementation of getFundName (replace with actual API call if available)
  static Future<String> getFundName(String rtaAmcCode, String rtaSchCode) async {
    // Simulate API call or lookup (replace with actual implementation)
    final mockFundNames = {
      'AXF_SCGPG': 'Axis Small Cap Fund',
      'AXF_GOGPG': 'Axis Gold Fund',
      'AXF_MCGPG': 'Axis Midcap Fund',
      'AXF_TPGPG': 'Axis Multi Asset Allocation Fund',
      'AXF_EFGPG': 'Axis Large Cap Fund',
      'AXF_CFGPG': 'Axis Liquid Fund',
      'B_295G': 'Aditya Birla Sun Life Small Cap Fund',
      'B_251G': 'Aditya Birla Sun Life Midcap Fund',
      '166_IBGPG': 'quant Small Cap Fund',
      'FTI_010': 'Franklin India Bluechip Fund', // Retained from original map
    };
    final cacheKey = '${rtaAmcCode}_${rtaSchCode}';
    return mockFundNames[cacheKey] ?? 'Unknown Fund ($rtaAmcCode $rtaSchCode)';
  }

  static Future<Map<String, dynamic>> purchaseLumpsum({
    required double totAmt,
    required String rtaAmcCode,
    required String rtaSchCode,
    required String folio,
    String divOpt = 'N',
  }) async {
    final url = Uri.parse('${AppConstant.NODE_API_URL}/payez/purchase');
    final body = json.encode({
      'totAmt': totAmt,
      'schList': [
        {
          'rtaAmcCode': rtaAmcCode,
          'rtaSchCode': rtaSchCode,
          'folio': 'NEW',
          'divOpt': divOpt,
          'vol': totAmt,
        }
      ],
      'paySec': {
        'payMode': 'UP', // Fixed to UPI as per requirement
      },
    });
    print(body);
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': "${UserConstants.TOKEN}",
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to process lumpsum purchase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error processing lumpsum purchase: $e');
    }
  }

  static Future<Map<String, dynamic>> registerSip({
    required double totAmt,
    required String rtaAmcCode,
    required String rtaSchCode,
    required String folio,
    String divOpt = 'N',
    required String frequency, // 'M' or 'D'
    required int day,
    required int startMonth,
    required int startYear,
    required int endMonth,
    required int endYear,
  }) async {
    final url = Uri.parse('${AppConstant.NODE_API_URL}/payez/sip');
    final body = json.encode({
      'totAmt': totAmt,
      'sysSchList': [
        {
          'rtaAmcCode': rtaAmcCode,
          'rtaSchCode': rtaSchCode,
          'folio': 'NEW',
          'divOpt': divOpt,
          'vol': totAmt,
          'frequency': frequency, // 'M' for Monthly or 'D' for Daily
          'day': day,
          'startMonth': startMonth,
          'startYear': startYear,
          'endMonth': endMonth,
          'endYear': endYear,
        }
      ],
      'paySecFlag': 'N',
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': "${UserConstants.TOKEN}",
          'Content-Type': 'application/json',
        },
        body: body,
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to register SIP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error registering SIP: $e');
    }
  }
}