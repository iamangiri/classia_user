import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:http/http.dart' as http;
import 'package:classia_amc/utills/constent/user_constant.dart';

import '../WithoutLogin/auth_login_check_service.dart';

class JtTradeService  {

  Future<List<dynamic>> fetchAmcList() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.NODE_API_URL}/mutual-fund/list?page=1&sizePerPage=10&isProd=true'),
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',  // Note: Added space after 'Bearer' (common issue if token is missing)
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      print(response.statusCode);
      await checkValidUserWithRouter(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          // Changed from 'usersList' to 'mfList' to match the API response
          return data['data']['mfList'] ?? [];  // Fallback to empty list if null
        } else {
          throw Exception('API returned error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load mutual fund list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String getAmcLogo(String amcName) {
    final logoMap = {
      'HDFC Asset Management Company': 'https://assets-netstorage.groww.in/mf-assets/logos/hdfc_groww.png',
      'ICICI Prudential AMC Ltd': 'https://assets-netstorage.groww.in/mf-assets/logos/icici_groww.png',
      'Quant Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/escorts_groww.png',
      'Aditya Birla Sun Life Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/birla_groww.png',
      'Axis Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/axis_groww.png',
      'Bandhan Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/idfc_groww.png',
      'ITI Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/iti_groww.png',
      'Invesco Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/invesco_groww.png',
      'Franklin Templeton Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/franklin_groww.png',
      'Motilal Oswal AMC': 'https://assets-netstorage.groww.in/mf-assets/logos/motilal_groww.png',
      'UTI Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/uti_groww.png',
      'Groww Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/groww_groww.png',
    };

    return logoMap[amcName] ?? 'https://www.quantmutual.com/images/logo.png';
  }

  List<Map<String, dynamic>> getDefaultAmcData() {
    return [

    ];
  }

  String _getPerformanceField(String filter) {
    switch (filter) {
      case 'Live':
        return 'dayChange';
      case 'Last 7 Days':
        return 'weekChange';
      case '1 Month':
        return 'monthChange';
      case '3 Months':
        return 'threeMonthsChange';
      case '6 Months':
        return 'sixMonthChange';
      case '1 Year':
        return 'oneYearChange';
      case '3 Years':
        return 'threeYearsChange';
      case '5 Years':
        return 'fiveYearsChange';
      case 'All':
        return 'allTime';
      default:
        return 'dayChange';
    }
  }

  double _parsePerformanceValue(String? value) {
    if (value == null || value.isEmpty) {
      return 0.0; // Return 0 instead of 12.0 for consistency with UI requirement
    }
    try {
      // Remove '%' and parse as double
      double parsedValue = double.parse(value.replaceAll('%', ''));
      return parsedValue.isNaN ? 0.0 : parsedValue;
    } catch (e) {
      print('Error parsing performance value: $e');
      return 0.0; // Return 0 on error to prevent NaN
    }
  }

  Future<List<Map<String, dynamic>>> loadAmcData({required String filter, required bool isBuy}) async {
    try {
      final amcListData = await fetchAmcList();
      if (amcListData == null || amcListData.isEmpty) {
        throw Exception('No AMC data received from API');
      }
      final performanceField = _getPerformanceField(filter);

      List<Map<String, dynamic>> enrichedAmcList = amcListData.map((amc) {
        return {
          'id': amc['id'],
          'logo': getAmcLogo(amc['amc']),
          'name': amc['amc'],
          'fundName': amc['scheamName'],
          'value': _parsePerformanceValue(amc[performanceField]),
          'scheamCode': amc['scheamCode'],
          'isDeleted': amc['isDeleted'],
          'createdAt': amc['createdAt'],
          'updatedAt': amc['updatedAt'],
          'deletedAt': amc['deletedAt'],
        };
      }).toList();

      enrichedAmcList.sort((a, b) => b['value'].compareTo(a['value']));
      return enrichedAmcList;
    } catch (e) {
      print('Error in TradeService.loadAmcData: $e');
      final defaultData = getDefaultAmcData();
      defaultData.sort((a, b) => b["value"].compareTo(a["value"]));
      return defaultData;
    }
  }
}