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
  Future<List<Map<String, dynamic>>> loadAmcData({required String filter, required bool isBuy}) async {
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
          'fundName': amc['FundName'] ?? 'Mutual Fund', // Use dynamic fund name from API
          'value': performanceData,
          'email': amc['Email'],
          'mobile': amc['Mobile'],
          'address': amc['Address'],
          'city': amc['City'],
          'state': amc['State'],
          'pinCode': amc['PinCode'],
          'contactPersonName': amc['ContactPersonName'],
          'contactPersonDesignation': amc['ContactPerDesignation'],
          'panNumber': amc['PanNumber'],
          'equityPer': amc['EquityPer'],
          'debtPer': amc['DebtPer'],
          'cashSplit': amc['CashSplit'],
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