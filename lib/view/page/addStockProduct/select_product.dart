import 'package:flutter/material.dart';
import 'package:omsetin_bengkel/model/product.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/view/widget/Notfound.dart';
import 'package:omsetin_bengkel/view/widget/app_bar_stock.dart';
import 'package:omsetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_bengkel/view/widget/search.dart';
import 'package:omsetin_bengkel/view/widget/select_product_stock.dart'; // Import halaman baru

class SelectProduct extends StatefulWidget {
  final List<Product>? selectedProductStock;
  const SelectProduct({super.key, this.selectedProductStock});

  @override
  State<SelectProduct> createState() => _SelectProductState();
}

class _SelectProductState extends State<SelectProduct> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late List<Product> selectedProductStock;

  late TextEditingController _searchController = TextEditingController();
  List<Product> allProductStock = [];
  List<Product> filteredProductStock = [];

  @override
  void initState() {
    super.initState();
    selectedProductStock = widget.selectedProductStock ?? [];
    _searchController = TextEditingController();
    _searchController.addListener(_filterSearch);

    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final List<Product> products = await _databaseService.getProducts();
    setState(() {
      allProductStock = products;
      filteredProductStock = products;
    });
  }

  void _filterSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredProductStock = allProductStock;
      } else {
        filteredProductStock = allProductStock.where((product) {
          return product.productName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<List<Product>> _getProductData() async {
    final List<Product> products = await _databaseService.getProducts();
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Column(
            children: [
              AppBarStock(
                appBarText: "PILIH Spare Part",
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: SearchTextField(
                      prefixIcon: const Icon(Icons.search, size: 20),
                      obscureText: false,
                      hintText: "Cari Spare Part",
                      controller: _searchController,
                      maxLines: 1,
                      suffixIcon: null,
                      color: cardColor,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              Expanded(
                child: filteredProductStock.isEmpty
                    ? const NotFoundPage(title: "Tidak ada Spare Part!")
                    : ListView.builder(
                        itemCount: filteredProductStock.length,
                        itemBuilder: (context, index) {
                          final product = filteredProductStock[index];
                          final isSelected =
                              selectedProductStock.contains(product);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: SelectStockProductCard(
                              product: product,
                              isSelected: isSelected,
                              onSelect: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedProductStock.remove(product);
                                  } else {
                                    selectedProductStock.add(product);
                                  }
                                });
                              },
                              selectedProductStock: selectedProductStock,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          ExpensiveFloatingButton(
              left: 15,
              right: 15,
              text: "TAMBAH",
              onPressed: () {
                Navigator.pop(context, selectedProductStock);
              }),
        ],
      ),
    );
  }
}
