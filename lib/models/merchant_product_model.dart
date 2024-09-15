import 'dart:convert';

class MerchantProductModel {
  final int id;
  final String imageUrl;
  final String name;
  final String price;
  final int categoryId;
  final String categoryIcon;
  final String categoryName;

  MerchantProductModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.categoryIcon,
    required this.categoryName,
  });

  factory MerchantProductModel.fromRawJson(String str) =>
      MerchantProductModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MerchantProductModel.fromJson(Map<String, dynamic> json) =>
      MerchantProductModel(
        id: json["id"],
        imageUrl: json["imageUrl"],
        name: json["name"],
        price: json["price"],
        categoryId: json["categoryId"],
        categoryIcon: json["categoryIcon"],
        categoryName: json["categoryName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "imageUrl": imageUrl,
        "name": name,
        "price": price,
        "categoryId": categoryId,
        "categoryIcon": categoryIcon,
        "categoryName": categoryName,
      };
}
