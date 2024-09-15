import 'dart:convert';

class NavbarModel {
  final int id;
  final String icon;
  final String name;

  NavbarModel({
    required this.id,
    required this.icon,
    required this.name,
  });

  factory NavbarModel.fromRawJson(String str) =>
      NavbarModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NavbarModel.fromJson(Map<String, dynamic> json) => NavbarModel(
        id: json["id"],
        icon: json["icon"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "icon": icon,
        "name": name,
      };
}
