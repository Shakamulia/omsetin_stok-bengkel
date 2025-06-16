import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/category.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/utils/search_utils.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/search.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:omsetin_stok/utils/sort.dart';

class SelectCategory extends StatefulWidget {
  const SelectCategory({super.key});

  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController _searchController = TextEditingController();
  List<Categories> _filteredCategories = [];

  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      fetchCategories();
      _sortProductsByDate(true);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _sortProductsByDate(true);
    _searchController.addListener(_searchCategories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchCategories);
    _searchController.dispose();
    super.dispose();
  }

  void _searchCategories() {
    setState(() {
      if (_searchController.text.isEmpty) {
        fetchCategories();
      } else {
        _filteredCategories = filterItems(_filteredCategories,
            _searchController.text, (category) => category.categoryName);
      }
    });
  }

  //  void _filterSearch() {
  //   setState(() {
  //     _filteredProduct = filterItems(itemProduk, _searchController.text,
  //         (itemProduk) => itemProduk.productName);
  //   });
  // }

  void _sortProductsByDate(bool newestFirst) {
    setState(() {
      sortItems(_filteredCategories,
          (categories) => DateTime.parse(categories.dateAdded), newestFirst);
    });
  }

  Future<void> fetchCategories() async {
    final categories = await _databaseService.getCategory();
    print("Fetched categories: $categories");
    setState(() {
      _filteredCategories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
                        decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor,
                  primaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              )
            ),
            child: AppBar(
              title: Text(
                "PILIH KATEGORI UNTUK PRODUK",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_title1(context),
                  color: bgColor,
                ),
              ),
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              leading: CustomBackButton(),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Column(
          children: [
            const Gap(20),
            SearchTextField(
              prefixIcon: const Icon(Icons.search, size: 24),
              obscureText: false,
              hintText: "Search",
              controller: _searchController,
              maxLines: 1,
              suffixIcon: null,
              color: cardColor,
            ),
            const Gap(15),
            Expanded(
              child: LiquidPullToRefresh(
                onRefresh: _pullRefresh,
                height: 150.0,
                showChildOpacityTransition: false,
                backgroundColor: primaryColor,
                color: Colors.transparent,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const Gap(7),
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _filteredCategories[index]
                                              .categoryName
                                              .length >
                                          17
                                      ? '${_filteredCategories[index].categoryName.substring(0, 17)}...'
                                      : _filteredCategories[index].categoryName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  // day month (january) year
                                  DateFormat('dd MMMM yyyy', 'en_US').format(
                                    DateTime.parse(
                                      _filteredCategories[index].dateAdded,
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(
                                context,
                                _filteredCategories[index].categoryName,
                              );
                            },
                          ),
                        ),
                        const Gap(5),
                      ],
                    );
                  },
                  itemCount: _filteredCategories.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
