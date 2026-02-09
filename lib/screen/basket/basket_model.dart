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
        data: json['data'] != null
            ? BasketData.fromJson(json['data'] as Map<String, dynamic>)
            : BasketData(
                totalRecords: 0, totalPages: 0, currentPage: 0, basketList: []),
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
    List<Basket> baskets = [];

    // Handle 'baskets' key from /list endpoint
    if (json['baskets'] != null) {
      baskets = (json['baskets'] as List<dynamic>)
          .map((e) => Basket.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Handle 'subscriptions' key from /my-subscriptions endpoint
    else if (json['subscriptions'] != null) {
      baskets = (json['subscriptions'] as List<dynamic>).map((e) {
        // For my-subscriptions, we prioritize the inner 'basket' object
        // but we need to inject subscription-specific details like basketVersionId and ID (subscription ID)
        if (e['basket'] != null) {
          final basketMap = Map<String, dynamic>.from(e['basket'] as Map);

          // Inject subscribed version ID
          if (e['basketVersionId'] != null) {
            basketMap['subscribedVersionId'] = e['basketVersionId'];
          }
          // Inject subscription ID
          if (e['ID'] != null) {
            basketMap['subscriptionId'] = e['ID'];
          }

          return Basket.fromJson(basketMap);
        }
        return Basket.fromJson(e as Map<String, dynamic>);
      }).toList();
    }
    // Fallback for old API structure or direct list
    else if (json['basketList'] != null) {
      baskets = (json['basketList'] as List<dynamic>)
          .map((e) => Basket.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Pagination mapping
    int total = 0;
    int pages = 0;
    int current = 1;

    if (json['pagination'] != null) {
      final pag = json['pagination'];
      total = _safeInt(pag['total']);
      // Calculate total pages if not provided (GoAPI doesn't seem to provide totalPages directly in pagination object based on example)
      // Example: "pagination": { "limit": 10, "page": 1, "total": 3 }
      int limit = _safeInt(pag['limit']);
      if (limit > 0) {
        pages = (total / limit).ceil();
      }
      current = _safeInt(pag['page']);
    } else {
      // Fallback to old keys
      total = _safeInt(json['totalRecords']);
      pages = _safeInt(json['totalPages']);
      current = _safeInt(json['currentPage']);
    }

    return BasketData(
      totalRecords: total,
      totalPages: pages,
      currentPage: current,
      basketList: baskets,
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

  // New Fields for Versioning
  final int? versionId; // The current version ID of the basket
  final int? subscribedVersionId; // The version ID the user is subscribed to
  final int? subscriptionId; // The ID of the subscription

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
    this.versionId,
    this.subscribedVersionId,
    this.subscriptionId,
  });

  factory Basket.fromJson(Map<String, dynamic> json) {
    // Determine if using New API (GoAPI) keys or Old API keys
    // New API uses uppercase ID, old uses id.
    // Also new API uses 'name', old 'basketName'.

    // ID MAPPING
    final id = _safeInt(json['ID'] ?? json['id']);

    // NAME MAPPING
    final basketName =
        json['name']?.toString() ?? json['basketName']?.toString() ?? 'Unknown';

    // SUBSCRIPTION AMOUNT
    final subscriptionAmount = json['subscriptionFee']?.toString() ??
        json['subscriptionAmount']?.toString() ??
        '0';

    // RA NAME (Missing in New API, Defaulting)
    final raName = json['raName']?.toString() ?? 'Classia Capital';

    // EXPECTED RETURN (Missing in New API, Defaulting)
    final expectedReturn = json['expectedReturn']?.toString() ?? '0';

    // SUBSCRIPTION TYPE (Derived from isFeeBased in New API)
    String subType = 'FREE';
    if (json.containsKey('isFeeBased')) {
      subType = (json['isFeeBased'] == true) ? 'PAID' : 'FREE';
    } else {
      subType = json['subscryptionType']?.toString() ?? 'FREE';
    }

    // VOLATILITY (Missing in New API, Defaulting)
    final volatility = json['volatility']?.toString() ?? 'LOW';

    // STATUS
    // In new API, status might be in 'versions' or 'currentVersion'.
    // Root object doesn't seem to have status in /list, but subscriptions has 'status': 'ACTIVE'
    // fallback to 'ACTIVE' if not found in root.
    final status = json['status']?.toString() ?? 'ACTIVE';

    // TYPE
    final type = json['basketType']?.toString() ??
        json['type']?.toString() ??
        'DELIVERY';

    // ACTION (Missing in New API, Defaulting)
    final action = json['action']?.toString() ?? 'BUY';

    // PRICES
    final initialPrice = json['initialPrice']?.toString() ??
        json['basketInitialPrice']?.toString();
    final currentPrice = json['currentPrice'] ?? json['basketCurrentPrice'];

    // VERSION INFO
    final versionId = _safeInt(json['currentVersionId']);
    final subscribedVersionId =
        _safeInt(json['subscribedVersionId']); // Injected from wrapper
    final subscriptionId =
        _safeInt(json['subscriptionId']); // Injected from wrapper

    // HOLDINGS / STOCKS
    // Old API: 'holdings'
    // New API: 'versions' (List) -> each version has 'stocks'. Or 'currentVersion' (Obj) -> 'stocks'.
    List<Holding> holdingsList = [];

    if (json['currentVersion'] != null &&
        json['currentVersion']['stocks'] != null) {
      holdingsList = (json['currentVersion']['stocks'] as List<dynamic>)
          .map((e) => Holding.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['versions'] != null &&
        (json['versions'] as List).isNotEmpty) {
      // Try to find published version or take the first one?
      // Assuming existing logic, we just check if any version has stocks (unlikely in list view based on example, but safe to check)
      // The example for /list showed versions but no stocks inside.
      // If stocks are missing, list will be empty.
      final v = json['versions'][0];
      if (v['stocks'] != null) {
        holdingsList = (v['stocks'] as List<dynamic>)
            .map((e) => Holding.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else if (json['holdings'] != null) {
      holdingsList = (json['holdings'] as List<dynamic>)
          .map((e) => Holding.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Basket(
      id: id,
      basketName: basketName,
      subscriptionAmount: subscriptionAmount,
      raName: raName,
      expectedReturn: expectedReturn,
      subscryptionType: subType,
      volatility: volatility,
      status: status,
      type: type,
      action: action,
      basketInitialPrice: initialPrice,
      basketCurrentPrice: currentPrice,
      holdings: holdingsList,
      createdBy: json['createdBy'], // might be missing in new API
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt:
          json['CreatedAt']?.toString() ?? json['createdAt']?.toString() ?? '',
      updatedAt:
          json['UpdatedAt']?.toString() ?? json['updatedAt']?.toString() ?? '',
      deletedAt: json['DeletedAt']?.toString() ?? json['deletedAt']?.toString(),
      versionId: versionId,
      subscribedVersionId: subscribedVersionId,
      subscriptionId: subscriptionId,
    );
  }

  Basket copyWith({
    int? id,
    String? basketName,
    String? subscriptionAmount,
    String? raName,
    String? expectedReturn,
    String? subscryptionType,
    String? volatility,
    String? status,
    String? type,
    String? action,
    String? basketInitialPrice,
    dynamic basketCurrentPrice,
    List<Holding>? holdings,
    dynamic createdBy,
    bool? isDeleted,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    int? versionId,
    int? subscribedVersionId,
    int? subscriptionId,
  }) {
    return Basket(
      id: id ?? this.id,
      basketName: basketName ?? this.basketName,
      subscriptionAmount: subscriptionAmount ?? this.subscriptionAmount,
      raName: raName ?? this.raName,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      subscryptionType: subscryptionType ?? this.subscryptionType,
      volatility: volatility ?? this.volatility,
      status: status ?? this.status,
      type: type ?? this.type,
      action: action ?? this.action,
      basketInitialPrice: basketInitialPrice ?? this.basketInitialPrice,
      basketCurrentPrice: basketCurrentPrice ?? this.basketCurrentPrice,
      holdings: holdings ?? this.holdings,
      createdBy: createdBy ?? this.createdBy,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionId: versionId ?? this.versionId,
      subscribedVersionId: subscribedVersionId ?? this.subscribedVersionId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }

  // Safe Getters
  double get expectedReturnValue => double.tryParse(expectedReturn) ?? 0.0;
  int get subscriptionAmountValue => int.tryParse(subscriptionAmount) ?? 0;
  int get holdingsCount => holdings.length;

  bool get isFree => subscryptionType.toUpperCase() == 'FREE';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isDeliveryType => type.toUpperCase() == 'DELIVERY';
  bool get isBuyAction => action.toUpperCase() == 'BUY';

  // ✅ Helper: Clean floating point errors and round to 2 decimals
  double _cleanPrice(double value) {
    // Round to 2 decimal places to remove floating point errors
    return (value * 100).round() / 100;
  }

  // ✅ FIXED: Price getters - Return RAW unrounded values for calculation
  double get _rawInitialPrice {
    if (basketInitialPrice == null ||
        basketInitialPrice == 'null' ||
        basketInitialPrice == '' ||
        basketInitialPrice == 'NaN') {
      return 0.0;
    }
    final parsed = double.tryParse(basketInitialPrice!.trim());
    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return 0.0;
    }
    return _cleanPrice(parsed);
  }

  double get _rawCurrentPrice {
    if (basketCurrentPrice == null ||
        basketCurrentPrice == 'null' ||
        basketCurrentPrice == '') {
      return 0.0;
    }
    double parsed;
    if (basketCurrentPrice is num) {
      parsed = (basketCurrentPrice as num).toDouble();
    } else {
      final temp = double.tryParse(basketCurrentPrice.toString().trim());
      if (temp == null || temp.isNaN || temp.isInfinite) {
        return 0.0;
      }
      parsed = temp;
    }
    return _cleanPrice(parsed);
  }

  double get initialPriceValue => _rawInitialPrice.roundToDouble();
  double get currentPriceValue => _rawCurrentPrice.roundToDouble();

  double get priceChangePercentage {
    final initial = initialPriceValue;
    final current = currentPriceValue;

    // 1. Handle Division by Zero (Critical)
    // If we started at 0, we cannot calculate a percentage change.
    // Returns 0.0 to show "0%" change (or you could handle this in UI to show "N/A")
    if (initial <= 0) {
      return 0.0;
    }

    // 2. Handle Data Not Ready
    // If current price is missing/zero, we might not want to show -100%.
    // This check is optional: remove it if you WANT to show 100% loss when price is 0.
    if (current <= 0) {
      return 0.0;
    }

    // 3. The Math
    // We use the VISIBLE integers to calculate.
    // Formula: (Current - Initial) / Initial * 100
    final double change = current - initial;
    final double percentage = (change / initial) * 100;

    // 4. Safety Check
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

  // ✅ Performance uses the rounded percentage calculation
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
        id: _safeInt(json['ID'] ?? json['id']),
        isin: json['isin']?.toString() ?? '',
        token: _safeInt(json['token']),
        units: json['units']?.toString() ?? '1',
        exchId: json['exchId']?.toString() ?? 'NSE',
        symbol: json['symbol']?.toString() ?? '',
        slPrice: json['stopLossPrice']?.toString() ??
            json['slPrice']?.toString() ??
            '0',
        tgtPrice: json['targetPrice']?.toString() ??
            json['tgtPrice']?.toString() ??
            '0',
        stockId: _safeInt(json['stockId']),
        fullName: json['stockName']?.toString() ?? 'Unknown Stock',
        holdinPercentage: json['weightage']?.toString() ??
            json['holdinPercentage']?.toString() ??
            '0',
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
