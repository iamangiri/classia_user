import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;

class WalletService {

  final String token;

  WalletService({required this.token});

  Future<Map<String, dynamic>> getTransactionList(int page, int limit, {String? transactionType}) async {
    final response = await http.get(
      Uri.parse('${AppConstant.API_URL}/user/transaction/list?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
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

  Future<void> deposit(int amount) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/deposit/amount'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: {
        'amount': amount.toString(),
        'amcId' : '2'
      },
    );
     print(response.body);
     print(response.statusCode);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Failed to deposit');
    }
  }

  Future<void> withdraw(int amount) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/withdraw/amount'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: {
        'amount': amount.toString(),
        'amcId' : '2'
      },
    );
    print(response.body);
    print(response.statusCode);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Failed to withdraw');
    }
  }

}
