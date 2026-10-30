class UserModel {
  final String? id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? dateOfBirth;
  final String? maritalStatus;
  final String? email;
  final String? pan;
  final num? monthlyIncome;
  final int creditScore;

  UserModel({
    this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.maritalStatus,
    this.email,
    this.pan,
    this.monthlyIncome,
    this.creditScore = 750,
  });

  String get fullName {
    final f = firstName?.trim() ?? '';
    final l = lastName?.trim() ?? '';
    if (f.isEmpty && l.isEmpty) return 'CreditSea User';
    return '$f $l'.trim();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      phone: json['phone']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      maritalStatus: json['maritalStatus']?.toString(),
      email: json['email']?.toString(),
      pan: json['pan']?.toString(),
      monthlyIncome: json['monthlyIncome'] as num?,
      creditScore: json['creditScore'] is int
          ? json['creditScore']
          : (int.tryParse(json['creditScore']?.toString() ?? '') ?? 750),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'maritalStatus': maritalStatus,
      'email': email,
      'pan': pan,
      'monthlyIncome': monthlyIncome,
      'creditScore': creditScore,
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? firstName,
    String? lastName,
    String? gender,
    String? dateOfBirth,
    String? maritalStatus,
    String? email,
    String? pan,
    num? monthlyIncome,
    int? creditScore,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      email: email ?? this.email,
      pan: pan ?? this.pan,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      creditScore: creditScore ?? this.creditScore,
    );
  }
}
