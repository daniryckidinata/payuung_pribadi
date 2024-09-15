import 'dart:convert';

class FinanceProductModel {
  final String icon;
  final String name;

  FinanceProductModel({
    required this.icon,
    required this.name,
  });

  factory FinanceProductModel.fromRawJson(String str) =>
      FinanceProductModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FinanceProductModel.fromJson(Map<String, dynamic> json) =>
      FinanceProductModel(
        icon: json["icon"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "name": name,
      };
}
