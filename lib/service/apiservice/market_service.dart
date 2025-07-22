import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketService {
  static const String _baseUrl = 'https://api.mfapi.in/mf';

  // Fetch list of mutual funds
  Future<List<Map<String, dynamic>>> fetchMutualFunds() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((fund) => _mapFundData(fund)).toList();
      } else {
        throw Exception('Failed to load mutual funds');
      }
    } catch (e) {
      throw Exception('Error fetching mutual funds: $e');
    }
  }

  // Fetch fund details (NAV history) for a specific scheme code
  Future<Map<String, dynamic>> fetchFundDetails(String schemeCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$schemeCode'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapFundDetailsData(data);
      } else {
        throw Exception('Failed to load fund details');
      }
    } catch (e) {
      throw Exception('Error fetching fund details: $e');
    }
  }

  // Map fund data from API to the app's expected format
  Map<String, dynamic> _mapFundData(dynamic fund) {
    return {
      'schemeCode': fund['schemeCode'].toString(),
      'name': fund['schemeName'] ?? 'Unknown Fund',
      'category': _deriveCategory(fund['schemeName']),
      'logo': 'https://via.placeholder.com/150', // Dummy logo
      'returns': _generateDummyReturns(), // Dummy returns
      'minSip': '₹${_generateDummyMinSip()}', // Dummy min SIP
      'rating': _generateDummyRating(), // Dummy rating
      'risk': _generateDummyRisk(), // Dummy risk
    };
  }

  // Map fund details data from API
  Map<String, dynamic> _mapFundDetailsData(dynamic data) {
    return {
      'meta': {
        'fund_house': data['meta']['fund_house'],
        'scheme_type': data['meta']['scheme_type'],
        'scheme_category': data['meta']['scheme_category'],
        'scheme_code': data['meta']['scheme_code'].toString(),
        'name': data['meta']['scheme_name'],
      },
      'navHistory': (data['data'] as List<dynamic>)
          .map((item) => {
        'date': item['date'],
        'nav': double.parse(item['nav']),
      })
          .toList(),
    };
  }

  // Derive category based on scheme name (simplified logic)
  String _deriveCategory(String schemeName) {
    if (schemeName.contains('Equity') || schemeName.contains('Large & Mid Cap')) {
      return 'Equity';
    } else if (schemeName.contains('Debt') || schemeName.contains('Income')) {
      return 'Debt';
    } else if (schemeName.contains('Hybrid')) {
      return 'Hybrid';
    } else if (schemeName.contains('Tax')) {
      return 'Tax Saving';
    } else {
      return 'Other';
    }
  }

  // Generate dummy data for fields not in API
  String _generateDummyReturns() {
    return '+${(10 + (DateTime.now().millisecondsSinceEpoch % 20)).toString()}%';
  }

  int _generateDummyMinSip() {
    return 500 + (DateTime.now().millisecondsSinceEpoch % 4500);
  }

  double _generateDummyRating() {
    return (3.0 + (DateTime.now().millisecondsSinceEpoch % 20) / 10).toDouble();
  }

  int _generateDummyRisk() {
    return (1 + (DateTime.now().millisecondsSinceEpoch % 5)).toInt();
  }
}