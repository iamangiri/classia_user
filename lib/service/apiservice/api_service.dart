import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;
import '../../models/mutual_fund_models.dart';
import '../WithoutLogin/auth_login_check_service.dart';


class ApiService {

  static const String _mutualFundEndpoint =
      '/mutual-fund/list?page=1&sizePerPage=10&isProd=true';

  Future<MutualFundResponse> fetchMutualFunds() async {
    try {
      final response = await http.get(
        Uri.parse( AppConstant.NODE_API_URL+ _mutualFundEndpoint),
        headers: {
          'Authorization': '${UserConstants.TOKEN}',
        },
      );
      print(response.statusCode);
      print(response.body);
      await checkValidUserWithRouter(response.statusCode);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return MutualFundResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load mutual funds: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching mutual funds: $e');
    }
  }
}