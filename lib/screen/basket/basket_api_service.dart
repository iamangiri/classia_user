import 'dart:convert';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;
import 'basket_model.dart';


class BasketApiService {
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