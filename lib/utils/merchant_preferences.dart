import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:payuung_pribadi/models/merchant_product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantPrefences {
  static const String _productsKey = 'merchantProducts';

  static Future<void> saveProductList(
      List<MerchantProductModel> products) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> productsJsonList =
        products.map((product) => product.toRawJson()).toList();
    await prefs.setStringList(_productsKey, productsJsonList);
  }

  static Future<List<MerchantProductModel>> getProductList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? productsJsonList = prefs.getStringList(_productsKey);

    if (productsJsonList != null) {
      return productsJsonList
          .map((productJson) => MerchantProductModel.fromRawJson(productJson))
          .toList();
    } else {
      return await _loadJsonMerchantProducts();
    }
  }

  static Future<void> removeProductList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productsKey);
  }

  static Future<List<MerchantProductModel>> _loadJsonMerchantProducts() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/merchant_products.json');
    final jsonData = json.decode(jsonString);
    List<MerchantProductModel> results = (jsonData as List)
        .map(
          (e) => MerchantProductModel.fromJson(e),
        )
        .toList();

    return results;
  }
}
