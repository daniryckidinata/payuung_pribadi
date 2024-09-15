import 'dart:convert';

class UserModel {
  final String fullName;
  final DateTime birthDate;
  final String gender;
  final String ktp;
  final String position;

  UserModel({
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.ktp,
    required this.position,
  });

  factory UserModel.initial() {
    return UserModel(
      fullName: 'Dani Rycki Dinata',
      birthDate: DateTime(1998, 09, 05),
      gender: 'Laki-laki',
      ktp: '',
      position: 'Developer',
    );
  }

  UserModel copyWith({
    String? fullName,
    DateTime? birthDate,
    String? gender,
    String? ktp,
    String? position,
  }) =>
      UserModel(
        fullName: fullName ?? this.fullName,
        birthDate: birthDate ?? this.birthDate,
        gender: gender ?? this.gender,
        ktp: ktp ?? this.ktp,
        position: position ?? this.position,
      );

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        fullName: json["full_name"],
        birthDate: DateTime.parse(json["birth_date"]),
        gender: json["gender"],
        ktp: json["ktp"],
        position: json["position"],
      );

  Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "birth_date": birthDate.toIso8601String(),
        "gender": gender,
        "ktp": ktp,
        "position": position,
      };
}
