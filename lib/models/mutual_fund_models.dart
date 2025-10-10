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
  final List<MutualFund> mfList;

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
      mfList: (json['mfList'] as List<dynamic>?)
          ?.map((item) => MutualFund.fromJson(item))
          .toList() ??
          [],
    );
  }

  List<MutualFund> get usersList => mfList;
}

// NEW: Create a proper model for ProdMfData
class ProdMfData {
  final int id;
  final String schemeCode;
  final String fundCode;
  final String planName;
  final String schemeType;
  final String planType;
  final String planOpt;
  final String divOpt;
  final String amfiId;
  final String priIsin;
  final String? secIsin;
  final String amc;
  final bool isDeleted;

  ProdMfData({
    required this.id,
    required this.schemeCode,
    required this.fundCode,
    required this.planName,
    required this.schemeType,
    required this.planType,
    required this.planOpt,
    required this.divOpt,
    required this.amfiId,
    required this.priIsin,
    this.secIsin,
    required this.amc,
    required this.isDeleted,
  });

  factory ProdMfData.fromJson(Map<String, dynamic> json) {
    return ProdMfData(
      id: json['id'] ?? 0,
      schemeCode: json['schemeCode'] ?? '',
      fundCode: json['fundCode'] ?? '',
      planName: json['planName'] ?? '',
      schemeType: json['schemeType'] ?? '',
      planType: json['planType'] ?? '',
      planOpt: json['planOpt'] ?? '',
      divOpt: json['divOpt'] ?? '',
      amfiId: json['amfiId'] ?? '',
      priIsin: json['priIsin'] ?? '',
      secIsin: json['secIsin'],
      amc: json['amc'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
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
  final dynamic mfData;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final ProdMfData prodMfData; // Changed from dynamic to ProdMfData

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
    required this.prodMfData,
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
      prodMfData: ProdMfData.fromJson(json['prodMfData'] ?? {}), // Parse properly
    );
  }

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