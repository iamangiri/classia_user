import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:classia_amc/utills/constent/user_constant.dart';

class TradeService {
  // API Configuration
  static const String baseUrl = 'https://api.classiacapital.com';

  // Fetch AMC list from API
  Future<List<dynamic>> fetchAmcList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/amc/list?page=1&limit=50'),
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return data['data']['users'];
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

  // Fetch AMC performance data
  Future<double> fetchAmcPerformance(int amcId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/amc/performance?amcId=$amcId'),
        headers: {
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          // Parse the averagePercentChange string (e.g., "-0.69%")
          String percentStr = data['data']['averagePercentChange'];
          // Remove the % sign and parse as double
          double percentValue = double.parse(percentStr.replaceAll('%', ''));
          return percentValue;
        }
      }
    } catch (e) {
      print('Error fetching performance for AMC $amcId: $e');
    }

    // Return random default value between -5 and 5 if API fails
    return (DateTime.now().millisecondsSinceEpoch % 1000) / 100 - 5;
  }

  // Get AMC logo URL based on name
  String getAmcLogo(String amcName) {
    final logoMap = {
      'HDFC Amc': 'https://upload.wikimedia.org/wikipedia/commons/7/70/HDFC_Bank_Logo.svg',
      'ICIC Amc': 'https://www.icicipruamc.com/docs/default-source/default-document-library/icici-pru-logo.jpg',
      'prakash': 'https://www.quantmutual.com/images/logo.png',
      'Classia amc': 'https://www.sbimf.com/images/default-source/default-album/sbi-mutual-fund-logo.png',
      'test amc': 'https://www.axisbank.com/etc.clientlibs/kotak/clientlibs/clientlib-base/resources/images/kotak-logo.png',
      'Amc Classia': 'https://www.kotak.com/etc.clientlibs/kotak/clientlibs/clientlib-base/resources/images/kotak-logo.png',
    };

    return logoMap[amcName] ?? 'https://www.quantmutual.com/images/logo.png';
  }

  // Get AMC fund name based on AMC name
  String getAmcFundName(String amcName) {
    final fundNameMap = {
      'HDFC Amc': 'Mid-Cap Opportunities Fund',
      'ICIC Amc': 'Technology Fund',
      'prakash': 'Small Cap Fund',
      'Classia amc': 'Bluechip Fund',
      'test amc': 'Midcap Fund',
      'Amc Classia': 'Emerging Equity Fund',
    };

    return fundNameMap[amcName] ?? 'Mutual Fund';
  }

  // Get default AMC data as fallback
  List<Map<String, dynamic>> getDefaultAmcData() {
    return [
      {
        "id": 1,
        "logo": "https://www.quantmutual.com/images/logo.png",
        "name": "Quant",
        "fundName": "Small Cap Fund",
        "value": 51.2,
      },
      {
        "id": 2,
        "logo": "https://www.nipponindiamf.com/assets/images/niam-logo.png",
        "name": "Nippon India",
        "fundName": "Small Cap Fund",
        "value": 46.8,
      },
      {
        "id": 3,
        "logo": "https://www.sbimf.com/images/default-source/default-album/sbi-mutual-fund-logo.png",
        "name": "SBI",
        "fundName": "Small Cap Fund",
        "value": 41.5,
      },
      {
        "id": 4,
        "logo": "https://www.icicipruamc.com/docs/default-source/default-document-library/icici-pru-logo.jpg",
        "name": "ICICI Prudential",
        "fundName": "Technology Fund",
        "value": 43.1,
      },
      {
        "id": 5,
        "logo": "https://upload.wikimedia.org/wikipedia/commons/7/70/HDFC_Bank_Logo.svg",
        "name": "HDFC",
        "fundName": "Mid-Cap Opportunities Fund",
        "value": 38.7,
      },
    ];
  }

  // Main method to load enriched AMC data
  Future<List<Map<String, dynamic>>> loadAmcData() async {
    try {
      // First, get the list of AMCs
      final amcListData = await fetchAmcList();

      // Then, get performance data for each AMC
      List<Map<String, dynamic>> enrichedAmcList = [];

      for (var amc in amcListData) {
        final performanceData = await fetchAmcPerformance(amc['ID']);

        enrichedAmcList.add({
          'id': amc['ID'],
          'logo': getAmcLogo(amc['Name']),
          'name': amc['Name'],
          'fundName': getAmcFundName(amc['Name']),
          'value': performanceData,
          'email': amc['Email'],
          'mobile': amc['Mobile'],
        });
      }

      // Sort by performance value in descending order
      enrichedAmcList.sort((a, b) => b['value'].compareTo(a['value']));

      return enrichedAmcList;
    } catch (e) {
      print('Error in TradeService.loadAmcData: $e');
      // Return default data as fallback
      final defaultData = getDefaultAmcData();
      defaultData.sort((a, b) => b["value"].compareTo(a["value"]));
      return defaultData;
    }
  }
}