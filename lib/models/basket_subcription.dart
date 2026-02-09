class BasketSubscriptionResponse {
  final BasketSubscriptionData data;
  final String message;
  final bool status;

  BasketSubscriptionResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory BasketSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return BasketSubscriptionResponse(
      data: BasketSubscriptionData.fromJson(json['data']),
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class BasketSubscriptionData {
  final List<BasketSubscription> baskets;
  final int total;

  BasketSubscriptionData({
    required this.baskets,
    required this.total,
  });

  factory BasketSubscriptionData.fromJson(Map<String, dynamic> json) {
    return BasketSubscriptionData(
      baskets: (json['baskets'] as List<dynamic>)
          .map((item) => BasketSubscription.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}

class BasketSubscription {
  final int subscriptionId;
  final int basketId;
  final String basketName;
  final String basketDescription;
  final String basketType;
  final String subscribedAt;
  final String expiresAt;
  final String subscriptionPeriod;
  final int subscriptionPrice;

  BasketSubscription({
    required this.subscriptionId,
    required this.basketId,
    required this.basketName,
    required this.basketDescription,
    required this.basketType,
    required this.subscribedAt,
    required this.expiresAt,
    required this.subscriptionPeriod,
    required this.subscriptionPrice,
  });

  factory BasketSubscription.fromJson(Map<String, dynamic> json) {
    return BasketSubscription(
      subscriptionId: json['subscriptionId'] ?? 0,
      basketId: json['basketId'] ?? 0,
      basketName: json['basketName'] ?? '',
      basketDescription: json['basketDescription'] ?? '',
      basketType: json['basketType'] ?? '',
      subscribedAt: json['subscribedAt'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      subscriptionPeriod: json['subscriptionPeriod'] ?? '',
      subscriptionPrice: json['subscriptionPrice'] ?? 0,
    );
  }

  // Helper to get formatted subscription period
  String get periodDisplayText {
    switch (subscriptionPeriod) {
      case 'MONTHLY':
        return 'Monthly';
      case 'YEARLY':
        return 'Yearly';
      case 'QUARTERLY':
        return 'Quarterly';
      default:
        return subscriptionPeriod;
    }
  }

  // Helper to get formatted price
  String get formattedPrice {
    return '₹${subscriptionPrice.toString()}';
  }

  // Helper to check if subscription is active
  bool get isActive {
    try {
      final expiryDate = DateTime.parse(expiresAt);
      return expiryDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Helper to get days remaining
  int get daysRemaining {
    try {
      final expiryDate = DateTime.parse(expiresAt);
      final now = DateTime.now();
      return expiryDate.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  // Helper to get formatted expiry date
  String get formattedExpiryDate {
    try {
      final expiryDate = DateTime.parse(expiresAt);
      return '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  // Helper to get formatted subscribed date
  String get formattedSubscribedDate {
    try {
      final subscribedDate = DateTime.parse(subscribedAt);
      return '${subscribedDate.day}/${subscribedDate.month}/${subscribedDate.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}