import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:classia_amc/utills/constent/user_constant.dart';

class TradeService {
  // API Configuration
  static const String baseUrl = 'https://classiahealth.com';

  // Fetch mutual fund list from API
  Future<List<dynamic>> fetchAmcList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mutual-fund/list?page=1&sizePerPage=1000'),
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return data['data']['usersList'];
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

  // Get AMC logo URL based on name
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

  // Get default AMC data as fallback
  List<Map<String, dynamic>> getDefaultAmcData() {
    return [
      {
        "id": 1,
        "logo": "https://www.quantmutual.com/images/logo.png",
        "name": "Quant",
        "fundName": "Small Cap Fund",
        "value": 0,
      },
      {
        "id": 2,
        "logo": "https://www.nipponindiamf.com/assets/images/niam-logo.png",
        "name": "Nippon India",
        "fundName": "Small Cap Fund",
        "value": 0,
      },
      {
        "id": 3,
        "logo": "https://www.sbimf.com/images/default-source/default-album/sbi-mutual-fund-logo.png",
        "name": "SBI",
        "fundName": "Small Cap Fund",
        "value": 0,
      },
      {
        "id": 4,
        "logo": "https://www.icicipruamc.com/docs/default-source/default-document-library/icici-pru-logo.jpg",
        "name": "ICICI Prudential",
        "fundName": "Technology Fund",
        "value": 0,
      },
      {
        "id": 5,
        "logo": "https://upload.wikimedia.org/wikipedia/commons/7/70/HDFC_Bank_Logo.svg",
        "name": "HDFC",
        "fundName": "Mid-Cap Opportunities Fund",
        "value": 12.0,
      },
    ];
  }

  // Map filter to API performance field
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

  // Parse performance value and handle null
  double _parsePerformanceValue(String? value) {
    if (value == null || value.isEmpty) {
      return 0.0; // Default value for null
    }
    try {
      return double.parse(value.replaceAll('%', '')) ?? 12.0;
    } catch (e) {
      print('Error parsing performance value: $e');
      return 0.0; // Default value on error
    }
  }

  // Main method to load enriched AMC data
  Future<List<Map<String, dynamic>>> loadAmcData({required String filter, required bool isBuy}) async {
    try {
      final amcListData = await fetchAmcList();
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