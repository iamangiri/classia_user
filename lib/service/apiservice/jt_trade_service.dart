import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import '../WithoutLogin/auth_login_check_service.dart';

class JtTradeService {
  // Fetches the mutual fund list from the API
  Future<List<dynamic>> fetchAmcList() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.NODE_API_URL}/mutual-fund/list?page=1&sizePerPage=50&isProd=true'),
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
          'Content-Type': 'application/json',
        },
      );
      print('fetchAmcList response: ${response.statusCode}');
      print('fetchAmcList body: ${response.body}');
      await checkValidUserWithRouter(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return data['data']['mfList'] ?? [];
        } else {
          throw Exception('API returned error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load mutual fund list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchAmcList: $e');
      throw Exception('Network error: $e');
    }
  }

  // Processes a lumpsum purchase request
  Future<Map<String, dynamic>> purchaseLumpsum({
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
          'folio': folio,
          'divOpt': divOpt,
          'vol': totAmt,
        }
      ],
      'paySec': {
        'payMode': 'UP', // Fixed to UPI
      },
    });

    try {
      print('purchaseLumpsum request: $body');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      print('purchaseLumpsum response: ${response.statusCode}');
      print('purchaseLumpsum body: ${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to process lumpsum purchase: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in purchaseLumpsum: $e');
      throw Exception('Error processing lumpsum purchase: $e');
    }
  }

  // Maps AMC name to logo URL
  String getAmcLogo(String amcName) {
    final logoMap = {
      'HDFC Asset Management Company': 'https://assets-netstorage.groww.in/mf-assets/logos/hdfc_groww.png',
      'ICICI Prudential AMC Ltd': 'https://assets-netstorage.groww.in/mf-assets/logos/icici_groww.png',
      'quant Mutual Fund': 'https://assets-netstorage.groww.in/mf-assets/logos/quant_groww.png',
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
    return logoMap[amcName] ?? 'https://via.placeholder.com/150';
  }

  // Returns default AMC data if API fails
  List<Map<String, dynamic>> getDefaultAmcData() {
    return [];
  }

  // Maps filter to the corresponding performance field
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
        return 'threeYearsChange'; // Changed default to 3 years
    }
  }

  // Parses performance value, handling null, infinity, NaN or invalid cases
  double _parsePerformanceValue(String? value) {
    if (value == null || value.isEmpty) {
      return 0.0;
    }
    try {
      // Remove % sign and trim whitespace
      String cleanValue = value.replaceAll('%', '').trim();

      // Handle special string cases
      if (cleanValue.toLowerCase() == 'infinity' ||
          cleanValue.toLowerCase() == 'inf' ||
          cleanValue.toLowerCase() == 'nan') {
        print('Warning: Invalid performance value detected: $value');
        return 0.0;
      }

      double parsedValue = double.parse(cleanValue);

      // Check for infinity, NaN, or unreasonably large values
      if (parsedValue.isInfinite) {
        print('Warning: Infinity value detected, converting to 0: $value');
        return 0.0;
      }

      if (parsedValue.isNaN) {
        print('Warning: NaN value detected, converting to 0: $value');
        return 0.0;
      }

      // Optional: Cap extremely large values (e.g., > 10000%)
      if (parsedValue.abs() > 10000) {
        print('Warning: Extremely large value detected (${parsedValue}%), capping to reasonable range');
        return parsedValue > 0 ? 10000.0 : -10000.0;
      }

      return parsedValue;
    } catch (e) {
      print('Error parsing performance value "$value": $e');
      return 0.0;
    }
  }

  // Maps catgId to category name
  String _getCategoryName(int? catgId) {
    switch (catgId) {
      case 1:
        return 'Equity';
      case 2:
        return 'Gold';
      case 3:
        return 'Liquid';
      case 4:
        return 'Hybrid';
      default:
        return 'Other';
    }
  }

  // Loads and enriches AMC data for display
  Future<List<Map<String, dynamic>>> loadAmcData({required String filter, required bool isBuy}) async {
    try {
      final amcListData = await fetchAmcList();
      if (amcListData.isEmpty) {
        throw Exception('No AMC data received from API');
      }
      final performanceField = _getPerformanceField(filter);

      List<Map<String, dynamic>> enrichedAmcList = amcListData.map((amc) {
        final prodMfData = amc['prodMfData'] ?? {};

        // Parse and validate performance value
        double performanceValue = _parsePerformanceValue(amc[performanceField]);

        return {
          'id': amc['id'],
          'logo': getAmcLogo(amc['amc'] ?? 'Unknown'),
          'name': amc['amc'] ?? 'Unknown AMC',
          'amc': amc['amc'] ?? 'Unknown AMC',
          'fundName': amc['scheamName'] ?? 'Unknown Fund',
          'scheamName': amc['scheamName'] ?? 'Unknown Fund',
          'value': performanceValue, // Already validated and sanitized
          'scheamCode': amc['scheamCode'],
          'isDeleted': amc['isDeleted'] ?? false,
          'createdAt': amc['createdAt'],
          'updatedAt': amc['updatedAt'],
          'deletedAt': amc['deletedAt'],
          // Fields for JtTradeDeatilsScreen
          'fundCode': prodMfData['fundCode'] ?? null,
          'schemeCode': prodMfData['schemeCode'] ?? null,
          'nav': amc['nav']?.toString() ?? prodMfData['nav']?.toString() ?? '0.00',
          'expenseRatio': prodMfData['expenseRatio']?.toString() ?? '1.5%',
          'exitLoad': prodMfData['exitLoad']?.toString() ?? 'Not Available',
          'planType': prodMfData['planType'] ?? 'Regular',
          'category': amc['category'] ?? _getCategoryName(prodMfData['catgId']),
          // Performance metrics - all validated
          'dayChange': amc['dayChange'] ?? '0.0%',
          'weekChange': amc['weekChange'] ?? '0.0%',
          'monthChange': amc['monthChange'] ?? '0.0%',
          'threeMonthsChange': amc['threeMonthsChange'] ?? '0.0%',
          'sixMonthChange': amc['sixMonthChange'] ?? '0.0%',
          'oneYearChange': amc['oneYearChange'] ?? '0.0%',
          'threeYearsChange': amc['threeYearsChange'] ?? '0.0%',
          'fiveYearsChange': amc['fiveYearsChange'] ?? '0.0%',
          'allTime': amc['allTime'] ?? '0.0%',
          // Additional data
          'holdings': amc['holdings'],
          'fundManagers': amc['fundManagers'],
          'analysis': amc['analysis'],
          'prodMfData': prodMfData,
        };
      }).toList();

      // Filter out entries with missing fundCode or schemeCode for buy scenarios
      if (isBuy) {
        enrichedAmcList = enrichedAmcList
            .where((amc) => amc['fundCode'] != null && amc['schemeCode'] != null)
            .toList();
      }

      // Sort by performance value in descending order
      enrichedAmcList.sort((a, b) {
        double aValue = a['value'] ?? 0.0;
        double bValue = b['value'] ?? 0.0;

        // Ensure no infinity or NaN in sorting
        if (aValue.isInfinite || aValue.isNaN) aValue = 0.0;
        if (bValue.isInfinite || bValue.isNaN) bValue = 0.0;

        return bValue.compareTo(aValue);
      });

      print('Processed ${enrichedAmcList.length} funds for filter: $filter');

      // Debug: Print first fund's data
      if (enrichedAmcList.isNotEmpty) {
        print('Sample fund data:');
        print('Fund: ${enrichedAmcList[0]['fundName']}');
        print('Performance: ${enrichedAmcList[0]['value']}%');
        print('Holdings: ${enrichedAmcList[0]['holdings'] != null ? "Present" : "Missing"}');
        print('Fund Managers: ${enrichedAmcList[0]['fundManagers'] != null ? "Present" : "Missing"}');
      }

      return enrichedAmcList;
    } catch (e) {
      print('Error in loadAmcData: $e');
      throw Exception('Failed to load AMC data: $e');
    }
  }
}