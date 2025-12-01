import 'package:equatable/equatable.dart';

class BasketResponse {
  final bool status;
  final String message;
  final BasketData data;

  BasketResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BasketResponse.fromJson(Map<String, dynamic> json) => BasketResponse(
    status: json['status'] as bool,
    message: json['message'] as String,
    data: BasketData.fromJson(json['data'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}

class BasketData {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final List<Basket> basketList;
  final dynamic minInvestment;

  BasketData({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.basketList,
    this.minInvestment,
  });

  factory BasketData.fromJson(Map<String, dynamic> json) => BasketData(
    totalRecords: json['totalRecords'] as int,
    totalPages: json['totalPages'] as int,
    currentPage: json['currentPage'] as int,
    basketList: (json['basketList'] as List)
        .map((e) => Basket.fromJson(e as Map<String, dynamic>))
        .toList(),
    minInvestment: json['minInvestment'],
  );

  Map<String, dynamic> toJson() => {
    'totalRecords': totalRecords,
    'totalPages': totalPages,
    'currentPage': currentPage,
    'basketList': basketList.map((e) => e.toJson()).toList(),
    'minInvestment': minInvestment,
  };
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
  final String type;
  final List<Holding> holdings;
  final dynamic createdBy;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const Basket({
    required this.id,
    required this.basketName,
    required this.subscriptionAmount,
    required this.raName,
    required this.expectedReturn,
    required this.subscryptionType,
    required this.volatility,
    required this.status,
    required this.type,
    required this.holdings,
    this.createdBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
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
    type: json['type'] as String? ?? 'DELIVERY',
    holdings: (json['holdings'] as List)
        .map((e) => Holding.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdBy: json['createdBy'],
    isDeleted: json['isDeleted'] as bool? ?? false,
    createdAt: json['createdAt'] as String,
    updatedAt: json['updatedAt'] as String,
    deletedAt: json['deletedAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'basketName': basketName,
    'subscriptionAmount': subscriptionAmount,
    'raName': raName,
    'expectedReturn': expectedReturn,
    'subscryptionType': subscryptionType,
    'volatility': volatility,
    'status': status,
    'type': type,
    'holdings': holdings.map((e) => e.toJson()).toList(),
    'createdBy': createdBy,
    'isDeleted': isDeleted,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'deletedAt': deletedAt,
  };

  // Helper methods
  bool get isFree => subscryptionType.toUpperCase() == 'FREE';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isDeliveryType => type.toUpperCase() == 'DELIVERY';
  bool get isIntradayType => type.toUpperCase() == 'INTRADAY';
  bool get isIntraHourType => type.toUpperCase() == 'INTRAHOUR';
  bool get hasHoldings => holdings.isNotEmpty;
  int get holdingsCount => holdings.length;

  @override
  List<Object?> get props => [id];
}

class Holding extends Equatable {
  final int id;
  final String isin;
  final int token;
  final String units;
  final String exchId;
  final String expiry;
  final String sector;
  final String series;
  final String symbol;
  final String slPrice;
  final int stockId;
  final String fullName;
  final String industry;
  final String tgtPrice;
  final dynamic tickSize;
  final dynamic faceValue;
  final double marketCap;
  final int marketLot;
  final String orderType;
  final String indexSymbol;
  final double strikePrice;
  final String marketCapType;
  final String instrumentType;
  final String holdinPercentage;

  const Holding({
    required this.id,
    required this.isin,
    required this.token,
    required this.units,
    required this.exchId,
    required this.expiry,
    required this.sector,
    required this.series,
    required this.symbol,
    required this.slPrice,
    required this.stockId,
    required this.fullName,
    required this.industry,
    required this.tgtPrice,
    this.tickSize,
    this.faceValue,
    required this.marketCap,
    required this.marketLot,
    required this.orderType,
    required this.indexSymbol,
    required this.strikePrice,
    required this.marketCapType,
    required this.instrumentType,
    required this.holdinPercentage,
  });

  factory Holding.fromJson(Map<String, dynamic> json) => Holding(
    id: json['id'] as int,
    isin: json['isin'] as String? ?? '',
    token: json['token'] as int,
    units: json['units'] as String? ?? '0',
    exchId: json['exchId'] as String? ?? '',
    expiry: json['expiry'] as String? ?? '0',
    sector: json['sector'] as String? ?? '',
    series: json['series'] as String? ?? '',
    symbol: json['symbol'] as String? ?? '',
    slPrice: json['slPrice'] as String? ?? '0',
    stockId: json['stockId'] as int,
    fullName: json['fullName'] as String? ?? 'Unknown Stock',
    industry: json['industry'] as String? ?? '',
    tgtPrice: json['tgtPrice'] as String? ?? '0',
    tickSize: json['tickSize'],
    faceValue: json['faceValue'],
    marketCap: (json['marketCap'] as num?)?.toDouble() ?? 0.0,
    marketLot: json['marketLot'] as int? ?? 1,
    orderType: json['orderType'] as String? ?? 'MARKET',
    indexSymbol: json['indexSymbol'] as String? ?? '',
    strikePrice: (json['strikePrice'] as num?)?.toDouble() ?? 0.0,
    marketCapType: json['marketCapType'] as String? ?? '',
    instrumentType: json['instrumentType'] as String? ?? '',
    holdinPercentage: json['holdinPercentage'] as String? ?? '0',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'isin': isin,
    'token': token,
    'units': units,
    'exchId': exchId,
    'expiry': expiry,
    'sector': sector,
    'series': series,
    'symbol': symbol,
    'slPrice': slPrice,
    'stockId': stockId,
    'fullName': fullName,
    'industry': industry,
    'tgtPrice': tgtPrice,
    'tickSize': tickSize,
    'faceValue': faceValue,
    'marketCap': marketCap,
    'marketLot': marketLot,
    'orderType': orderType,
    'indexSymbol': indexSymbol,
    'strikePrice': strikePrice,
    'marketCapType': marketCapType,
    'instrumentType': instrumentType,
    'holdinPercentage': holdinPercentage,
  };

  // Helper methods
  bool get isMarketOrder => orderType.toUpperCase() == 'MARKET';
  bool get isLimitOrder => orderType.toUpperCase() == 'LIMIT';
  bool get hasStopLoss => double.tryParse(slPrice) != null && double.parse(slPrice) > 0;
  bool get hasTarget => double.tryParse(tgtPrice) != null && double.parse(tgtPrice) > 0;

  // Get formatted price strings
  String get formattedSlPrice => '₹${slPrice}';
  String get formattedTgtPrice => '₹${tgtPrice}';
  String get formattedHoldingPercentage => '$holdinPercentage%';

  @override
  List<Object?> get props => [id, stockId];
}