import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:http/http.dart' as http;
import '../../models/user_kyc_model.dart';

class UserService {

  final String token; // JWT token

  UserService({required this.token});

// Helper method to set headers
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

// Send Aadhaar OTP
  Future<AadhaarOtpResponse> sendAadhaarOtp(String aadhaarNumber) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/send/adhar/otp'),
      headers: _getHeaders(),
      body: jsonEncode({'aadharNumber': aadhaarNumber}),
    );

    final data = jsonDecode(response.body);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return AadhaarOtpResponse.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to send Aadhaar OTP');
    }
  }

// Verify Aadhaar OTP
  Future<void> verifyAadhaarOtp(
      String aadhaarNumber, String referenceId, String otp) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/verify/adhar/otp'),
      headers: _getHeaders(),
      body: jsonEncode({
        'aadharNumber': aadhaarNumber,
        'referenceId': referenceId,
        'otp': otp,
      }),
    );
    print(response.statusCode);
    print(response.body);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Failed to verify Aadhaar OTP');
    }
  }

// Check PAN-Aadhaar Link Status
  Future<PanAadhaarStatusResponse> checkPanAadhaarStatus(
      String aadhaarNumber, String panNumber) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/pan/adhar/link/status'),
      headers: _getHeaders(),
      body: jsonEncode({
        'aadhaarNumber': aadhaarNumber,
        'panNumber': panNumber,
      }),
    );
    print(response.statusCode);
    print(response.body);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return PanAadhaarStatusResponse.fromJson(data['data']);
    } else {
      throw Exception(
          data['message'] ?? 'Failed to check PAN-Aadhaar link status');
    }
  }

// Add Bank Account
  Future<BankDetailsResponse> addBankAccount(
      Map<String, String> bankData) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/add/bank/account'),
      headers: _getHeaders(),
      body: jsonEncode(bankData),
    );
    print(response.statusCode);
    print(response.body);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return BankDetailsResponse.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to add bank account');
    }
  }



  // Add Folio Number
  Future<void> addFolioNumber(String folioNumber) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/add/folio/number'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: {'folioNumber': folioNumber},
    );
    print(response.statusCode);
    print(response.body);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Failed to add folio number');
    }
  }

  // Get Folio List
  Future<Map<String, dynamic>> getFolioList(int page, int limit) async {
    final response = await http.post(
      Uri.parse('${AppConstant.API_URL}/user/folio/list'),
      headers: _getHeaders(),
      body: jsonEncode({'page': page, 'limit': limit}),
    );
   print(response.statusCode);
   print(response.body);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch folio numbers');
    }
  }

}

