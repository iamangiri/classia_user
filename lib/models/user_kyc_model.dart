class AadhaarOtpResponse {
  final String transactionId;
  final int referenceId;

  AadhaarOtpResponse({required this.transactionId, required this.referenceId});

  factory AadhaarOtpResponse.fromJson(Map<String, dynamic> json) {
    return AadhaarOtpResponse(
      transactionId: json['transaction_id'] ?? '',
      referenceId: json['reference_id'] ?? 0,
    );
  }
}

class PanAadhaarStatusResponse {
  final bool isLinked;
  final String message;
  final String? linkedDate;

  PanAadhaarStatusResponse(
      {required this.isLinked, required this.message, this.linkedDate});

  factory PanAadhaarStatusResponse.fromJson(Map<String, dynamic> json) {
    return PanAadhaarStatusResponse(
      isLinked: json['is_linked'] ?? false,
      message: json['message'] ?? '',
      linkedDate: json['linked_date'],
    );
  }
}

class BankDetailsResponse {
  final int id;
  final String bankName;
  final String accountNo;
  final String holderName;
  final String ifscCode;
  final String branchName;
  final String accountType;

  BankDetailsResponse({
    required this.id,
    required this.bankName,
    required this.accountNo,
    required this.holderName,
    required this.ifscCode,
    required this.branchName,
    required this.accountType,
  });

  factory BankDetailsResponse.fromJson(Map<String, dynamic> json) {
    return BankDetailsResponse(
      id: json['id'] ?? 0,
      bankName: json['bankName'] ?? '',
      accountNo: json['accountNo'] ?? '',
      holderName: json['holderName'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      branchName: json['branchName'] ?? '',
      accountType: json['accountType'] ?? '',
    );
  }
}
