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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon.codePoint,
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
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
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