import 'package:flutter/material.dart';

class MutualFundResponse {
  final bool status;
  final String message;
  final MutualFundData data;

  MutualFundResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MutualFundResponse.fromJson(Map<String, dynamic> json) {
    return MutualFundResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: MutualFundData.fromJson(json['data'] ?? {}),
    );
  }
}

class MutualFundData {
  final int totalRecords;
  final int totalPages;
  final String currentPage;
  final List<MutualFund> mfList; // Changed from usersList to mfList

  MutualFundData({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.mfList,
  });

  factory MutualFundData.fromJson(Map<String, dynamic> json) {
    return MutualFundData(
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? '0',
      mfList: (json['mfList'] as List<dynamic>?) // Changed from usersList to mfList
          ?.map((item) => MutualFund.fromJson(item))
          .toList() ??
          [],
    );
  }

  // Getter for backward compatibility if needed
  List<MutualFund> get usersList => mfList;
}

class MutualFund {
  final int id;
  final String amc;
  final String scheamName;
  final String scheamCode;
  final String? dayChange;
  final String? weekChange;
  final String? monthChange;
  final String? sixMonthChange;
  final String? oneYearChange;
  final String? threeYearsChange;
  final String? fiveYearsChange;
  final String? allTime;
  final dynamic mfData; // Added missing field
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final dynamic prodMfData; // Added missing field

  MutualFund({
    required this.id,
    required this.amc,
    required this.scheamName,
    required this.scheamCode,
    this.dayChange,
    this.weekChange,
    this.monthChange,
    this.sixMonthChange,
    this.oneYearChange,
    this.threeYearsChange,
    this.fiveYearsChange,
    this.allTime,
    this.mfData,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.prodMfData,
  });

  factory MutualFund.fromJson(Map<String, dynamic> json) {
    return MutualFund(
      id: json['id'] ?? 0,
      amc: json['amc'] ?? '',
      scheamName: json['scheamName'] ?? '',
      scheamCode: json['scheamCode'] ?? '',
      dayChange: json['dayChange'],
      weekChange: json['weekChange'],
      monthChange: json['monthChange'],
      sixMonthChange: json['sixMonthChange'],
      oneYearChange: json['oneYearChange'],
      threeYearsChange: json['threeYearsChange'],
      fiveYearsChange: json['fiveYearsChange'],
      allTime: json['allTime'],
      mfData: json['mfData'],
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'],
      prodMfData: json['prodMfData'],
    );
  }

  // Helper methods for better data access
  String get displayReturn => oneYearChange ?? 'N/A';

  bool get hasPositiveReturn {
    if (oneYearChange == null) return false;
    final numericValue = oneYearChange!.replaceAll('%', '');
    final doubleValue = double.tryParse(numericValue);
    return doubleValue != null && doubleValue > 0;
  }

  String get shortName {
    if (scheamName.length <= 50) return scheamName;
    return '${scheamName.substring(0, 47)}...';
  }
}

// Keep existing classes for UI compatibility
class AMC {
  final String name;
  final List<Scheme> schemes;

  AMC({
    required this.name,
    required this.schemes,
  });
}

class Scheme {
  final String name;
  final String rank;
  final String returnRate;
  final String risk;

  Scheme({
    required this.name,
    required this.rank,
    required this.returnRate,
    required this.risk,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scheme && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

class Fund {
  final String name;
  final String returnRate;
  final String risk;
  final Color color;

  Fund({
    required this.name,
    required this.returnRate,
    required this.risk,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fund && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}