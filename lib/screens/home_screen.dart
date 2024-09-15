import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:payuung_pribadi/models/finance_product_model.dart';
import 'package:payuung_pribadi/models/merchant_product_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payuung_pribadi/models/navbar_model.dart';
import 'package:payuung_pribadi/models/user_model.dart';
import 'package:payuung_pribadi/screens/personal_information_screen.dart';
import 'package:payuung_pribadi/utils/merchant_preferences.dart';
import 'package:payuung_pribadi/utils/user_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel _userModel = UserModel.initial();
  List<FinanceProductModel> _financeProducts = [];
  List<MerchantProductModel> _featuredCategories = [];
  List<MerchantProductModel> _merchantProducts = [];
  List<NavbarModel> _navbars = [];
  final _sheet = GlobalKey();
  final _controller = DraggableScrollableController();

  @override
  void initState() {
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _financeProducts = await loadJsonFinanceProducts();
        _merchantProducts = await MerchantPrefences.getProductList();
        _featuredCategories = _getUniqueCategoryProducts(_merchantProducts);
        _navbars = await loadNavbars();
        _userModel = await UserPreferences.getUserModel();

        setState(() {});
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<List<FinanceProductModel>> loadJsonFinanceProducts() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/finance_products.json');
    final jsonData = json.decode(jsonString);
    List<FinanceProductModel> results = (jsonData as List)
        .map(
          (e) => FinanceProductModel.fromJson(e),
        )
        .toList();

    return results;
  }

  List<MerchantProductModel> _getUniqueCategoryProducts(
      List<MerchantProductModel> products) {
    Set<int> uniqueCategoryIds = {};
    List<MerchantProductModel> uniqueProducts = [];

    for (var product in products) {
      if (!uniqueCategoryIds.contains(product.categoryId)) {
        uniqueCategoryIds.add(product.categoryId);
        uniqueProducts.add(product);
      }
    }

    return uniqueProducts;
  }

  Future<List<NavbarModel>> loadNavbars() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/navbars.json');
    final jsonData = json.decode(jsonString);
    List<NavbarModel> results = (jsonData as List)
        .map(
          (e) => NavbarModel.fromJson(e),
        )
        .toList();

    return results;
  }

  void _onChanged() {
    final currentSize = _controller.size;
    if (currentSize <= 0.05) _collapse();
  }

  void _collapse() => _animateSheet(sheet.snapSizes!.first);

  void _animateSheet(double size) {
    _controller.animateTo(
      size,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  DraggableScrollableSheet get sheet =>
      (_sheet.currentWidget as DraggableScrollableSheet);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Siang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _userModel.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PersonalInformationScreen(
                                  userModel: _userModel,
                                ),
                              )).then(
                            (_) async {
                              _userModel = await UserPreferences.getUserModel();
                              setState(() {});
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Text(
                            _userModel.fullName[0],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Produk Keuangan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.97,
                            ),
                            itemCount: _financeProducts.length,
                            itemBuilder: (context, index) {
                              FinanceProductModel item =
                                  _financeProducts[index];
                              return Column(
                                children: [
                                  SvgPicture.asset(
                                    item.icon,
                                    height: 30,
                                    width: 30,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.name,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Kategori Pilihan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.97,
                            ),
                            itemCount: _featuredCategories.length,
                            itemBuilder: (context, index) {
                              MerchantProductModel item =
                                  _featuredCategories[index];
                              return Column(
                                children: [
                                  SvgPicture.asset(
                                    item.categoryIcon,
                                    height: 30,
                                    width: 30,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.categoryName,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Explore Wellness',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.97,
                            ),
                            itemCount: _merchantProducts.length,
                            itemBuilder: (context, index) {
                              MerchantProductModel item =
                                  _merchantProducts[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    child: Image.network(
                                      item.imageUrl,
                                      height: 100,
                                      width: 100,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.name),
                                  const SizedBox(height: 4),
                                  Text(item.price),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DraggableScrollableSheet(
              key: _sheet,
              initialChildSize: 0.12,
              maxChildSize: 0.5,
              minChildSize: 0,
              expand: true,
              snap: true,
              snapSizes: const [
                0.12,
                0.5,
              ],
              controller: _controller,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0.5,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(24),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.97,
                          ),
                          itemCount: _navbars.length,
                          itemBuilder: (context, index) {
                            NavbarModel item = _navbars[index];
                            return Column(
                              children: [
                                SvgPicture.asset(
                                  item.icon,
                                  height: 30,
                                  width: 30,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.name,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
