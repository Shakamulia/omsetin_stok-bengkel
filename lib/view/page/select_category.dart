import 'package:flutter/material.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/app_bar_stock.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/search.dart';

class SelectCategory extends StatefulWidget {
  final List<String>? selectedCategories;

  const SelectCategory({super.key, this.selectedCategories});

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late List<String> selectedCategories;

  late TextEditingController _searchController = TextEditingController();
  List<String> allCategories = [];
  List<String> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.selectedCategories ?? [];
    _searchController = TextEditingController();
    _searchController.addListener(_filterSearch);
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await _databaseService.getAllCategoryNames();
    setState(() {
      allCategories = categories;
      filteredCategories = categories;
    });
  }

  void _filterSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCategories = allCategories;
      } else {
        filteredCategories = allCategories
            .where((category) => category.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppBarStock(
                  appBarText: "Pilih Kategori",
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: SearchTextField(
                        prefixIcon: const Icon(Icons.search, size: 20),
                        obscureText: false,
                        hintText: "Cari Kategori",
                        controller: _searchController,
                        maxLines: 1,
                        suffixIcon: null,
                        color: cardColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Expanded(
                  child: filteredCategories.isEmpty
                      ? const NotFoundPage(title: "Tidak ada kategori!")
                      : ListView.builder(
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            final isSelected =
                                selectedCategories.contains(category);
                            return ListTile(
                              title: Text(category),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: primaryColor)
                                  : null,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedCategories.remove(category);
                                  } else {
                                    selectedCategories.add(category);
                                  }
                                });
                              },
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
                Navigator.pop(context, selectedCategories);
              },
            ),
          ],
        ),
      ),
    );
  }
}
