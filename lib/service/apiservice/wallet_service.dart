import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;

import '../WithoutLogin/auth_login_check_service.dart';

class WalletService {

  final String token;
  static const String _baseUrl = 'https://nodeapi.classiacapital.com/basket';

  WalletService({required this.token});

  Future<Map<String, dynamic>> getTransactionList(int page, int limit, {String? transactionType}) async {
    final response = await http.get(
      Uri.parse('${AppConstant.API_URL}/user/transaction/list?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    await checkValidUserWithRouter(response.statusCode);
    if (response.statusCode == 200 && data['status'] == true) {
      // Filter transactions by transactionType if provided
      final transactions = List<Map<String, dynamic>>.from(data['data']['transactions'])
          .where((txn) => transactionType == null || txn['TransactionType'] == transactionType)
          .toList();
      return {
        'pagination': data['data']['pagination'],
        'transactions': transactions,
      };
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch transactions');
    }
  }

  Future<void> deposit(int amount,int amcId) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/deposit/amount'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: {
        'amount': amount.toString(),
        'amcId' : amcId.toString()
      },
    );
     print(response.body);
     print(response.statusCode);
    await checkValidUserWithRouter(response.statusCode);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Failed to deposit');
    }
  }

  Future<void> withdraw(int amount ,int amcId) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/withdraw/amount'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: {
        'amount': amount.toString(),
        'amcId' : amcId.toString(),
      },
    );
    print(response.body);
    print(response.statusCode);
    await checkValidUserWithRouter(response.statusCode);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Failed to withdraw');
    }
  }


  // Deposit money to wallet
  Future<Map<String, dynamic>> depositMoney({
    required double amount,
    required Map<String, dynamic> depositDetails,
  }) async {
    final uri = Uri.parse('$_baseUrl/deposit');

    final requestBody = {
      'amount': amount,
      'depositDetails': depositDetails,
    };

    print('Deposit Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': '${UserConstants.TOKEN}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('Deposit Response: ${response.body}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json;
    } else {
      throw Exception('Failed to deposit money: ${response.statusCode}');
    }
  }

  // Get wallet balance (if you have this endpoint)
  Future<Map<String, dynamic>> getWalletBalance() async {
    final uri = Uri.parse('$_baseUrl/wallet-balance');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': '${UserConstants.TOKEN}',
      },
    );

    print('Wallet Balance Response: ${response.body}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json;
    } else {
      throw Exception('Failed to get wallet balance: ${response.statusCode}');
    }
  }

  // Get transaction history (if you have this endpoint)
  static Future<Map<String, dynamic>> TransactionList({int page = 1, int sizePerPage = 10}) async {
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



}
