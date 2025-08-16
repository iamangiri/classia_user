import 'package:flutter/material.dart';

class Sip {
  final int id;
  final Goal goal;
  final String frequency;
  final int periodMonths;
  final double monthlyAmount;
  final List<FundAllocation> funds;
  final TopUp? topUp;
  String status;

  Sip({
    required this.id,
    required this.goal,
    required this.frequency,
    required this.periodMonths,
    required this.monthlyAmount,
    required this.funds,
    this.topUp,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'goal': goal.toJson(),
    'frequency': frequency,
    'periodMonths': periodMonths,
    'monthlyAmount': monthlyAmount,
    'funds': funds.map((f) => f.toJson()).toList(),
    'topUp': topUp?.toJson(),
    'status': status,
  };

  factory Sip.fromJson(Map<String, dynamic> json) => Sip(
    id: json['id'],
    goal: Goal.fromJson(json['goal']),
    frequency: json['frequency'],
    periodMonths: json['periodMonths'],
    monthlyAmount: json['monthlyAmount'].toDouble(),
    funds: (json['funds'] as List)
        .map((f) => FundAllocation.fromJson(f))
        .toList(),
    topUp: json['topUp'] != null ? TopUp.fromJson(json['topUp']) : null,
    status: json['status'],
  );
}

class FundAllocation {
  final Fund fund;
  final double percentage;

  FundAllocation({required this.fund, required this.percentage});

  Map<String, dynamic> toJson() =>
      {'fund': fund.toJson(), 'percentage': percentage};

  factory FundAllocation.fromJson(Map<String, dynamic> json) => FundAllocation(
    fund: Fund.fromJson(json['fund']),
    percentage: json['percentage'].toDouble(),
  );
}

class TopUp {
  final String type;
  final double value;
  final bool enabled;

  TopUp({required this.type, required this.value, required this.enabled});

  Map<String, dynamic> toJson() =>
      {'type': type, 'value': value, 'enabled': enabled};

  factory TopUp.fromJson(Map<String, dynamic> json) => TopUp(
    type: json['type'],
    value: json['value'].toDouble(),
    enabled: json['enabled'],
  );
}

class Fund {
  final String name;
  final String returnRate;
  final String risk;
  final Color color;

  Fund(
      {required this.name,
        required this.returnRate,
        required this.risk,
        required this.color});

  Map<String, dynamic> toJson() => {
    'name': name,
    'returnRate': returnRate,
    'risk': risk,
    'color': color.value,
  };

  factory Fund.fromJson(Map<String, dynamic> json) => Fund(
    name: json['name'],
    returnRate: json['returnRate'],
    risk: json['risk'],
    color: Color(json['color']),
  );
}

class Goal {
  final int id;
  final String name;
  final IconData icon;
  double target; // Removed 'late final' to allow reassignment
  final double current;
  final double monthlyPayment;
  final Color color;
  final double progress;
  final String lottieAsset;

  Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.target,
    required this.current,
    required this.monthlyPayment,
    required this.color,
    required this.progress,
    required this.lottieAsset,
  });

  // Helper method to convert IconData to a storable format
  static Map<String, dynamic> _iconToJson(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
      'matchTextDirection': icon.matchTextDirection,
    };
  }

  // Helper method to convert stored format back to IconData
  static IconData _iconFromJson(Map<String, dynamic> iconData) {
    // Use a predefined map of common icons to avoid non-constant IconData
    final codePoint = iconData['codePoint'] as int;
    return _getIconFromCodePoint(codePoint);
  }

  // Map common icon code points to their IconData instances
  static IconData _getIconFromCodePoint(int codePoint) {
    const iconMap = {
      0xe5ca: Icons.star,
      0xe88a: Icons.home,
      0xe559: Icons.directions_car,
      0xe862: Icons.school,
      0xe8cc: Icons.local_hospital,
      0xe7fd: Icons.beach_access,
      0xe8d2: Icons.business,
      0xe890: Icons.work,
      0xe7ee: Icons.savings,
      0xe8b8: Icons.flight,
      0xe5d2: Icons.restaurant,
      0xe5c9: Icons.fitness_center,
      0xe896: Icons.shopping_cart,
      0xe5c3: Icons.child_care,
      0xe1b1: Icons.pets,
      0xe3e2: Icons.music_note,
      0xe06d: Icons.sports_esports,
      0xe430: Icons.camera_alt,
      0xe870: Icons.phone,
      0xe0b7: Icons.laptop,
    };

    return iconMap[codePoint] ?? Icons.star; // Default fallback
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': _iconToJson(icon),
    'target': target,
    'current': current,
    'monthlyPayment': monthlyPayment,
    'color': color.value,
    'progress': progress,
    'lottieAsset': lottieAsset,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'],
    name: json['name'],
    icon: json['icon'] is Map<String, dynamic>
        ? _iconFromJson(json['icon'])
        : _getIconFromCodePoint(json['icon'] as int), // Use the safe method
    target: json['target'].toDouble(),
    current: json['current'].toDouble(),
    monthlyPayment: json['monthlyPayment'].toDouble(),
    color: Color(json['color']),
    progress: json['progress'].toDouble(),
    lottieAsset: json['lottieAsset'],
  );
}

class AMC {
  final String name;
  final List<Scheme> schemes;

  AMC({required this.name, required this.schemes});
}

class Scheme {
  final String name;
  final String rank;
  final String returnRate;
  final String risk;

  Scheme(
      {required this.name,
        required this.rank,
        required this.returnRate,
        required this.risk});

  Fund toFund() => Fund(
    name: name,
    returnRate: returnRate,
    risk: risk,
    color: Colors.blueGrey,
  );
}

// SipExploreGoalGrid (Unchanged)
class ExploreGoal {
  final String name;
  final IconData? icon;
  final String description;
  final Color color;
  final String? lottieAsset;

  ExploreGoal(
      {required this.name,
        this.icon,
        required this.description,
        required this.color,
        this.lottieAsset});

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'color': color.value,
    'lottieAsset': lottieAsset,
  };

  factory ExploreGoal.fromJson(Map<String, dynamic> json) => ExploreGoal(
    name: json['name'],
    description: json['description'],
    color: Color(json['color']),
    lottieAsset: json['lottieAsset'],
  );

  Goal toGoal() => Goal(
    id: DateTime.now().millisecondsSinceEpoch,
    name: name,
    icon: icon ?? Icons.star,
    target: 0.0,
    current: 0.0,
    monthlyPayment: 0.0,
    color: color,
    progress: 0.0,
    lottieAsset: lottieAsset ?? 'assets/anim/sip_anim_1.json',
  );
}