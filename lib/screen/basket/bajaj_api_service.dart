// // File: lib/bajaj_api_service.dart
//
// import 'dart:convert';
// import 'package:classia_amc/utills/constent/user_constant.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class BajajApiService {
//   static const String baseUrl = 'https://nodeapi.classiacapital.com';
//   static const String ssoUrl = 'https://sso.bajajbroking.in';
//   static const String bridgeUrl = 'https://bridgelink.bajajbroking.in';
//   static const String clientId = '54F97FA8-A45C-48FC-BC5A-F6A6AC81D1A7';
//   static const String clientSecret = 'T039SWyFe6BGyRyQoeVGOA==';
//   static const String redirectUri = 'https://classiacapital.com/';
//
//   // Get authorization token from SharedPreferences
//   Future<String?> _getAuthToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }
//
//   // Get Bajaj access token from SharedPreferences
//   Future<String?> getBajajAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('bajaj_access_token');
//   }
//
//   // Save Bajaj tokens to SharedPreferences
//   Future<void> saveBajajTokens({
//     required String accessToken,
//     required String refreshToken,
//     required int expiresIn,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('bajaj_access_token', accessToken);
//     await prefs.setString('bajaj_refresh_token', refreshToken);
//     await prefs.setInt('bajaj_token_expiry',
//         DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000));
//   }
//
//   // Check if Bajaj token is valid
//   Future<bool> isBajajTokenValid() async {
//     final prefs = await SharedPreferences.getInstance();
//     final expiry = prefs.getInt('bajaj_token_expiry');
//     if (expiry == null) return false;
//     return DateTime.now().millisecondsSinceEpoch < expiry;
//   }
//
//   // Clear Bajaj tokens
//   Future<void> clearBajajTokens() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('bajaj_access_token');
//     await prefs.remove('bajaj_refresh_token');
//     await prefs.remove('bajaj_token_expiry');
//   }
//
//   // Get basket list with filters
//   Future<BasketListResponse> getBasketList({
//     String? subscriptionType = 'FREE',
//     String? volatility = 'LOW',
//     String? status = 'ACTIVE',
//     int? id,
//     int page = 1,
//     int sizePerPage = 10,
//   }) async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) throw Exception('Auth token not found');
//
//       final queryParams = {
//         if (subscriptionType != null) 'subscryptionType': subscriptionType,
//         if (volatility != null) 'volatility': volatility,
//         if (status != null) 'status': status,
//         if (id != null) 'id': id.toString(),
//         'page': page.toString(),
//         'sizePerPage': sizePerPage.toString(),
//       };
//
//       final uri = Uri.parse('$baseUrl/basket/list')
//           .replace(queryParameters: queryParams);
//
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': '${UserConstants.TOKEN}',
//           'Content-Type': 'application/json',
//         },
//       );
//       print(response.statusCode);
//       print(response.body);
//       if (response.statusCode == 200) {
//         return BasketListResponse.fromJson(json.decode(response.body));
//       } else {
//         throw Exception('Failed to load baskets: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching baskets: $e');
//     }
//   }
//
//   // Get Bajaj SSO authorization URL
//   String getBajajAuthUrl() {
//     final params = {
//       'response_type': 'code',
//       'state': '1234',
//       'redirect_uri': redirectUri,
//       'client_id': clientId,
//     };
//
//     return Uri.parse('$ssoUrl/api/sso/oauth/authorize')
//         .replace(queryParameters: params)
//         .toString();
//   }
//
//   // Exchange authorization code for access token
//   Future<BajajTokenResponse> exchangeCodeForToken(String code) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$bridgeUrl/api/user/token'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'grant_type': 'authorization_code',
//           'code': code,
//           'client_id': clientId,
//           'client_secret': clientSecret,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final tokenResponse = BajajTokenResponse.fromJson(
//           json.decode(response.body),
//         );
//
//         // Save tokens to SharedPreferences
//         await saveBajajTokens(
//           accessToken: tokenResponse.data.accessToken,
//           refreshToken: tokenResponse.data.refreshToken,
//           expiresIn: tokenResponse.data.expiresIn,
//         );
//
//         return tokenResponse;
//       } else {
//         throw Exception('Failed to exchange token: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error exchanging token: $e');
//     }
//   }
//
//   // Refresh Bajaj access token
//   Future<BajajTokenResponse> refreshBajajToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final refreshToken = prefs.getString('bajaj_refresh_token');
//
//       if (refreshToken == null) {
//         throw Exception('Refresh token not found');
//       }
//
//       final response = await http.post(
//         Uri.parse('$bridgeUrl/api/user/token'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'grant_type': 'refresh_token',
//           'refresh_token': refreshToken,
//           'client_id': clientId,
//           'client_secret': clientSecret,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final tokenResponse = BajajTokenResponse.fromJson(
//           json.decode(response.body),
//         );
//
//         await saveBajajTokens(
//           accessToken: tokenResponse.data.accessToken,
//           refreshToken: tokenResponse.data.refreshToken,
//           expiresIn: tokenResponse.data.expiresIn,
//         );
//
//         return tokenResponse;
//       } else {
//         throw Exception('Failed to refresh token: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error refreshing token: $e');
//     }
//   }
// }
//
// // Models
// class BasketListResponse {
//   final bool status;
//   final String message;
//   final BasketData data;
//
//   BasketListResponse({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   factory BasketListResponse.fromJson(Map<String, dynamic> json) {
//     return BasketListResponse(
//       status: json['status'],
//       message: json['message'],
//       data: BasketData.fromJson(json['data']),
//     );
//   }
// }
//
// class BasketData {
//   final int totalRecords;
//   final int totalPages;
//   final int currentPage;
//   final List<Basket> basketList;
//
//   BasketData({
//     required this.totalRecords,
//     required this.totalPages,
//     required this.currentPage,
//     required this.basketList,
//   });
//
//   factory BasketData.fromJson(Map<String, dynamic> json) {
//     return BasketData(
//       totalRecords: json['totalRecords'],
//       totalPages: json['totalPages'],
//       currentPage: json['currentPage'],
//       basketList: (json['basketList'] as List)
//           .map((e) => Basket.fromJson(e))
//           .toList(),
//     );
//   }
// }
//
// class Basket {
//   final int id;
//   final String basketName;
//   final String subscriptionAmount;
//   final String raName;
//   final String expectedReturn;
//   final String subscryptionType;
//   final String volatility;
//   final String status;
//   final List<Holding> holdings;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   Basket({
//     required this.id,
//     required this.basketName,
//     required this.subscriptionAmount,
//     required this.raName,
//     required this.expectedReturn,
//     required this.subscryptionType,
//     required this.volatility,
//     required this.status,
//     required this.holdings,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory Basket.fromJson(Map<String, dynamic> json) {
//     return Basket(
//       id: json['id'],
//       basketName: json['basketName'],
//       subscriptionAmount: json['subscriptionAmount'],
//       raName: json['raName'],
//       expectedReturn: json['expectedReturn'],
//       subscryptionType: json['subscryptionType'],
//       volatility: json['volatility'],
//       status: json['status'],
//       holdings: (json['holdings'] as List)
//           .map((e) => Holding.fromJson(e))
//           .toList(),
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }
// }
//
// class Holding {
//   final String slPrice;
//   final int stockId;
//   final String tgtPrice;
//   final String orderType;
//   final String holdinPercentage;
//
//   Holding({
//     required this.slPrice,
//     required this.stockId,
//     required this.tgtPrice,
//     required this.orderType,
//     required this.holdinPercentage,
//   });
//
//   factory Holding.fromJson(Map<String, dynamic> json) {
//     return Holding(
//       slPrice: json['slPrice'],
//       stockId: json['stockId'],
//       tgtPrice: json['tgtPrice'],
//       orderType: json['orderType'],
//       holdinPercentage: json['holdinPercentage'],
//     );
//   }
// }
//
// class BajajTokenResponse {
//   final int statusCode;
//   final String message;
//   final BajajTokenData data;
//
//   BajajTokenResponse({
//     required this.statusCode,
//     required this.message,
//     required this.data,
//   });
//
//   factory BajajTokenResponse.fromJson(Map<String, dynamic> json) {
//     return BajajTokenResponse(
//       statusCode: json['statusCode'],
//       message: json['message'],
//       data: BajajTokenData.fromJson(json['data']),
//     );
//   }
// }
//
// class BajajTokenData {
//   final String accessToken;
//   final String tokenType;
//   final int expiresIn;
//   final String refreshToken;
//
//   BajajTokenData({
//     required this.accessToken,
//     required this.tokenType,
//     required this.expiresIn,
//     required this.refreshToken,
//   });
//
//   factory BajajTokenData.fromJson(Map<String, dynamic> json) {
//     return BajajTokenData(
//       accessToken: json['access_token'],
//       tokenType: json['token_type'],
//       expiresIn: json['expires_in'],
//       refreshToken: json['refresh_token'],
//     );
//   }
// }


import 'dart:convert';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;

import 'basket_model.dart';


class BasketService {
  static const String _baseUrl =
      'https://nodeapi.classiacapital.com/basket/list';


  Future<List<Basket>> fetchBaskets({
    int page = 1,
    int sizePerPage = 10,
  }) async {
    final uri = Uri.parse(
        '$_baseUrl');

    final response = await http.get(
      uri,
      headers: {'Authorization':'${UserConstants.TOKEN}'},
    );
   print(response.body);
   print(response.statusCode);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final basketResp = BasketResponse.fromJson(json);
      return basketResp.data.basketList;
    } else {
      throw Exception('Failed to load baskets: ${response.statusCode}');
    }
  }
}