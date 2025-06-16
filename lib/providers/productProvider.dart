import 'package:flutter/material.dart';
import 'package:omsetin_stok/model/product.dart';
import 'package:omsetin_stok/services/database_service.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  Future<List<Product>> _futureProducts = Future.value([]);

  Future<List<Product>> get futureProducts => _futureProducts;

  Future<List<Product>> fetchProductsSortedByDate(
      String column, String sortOrder, bool productOrCategory) async {
    final productData = await _futureProducts;
    productData.sort((a, b) {
      var aValue = DateTime.parse(a.toJson()[column]);
      var bValue = DateTime.parse(b.toJson()[column]);
      if (sortOrder == 'asc') {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });
    print("Fetched products sorted: $productData");
    return productData;
  }

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _futureProducts = _databaseService.getProducts();
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }
}
