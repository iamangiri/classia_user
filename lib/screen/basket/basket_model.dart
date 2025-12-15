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
    status: json['status'] as bool? ?? false,
    message: json['message'] as String? ?? '',
    data: BasketData.fromJson(json['data'] as Map<String, dynamic>),
  );
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

  factory BasketData.fromJson(Map<String, dynamic> json) {
    return BasketData(
      totalRecords: _safeInt(json['totalRecords']),
      totalPages: _safeInt(json['totalPages']),
      currentPage: _safeInt(json['currentPage']),
      basketList: (json['basketList'] as List<dynamic>?)
          ?.map((e) => Basket.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      minInvestment: json['minInvestment'],
    );
  }
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
  final String action;
  final String? basketInitialPrice;
  final dynamic basketCurrentPrice;
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
    required this.action,
    this.basketInitialPrice,
    this.basketCurrentPrice,
    required this.holdings,
    this.createdBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Basket.fromJson(Map<String, dynamic> json) => Basket(
    id: _safeInt(json['id']),
    basketName: json['basketName']?.toString() ?? 'Unknown',
    subscriptionAmount: json['subscriptionAmount']?.toString() ?? '0',
    raName: json['raName']?.toString() ?? 'Unknown',
    expectedReturn: json['expectedReturn']?.toString() ?? '0',
    subscryptionType: json['subscryptionType']?.toString() ?? 'FREE',
    volatility: json['volatility']?.toString() ?? 'LOW',
    status: json['status']?.toString() ?? 'INACTIVE',
    type: json['type']?.toString() ?? 'DELIVERY',
    action: json['action']?.toString() ?? 'BUY',
    basketInitialPrice: json['basketInitialPrice']?.toString(),
    basketCurrentPrice: json['basketCurrentPrice'],
    holdings: (json['holdings'] as List<dynamic>?)
        ?.map((e) => Holding.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [],
    createdBy: json['createdBy'],
    isDeleted: json['isDeleted'] as bool? ?? false,
    createdAt: json['createdAt']?.toString() ?? '',
    updatedAt: json['updatedAt']?.toString() ?? '',
    deletedAt: json['deletedAt'] as String?,
  );

  // Safe Getters
  double get expectedReturnValue => double.tryParse(expectedReturn) ?? 0.0;
  int get subscriptionAmountValue => int.tryParse(subscriptionAmount) ?? 0;
  int get holdingsCount => holdings.length;

  bool get isFree => subscryptionType.toUpperCase() == 'FREE';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isDeliveryType => type.toUpperCase() == 'DELIVERY';
  bool get isBuyAction => action.toUpperCase() == 'BUY';

  // Price getters - ALWAYS return valid numbers, default to 0
  double get initialPriceValue {
    if (basketInitialPrice == null || basketInitialPrice == 'null' || basketInitialPrice == '') {
      return 0.0;
    }
    return double.tryParse(basketInitialPrice!) ?? 0.0;
  }

  double get currentPriceValue {
    if (basketCurrentPrice == null || basketCurrentPrice == 'null' || basketCurrentPrice == '') {
      return 0.0;
    }
    if (basketCurrentPrice is num) {
      return (basketCurrentPrice as num).toDouble();
    }
    return double.tryParse(basketCurrentPrice.toString()) ?? 0.0;
  }

  // ✅ FIXED: Calculate percentage change with proper validation
  // Formula: ((Current - Initial) / Initial) × 100
  double get priceChangePercentage {
    // Return 0 if either price is invalid or zero
    if (initialPriceValue <= 0 || currentPriceValue <= 0) {
      return 0.0;
    }

    // Calculate: (Current - Initial) / Initial * 100
    final double change = currentPriceValue - initialPriceValue;
    final double percentage = (change / initialPriceValue) * 100;

    // Return 0 if result is NaN or Infinite
    if (percentage.isNaN || percentage.isInfinite) {
      return 0.0;
    }

    return percentage;
  }

  // Calculate absolute change
  double get priceChangeAmount {
    if (initialPriceValue <= 0 || currentPriceValue <= 0) {
      return 0.0;
    }
    return currentPriceValue - initialPriceValue;
  }

  // Check if we have valid price data (both must be greater than 0)
  bool get hasPriceData => initialPriceValue > 0 && currentPriceValue > 0;

  // ✅ FIXED: Performance always uses actual price change, returns 0 if no data
  double get performanceValue {
    if (!hasPriceData) {
      return 0.0;
    }
    return priceChangePercentage;
  }

  @override
  List<Object?> get props => [id];
}

class Holding extends Equatable {
  final int id;
  final String isin;
  final int token;
  final String units;
  final String exchId;
  final String symbol;
  final String slPrice;
  final String tgtPrice;
  final int stockId;
  final String fullName;
  final String holdinPercentage;
  final String orderType;

  const Holding({
    required this.id,
    required this.isin,
    required this.token,
    required this.units,
    required this.exchId,
    required this.symbol,
    required this.slPrice,
    required this.tgtPrice,
    required this.stockId,
    required this.fullName,
    required this.holdinPercentage,
    required this.orderType,
  });

  factory Holding.fromJson(Map<String, dynamic> json) => Holding(
    id: _safeInt(json['id']),
    isin: json['isin']?.toString() ?? '',
    token: _safeInt(json['token']),
    units: json['units']?.toString() ?? '1',
    exchId: json['exchId']?.toString() ?? 'NSE',
    symbol: json['symbol']?.toString() ?? '',
    slPrice: json['slPrice']?.toString() ?? '0',
    tgtPrice: json['tgtPrice']?.toString() ?? '0',
    stockId: _safeInt(json['stockId']),
    fullName: json['fullName']?.toString() ?? 'Unknown Stock',
    holdinPercentage: json['holdinPercentage']?.toString() ?? '0',
    orderType: json['orderType']?.toString() ?? 'MARKET',
  );

  // Safe numeric values
  int get unitsValue => int.tryParse(units) ?? 1;
  double get slPriceValue => double.tryParse(slPrice) ?? 0.0;
  double get tgtPriceValue => double.tryParse(tgtPrice) ?? 0.0;
  double get percentageValue => double.tryParse(holdinPercentage) ?? 0.0;

  bool get hasTarget => tgtPriceValue > 0;
  bool get hasStopLoss => slPriceValue > 0;

  String get formattedPercentage => '${percentageValue.toStringAsFixed(0)}%';

  @override
  List<Object?> get props => [id, stockId];
}

// Helper: Safely convert anything → int (handles String, int, null, "null")
int _safeInt(dynamic value) {
  if (value == null || value == 'null' || value == '') return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}