import 'package:flutter/material.dart';
import 'package:omzetin_bengkel/model/category.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  Future<List<Categories>> _futureCategories = Future.value([]);

  Future<List<Categories>> get futureCategories => _futureCategories;

  Future<List<Categories>> fetchCategoriesSortedByDate(
      String column, String sortOrder) async {
    final categoryData = await _futureCategories;
    categoryData.sort((a, b) {
      var aValue = DateTime.parse(a.toJson()[column]);
      var bValue = DateTime.parse(b.toJson()[column]);
      if (sortOrder == 'asc') {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });
    print("Fetched categories sorted: $categoryData");
    return categoryData;
  }

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    notifyListeners();
  }

  Future<void> refreshCategories() async {
    await loadCategories();
  }
}
