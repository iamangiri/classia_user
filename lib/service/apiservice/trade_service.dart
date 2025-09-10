import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:classia_amc/utills/constent/user_constant.dart';

import '../WithoutLogin/auth_login_check_service.dart';

class TradeService {
  static const String baseUrl = 'https://goapi.classiacapital.com';
  final Random _random = Random();

  Future<List<dynamic>> fetchAmcList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/amc/list?page=1&limit=10'),
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
          'Content-Type': 'application/json',
        },
      );
      await checkValidUserWithRouter(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return data['data']['users']; // Updated to match new API response structure
        } else {
          throw Exception('API returned error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load AMC list: ${response.statusCode}');
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

  /// Generates random performance value between 1.0 and 10.0
  double _generateRandomPerformance() {
    // Generate random double between 1.0 and 10.0
    return 1.0 + (_random.nextDouble() * 9.0);
  }

  /// Generates random projection value between 1.0 and 10.0
  double _generateRandomProjection() {
    // Generate random double between 1.0 and 10.0
    return 1.0 + (_random.nextDouble() * 9.0);
  }

  /// Generates random performance based on filter type with realistic ranges
  double _generateRandomPerformanceByFilter(String filter) {
    switch (filter) {
      case 'Live':
      // Daily changes are usually smaller: -2% to +3%
        return -2.0 + (_random.nextDouble() * 5.0);
      case 'Last 7 Days':
      // Weekly changes: -5% to +8%
        return -5.0 + (_random.nextDouble() * 13.0);
      case '1 Month':
      // Monthly changes: -8% to +12%
        return -8.0 + (_random.nextDouble() * 20.0);
      case '3 Months':
      // Quarterly changes: -15% to +25%
        return -15.0 + (_random.nextDouble() * 40.0);
      case '6 Months':
      // Half-yearly changes: -20% to +35%
        return -20.0 + (_random.nextDouble() * 55.0);
      case '1 Year':
      // Annual changes: -30% to +50%
        return -30.0 + (_random.nextDouble() * 80.0);
      case '3 Years':
      // 3-year changes: -20% to +80%
        return -20.0 + (_random.nextDouble() * 100.0);
      case '5 Years':
      // 5-year changes: 0% to +150%
        return _random.nextDouble() * 150.0;
      case 'All':
      // All-time changes: 0% to +300%
        return _random.nextDouble() * 300.0;
      default:
        return _generateRandomPerformance();
    }
  }

  /// Generates random projection based on filter type with realistic ranges
  /// Projections are typically more optimistic than current performance
  double _generateRandomProjectionByFilter(String filter) {
    switch (filter) {
      case 'Live':
      // Daily projections: 0% to +5%
        return _random.nextDouble() * 5.0;
      case 'Last 7 Days':
      // Weekly projections: 2% to +15%
        return 2.0 + (_random.nextDouble() * 13.0);
      case '1 Month':
      // Monthly projections: 5% to +20%
        return 5.0 + (_random.nextDouble() * 15.0);
      case '3 Months':
      // Quarterly projections: 8% to +35%
        return 8.0 + (_random.nextDouble() * 27.0);
      case '6 Months':
      // Half-yearly projections: 12% to +45%
        return 12.0 + (_random.nextDouble() * 33.0);
      case '1 Year':
      // Annual projections: 15% to +65%
        return 15.0 + (_random.nextDouble() * 50.0);
      case '3 Years':
      // 3-year projections: 25% to +120%
        return 25.0 + (_random.nextDouble() * 95.0);
      case '5 Years':
      // 5-year projections: 40% to +200%
        return 40.0 + (_random.nextDouble() * 160.0);
      case 'All':
      // All-time projections: 60% to +400%
        return 60.0 + (_random.nextDouble() * 340.0);
      default:
        return _generateRandomProjection();
    }
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
      return 0.0;
    }
    try {
      // Remove '%' and parse as double
      double parsedValue = double.parse(value.replaceAll('%', ''));
      return parsedValue.isNaN ? 0.0 : parsedValue;
    } catch (e) {
      print('Error parsing performance value: $e');
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> loadAmcData({required String filter, required bool isBuy}) async {
    try {
      final amcListData = await fetchAmcList();

      List<Map<String, dynamic>> enrichedAmcList = amcListData.map<Map<String, dynamic>>((amc) {
        return {
          'id': amc['ID'], // Updated field name from API response
          'logo': getAmcLogo(amc['Name']), // Updated field name
          'name': amc['Name'], // Updated field name
          'fundName': amc['FundName'], // Updated field name
          'value': _generateRandomPerformanceByFilter(filter), // Generate random performance
          'projection': _generateRandomProjectionByFilter(filter), // Generate random projection
          'email': amc['Email'],
          'mobile': amc['Mobile'],
          'role': amc['Role'],
          'panNumber': amc['PanNumber'],
          'address': amc['Address'],
          'city': amc['City'],
          'state': amc['State'],
          'pinCode': amc['PinCode'],
          'contactPersonName': amc['ContactPersonName'],
          'contactPerDesignation': amc['ContactPerDesignation'],
          'equityPer': amc['EquityPer'],
          'debtPer': amc['DebtPer'],
          'cashSplit': amc['CashSplit'],
          'isDeleted': amc['IsDeleted'],
          'createdAt': amc['CreatedAt'],
          'updatedAt': amc['UpdatedAt'],
          'deletedAt': amc['DeletedAt'],
        };
      }).toList();

      // Sort by performance value in descending order
      enrichedAmcList.sort((a, b) => b['value'].compareTo(a['value']));
      return enrichedAmcList;
    } catch (e) {
      print('Error in TradeService.loadAmcData: $e');
      final defaultData = getDefaultAmcData();
      defaultData.sort((a, b) => b["value"].compareTo(a["value"]));
      return defaultData;
    }
  }

  /// Optional: Method to refresh performance and projection values for existing data
  void refreshPerformanceValues(List<Map<String, dynamic>> amcList, String filter) {
    for (var amc in amcList) {
      amc['value'] = _generateRandomPerformanceByFilter(filter);
      amc['projection'] = _generateRandomProjectionByFilter(filter);
    }
    // Re-sort after updating values
    amcList.sort((a, b) => b['value'].compareTo(a['value']));
  }

  /// Optional: Method to refresh only projection values for existing data
  void refreshProjectionValues(List<Map<String, dynamic>> amcList, String filter) {
    for (var amc in amcList) {
      amc['projection'] = _generateRandomProjectionByFilter(filter);
    }
  }
}