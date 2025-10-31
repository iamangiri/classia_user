import 'package:equatable/equatable.dart';

class BasketResponse {
  final bool status;
  final String message;
  final BasketData data;

  BasketResponse({required this.status, required this.message, required this.data});

  factory BasketResponse.fromJson(Map<String, dynamic> json) => BasketResponse(
    status: json['status'] as bool,
    message: json['message'] as String,
    data: BasketData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

class BasketData {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final List<Basket> basketList;

  BasketData({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.basketList,
  });

  factory BasketData.fromJson(Map<String, dynamic> json) => BasketData(
    totalRecords: json['totalRecords'] as int,
    totalPages: json['totalPages'] as int,
    currentPage: json['currentPage'] as int,
    basketList: (json['basketList'] as List)
        .map((e) => Basket.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class Basket extends Equatable {
  final int id;
  final String basketName;
  final String subscriptionAmount;
  final String raName;
  final String expectedReturn;
  final String subscryptionType;
  final String volatility;
  final String status;
  final List<Holding> holdings;

  const Basket({
    required this.id,
    required this.basketName,
    required this.subscriptionAmount,
    required this.raName,
    required this.expectedReturn,
    required this.subscryptionType,
    required this.volatility,
    required this.status,
    required this.holdings,
  });

  factory Basket.fromJson(Map<String, dynamic> json) => Basket(
    id: json['id'] as int,
    basketName: json['basketName'] as String,
    subscriptionAmount: json['subscriptionAmount'] as String,
    raName: json['raName'] as String,
    expectedReturn: json['expectedReturn'] as String,
    subscryptionType: json['subscryptionType'] as String,
    volatility: json['volatility'] as String,
    status: json['status'] as String,
    holdings: (json['holdings'] as List)
        .map((e) => Holding.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  @override
  List<Object?> get props => [id];
}

class Holding extends Equatable {
  final String slPrice;
  final int stockId;
  final String tgtPrice;
  final String orderType;
  final String holdinPercentage;

  const Holding({
    required this.slPrice,
    required this.stockId,
    required this.tgtPrice,
    required this.orderType,
    required this.holdinPercentage,
  });

  factory Holding.fromJson(Map<String, dynamic> json) => Holding(
    slPrice: json['slPrice'] as String,
    stockId: json['stockId'] as int,
    tgtPrice: json['tgtPrice'] as String,
    orderType: json['orderType'] as String,
    holdinPercentage: json['holdinPercentage'] as String,
  );

  @override
  List<Object?> get props => [stockId];
}