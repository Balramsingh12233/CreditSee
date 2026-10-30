class LoanModel {
  final String applicationId;
  final String userPhone;
  final String userName;
  final String purpose;
  final double principalAmount;
  final int tenureDays;
  final double dailyInterestRate;
  final double processingFee;
  final double totalInterest;
  final double totalPayable;
  final String status;
  final int currentStep;
  final String statusMessage;
  final double offerAmount;
  final int offerTenureDays;
  final double offerPayable;
  final bool isOfferAccepted;
  final DateTime? createdAt;

  LoanModel({
    required this.applicationId,
    required this.userPhone,
    this.userName = '',
    this.purpose = 'Personal Needs',
    this.principalAmount = 30000,
    this.tenureDays = 40,
    this.dailyInterestRate = 0.01,
    this.processingFee = 3000,
    this.totalInterest = 2000,
    this.totalPayable = 32000,
    this.status = 'Under Review',
    this.currentStep = 2,
    this.statusMessage =
        "We're carefully reviewing your application to ensure everything is in order. Thank you for your patience.",
    this.offerAmount = 10000,
    this.offerTenureDays = 90,
    this.offerPayable = 10600,
    this.isOfferAccepted = true,
    this.createdAt,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      applicationId: json['applicationId']?.toString() ?? '#CS12323',
      userPhone: json['userPhone']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? 'Personal Needs',
      principalAmount: (json['principalAmount'] as num?)?.toDouble() ?? 30000.0,
      tenureDays: (json['tenureDays'] as num?)?.toInt() ?? 40,
      dailyInterestRate: (json['dailyInterestRate'] as num?)?.toDouble() ?? 0.01,
      processingFee: (json['processingFee'] as num?)?.toDouble() ?? 3000.0,
      totalInterest: (json['totalInterest'] as num?)?.toDouble() ?? 2000.0,
      totalPayable: (json['totalPayable'] as num?)?.toDouble() ?? 32000.0,
      status: json['status']?.toString() ?? 'Under Review',
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 2,
      statusMessage: json['statusMessage']?.toString() ??
          "We're carefully reviewing your application to ensure everything is in order. Thank you for your patience.",
      offerAmount: (json['offerAmount'] as num?)?.toDouble() ?? 10000.0,
      offerTenureDays: (json['offerTenureDays'] as num?)?.toInt() ?? 90,
      offerPayable: (json['offerPayable'] as num?)?.toDouble() ?? 10600.0,
      isOfferAccepted: json['isOfferAccepted'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'userPhone': userPhone,
      'userName': userName,
      'purpose': purpose,
      'principalAmount': principalAmount,
      'tenureDays': tenureDays,
      'dailyInterestRate': dailyInterestRate,
      'processingFee': processingFee,
      'totalInterest': totalInterest,
      'totalPayable': totalPayable,
      'status': status,
      'currentStep': currentStep,
      'statusMessage': statusMessage,
      'offerAmount': offerAmount,
      'offerTenureDays': offerTenureDays,
      'offerPayable': offerPayable,
      'isOfferAccepted': isOfferAccepted,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  LoanModel copyWith({
    String? applicationId,
    String? userPhone,
    String? userName,
    String? purpose,
    double? principalAmount,
    int? tenureDays,
    double? dailyInterestRate,
    double? processingFee,
    double? totalInterest,
    double? totalPayable,
    String? status,
    int? currentStep,
    String? statusMessage,
    double? offerAmount,
    int? offerTenureDays,
    double? offerPayable,
    bool? isOfferAccepted,
    DateTime? createdAt,
  }) {
    return LoanModel(
      applicationId: applicationId ?? this.applicationId,
      userPhone: userPhone ?? this.userPhone,
      userName: userName ?? this.userName,
      purpose: purpose ?? this.purpose,
      principalAmount: principalAmount ?? this.principalAmount,
      tenureDays: tenureDays ?? this.tenureDays,
      dailyInterestRate: dailyInterestRate ?? this.dailyInterestRate,
      processingFee: processingFee ?? this.processingFee,
      totalInterest: totalInterest ?? this.totalInterest,
      totalPayable: totalPayable ?? this.totalPayable,
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      statusMessage: statusMessage ?? this.statusMessage,
      offerAmount: offerAmount ?? this.offerAmount,
      offerTenureDays: offerTenureDays ?? this.offerTenureDays,
      offerPayable: offerPayable ?? this.offerPayable,
      isOfferAccepted: isOfferAccepted ?? this.isOfferAccepted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
