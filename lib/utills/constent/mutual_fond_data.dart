import '../../service/apiservice/market_service.dart';

class MutualFondData {
  static Future<List<Map<String, dynamic>>> get mutualFunds async {
    final marketService = MarketService();
    return await marketService.fetchMutualFunds();
  }
}