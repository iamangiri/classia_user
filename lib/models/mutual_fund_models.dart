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
  final List<MutualFund> usersList;

  MutualFundData({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.usersList,
  });

  factory MutualFundData.fromJson(Map<String, dynamic> json) {
    return MutualFundData(
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? '0',
      usersList: (json['usersList'] as List<dynamic>?)
          ?.map((item) => MutualFund.fromJson(item))
          .toList() ??
          [],
    );
  }
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
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

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
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
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
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'],
    );
  }
}
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
}