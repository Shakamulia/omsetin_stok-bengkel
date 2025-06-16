import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:intl/intl.dart';

import 'package:omsetin_stok/model/category.dart';
import 'package:omsetin_stok/model/product.dart';
import 'package:omsetin_stok/providers/securityProvider.dart';

import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/failedAlert.dart';
import 'package:omsetin_stok/utils/modal_animation.dart';
import 'package:omsetin_stok/utils/navigation_utils.dart';
import 'package:omsetin_stok/utils/null_data_alert.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/utils/sort.dart';
import 'package:omsetin_stok/utils/successAlert.dart';
import 'package:omsetin_stok/view/page/product/add_product.dart';
import 'package:omsetin_stok/view/page/product/select_category.dart';
import 'package:omsetin_stok/view/page/product/update_product.dart';
import 'package:omsetin_stok/view/widget/Notfound.dart';
import 'package:omsetin_stok/view/widget/add_category_modal.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/confirm_delete_dialog.dart';
import 'package:omsetin_stok/view/widget/createCategoryModal.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_stok/view/widget/floating_button.dart';

import 'package:omsetin_stok/view/widget/refresWidget.dart';
import 'package:omsetin_stok/view/widget/search.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconify_flutter/icons/cil.dart';
import 'package:iconify_flutter/icons/eva.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:iconify_flutter/icons/wi.dart';
import 'package:lottie/lottie.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();

  static String formatCurrency(int amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
        .format(amount);
  }
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  // Deklarasi variabel _tabController untuk mengatur tab
  // Late berarti variabel ini akan diinisialisasi setelah deklarasi
  // Tipe data dari variabel ini adalah TabController
  late TabController _tabController;

  // initialize database service
  final DatabaseService _databaseService = DatabaseService.instance;

  late TextEditingController _searchController = TextEditingController();
  late TextEditingController _searchCategoryController =
      TextEditingController();

  final TextEditingController _categoryController = TextEditingController();

  // inisialisasi array untuk data data yang akan berubah ubah akan di simpan ke sini
  List<Product> _filteredProduct = [];
  List<Categories> _filteredCategories = [];

  String? _selectedCategory;

  Future<void> _pullRefresh() async {
    // Misalnya, memuat ulang data dari API
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // jika di tarik maka akan mengembalikan sort nya ke awal (berdasarkan kapan produk di tambahkan)
      _futureProducts = (_tabController.index == 0)
          ? (_selectedCategory == null
              ? fetchProductsSortedByDate("product_date_added", "asc", true)
              : fetchProductsByCategory(_selectedCategory ?? ''))
          : null;
      _futureCategories =
          (_tabController.index != 0) ? fetchCategories() : null;
    });
  }

  //! SECURITY
  bool? _isProductOn;
  bool? _isDeleteProductOn;
  bool? _isEditCategoryOn;
  bool? _isDeleteCategoryOn;
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isProductOn = prefs.getBool('tambahProduk') ?? false;
      _isDeleteProductOn = prefs.getBool('hapusProduk') ?? false;
      _isEditCategoryOn = prefs.getBool('editKategori') ?? false;
      _isDeleteCategoryOn = prefs.getBool('hapusKategori') ?? false;
    });
  }

  Future<List<Product>>? _futureProducts;
  Future<List<Categories>>? _futureCategories;

  Future<List<Product>> fetchProductsWithCategory() async {
    final productData = await _databaseService.getProducts();
    print("Fetched products: $productData");
    return productData;
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final productData = await _databaseService.getProductsByCategory(category);
    print("Fetched products by category: $productData");
    return productData;
  }

  Future<List<Product>> fetchProductsSorted(
      String column, String sortOrder, bool productOrCategory) async {
    // jika tidak ada category yang terpilih untuk memfilter data maka akan menggunakan fetchProductWithCategory namun jika ada akan menggunaakan fetchProductsByCategory()
    final productData = _selectedCategory == null
        ? await fetchProductsWithCategory()
        : await fetchProductsByCategory(_selectedCategory!);
    productData.sort((a, b) {
      var aValue = a.toJson()[column];
      var bValue = b.toJson()[column];
      if (sortOrder == 'asc') {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });
    print("Fetched products sorted: $productData");
    return productData;
  }

  Future<List<Product>> fetchProductsSortedByDate(
      String column, String sortOrder, bool productOrCategory) async {
    final productData = _selectedCategory == null
        ? await fetchProductsWithCategory()
        : await fetchProductsByCategory(_selectedCategory!);
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

  Future<List<Categories>> fetchCategories() async {
    final categoryData = await _databaseService.getCategory();
    return categoryData;
  }

  Future<void> _loadSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCategory = prefs.getString('selectedCategory');
      if (_selectedCategory == null) {
        _futureProducts = fetchProductsWithCategory();
      } else {
        _futureProducts = fetchProductsByCategory(_selectedCategory ?? '');
      }
    });
  }

  Future<void> _cancelCategoryFilter() async {
    // batalkan filter yang sudah dilakukan
    final prefs = await SharedPreferences.getInstance();
    // remove var 'selectedCategory' yang ada di cache
    await prefs.remove('selectedCategory');
    setState(() {
      _futureProducts = fetchProductsWithCategory();
      _selectedCategory = null;
    });
  }

  Future<void> _filterCategory() async {
    final selectedCategory = await navigateWithTransition(
      context,
      const SelectCategory(),
    );

    if (selectedCategory != null) {
      setState(() {
        _selectedCategory = selectedCategory;
        _saveSelectedCategory(selectedCategory);
        _futureProducts = fetchProductsByCategory(selectedCategory);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadSelectedCategory();

    _futureProducts = fetchProductsWithCategory();
    _futureCategories = fetchCategories();

    _filteredCategories.sort((a, b) =>
        DateTime.parse(b.dateAdded).compareTo(DateTime.parse(a.dateAdded)));
    _filteredProduct.sort((a, b) => DateTime.parse(b.productDateAdded)
        .compareTo(DateTime.parse(a.productDateAdded)));

    _searchController = TextEditingController();
    _searchController.addListener(_filterSearch);
    _searchCategoryController = TextEditingController();
    _searchCategoryController.addListener(_filterCategorySearch);
    // Inisialisasi TabController dengan 2 tab dan mendengarkan perubahan tab
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  //* PRODUK
  void _filterSearch() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _futureProducts = _selectedCategory == null
            ? fetchProductsWithCategory()
            : fetchProductsByCategory(_selectedCategory!);
      } else {
        _futureProducts = _selectedCategory == null
            ? fetchProductsWithCategory().then((products) {
                return products.where((product) {
                  return product.productName
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());
                }).toList();
              })
            : fetchProductsByCategory(_selectedCategory!).then((products) {
                return products.where((product) {
                  return product.productName
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());
                }).toList();
              });
      }
    });
  }

  //*  CATEGORIES
  void _filterCategorySearch() {
    setState(() {
      if (_searchCategoryController.text.isEmpty) {
        _futureCategories = fetchCategories();
      } else {
        _futureCategories = fetchCategories().then((categories) {
          return categories.where((category) {
            return category.categoryName
                .toLowerCase()
                .contains(_searchCategoryController.text.toLowerCase());
          }).toList();
        });
      }
    });
  }

  void _sortCategoriesByDate(bool newestFirst) {
    setState(() {
      sortItems(_filteredCategories,
          (kategori) => DateTime.parse(kategori.dateAdded), newestFirst);
    });
  }

  void _sortCategories(bool ascending) {
    setState(() {
      sortItems(
          _filteredCategories, (kategori) => kategori.categoryName, ascending);
    });
  }

  final FocusNode _categoryFocusNode = FocusNode();

  Future<void> _saveSelectedCategory(String? category) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("selectedCategory", category ?? '');
  }

  void _createCategory() {
    CreateCategoryModal.showCustomModal(
      context: context,
      controller: _categoryController,
      focusNode: _categoryFocusNode,
      title: 'Tambah Kategori',
      hintText: 'Nama Kategori',
      buttonText: 'SIMPAN',
      onSave: (categoryName) async {
        try {
          final _existingCategories = await _databaseService.getCategory();
          final _categoryExists = _existingCategories.any((category) =>
              category.categoryName.toLowerCase() ==
              categoryName.toLowerCase());

          if (_categoryExists) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showNullDataAlert(context, message: "Kategori sudah ada!");
            });
            return;
          }

          await _databaseService.addCategory(
              categoryName, DateTime.now().toIso8601String());

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSuccessAlert(context, "Kategori berhasil ditambahkan!");
          });
        } catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showFailedAlert(context, message: "Gagal menambahkan kategori: $e");
          });
        }

        setState(() {
          _categoryController.text = "";
          _futureCategories = fetchCategories();
        });
      },
    );
  }

  void _updateCategory(
      int categoryId, String categoryName, String categoryDateAdded) async {
    _categoryController.text = categoryName;

    CreateCategoryModal.showCustomModal(
      context: context,
      controller: _categoryController,
      focusNode: _categoryFocusNode,
      title: 'Update Kategori',
      hintText: 'Nama Kategori',
      buttonText: 'SIMPAN',
      onSave: (categoryName) async {
        if (categoryName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Nama kategori harus diisi!")),
          );
          return;
        }

        final updatedCategory = Categories(
          categoryId: categoryId,
          categoryName: categoryName,
          dateAdded: categoryDateAdded,
        );

        try {
          await _databaseService.updateCategory(updatedCategory);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kategori berhasil diperbarui!")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal memperbarui kategori: $e")),
          );
        }

        setState(() {
          _categoryController.text = "";
          _futureCategories = fetchCategories();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var securityProvider = Provider.of<SecurityProvider>(context);

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
                gradient: LinearGradient(colors: [
              secondaryColor,
              primaryColor,
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: AppBar(
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              leading: const CustomBackButton(),
              title: Text(
                'KELOLA PRODUK',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Expanded(
                          //   flex: 1,
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: _tabController.index == 0
                          //           ? primaryColor
                          //           : Colors.white,
                          //       foregroundColor: _tabController.index == 0
                          //           ? Colors.white
                          //           : Colors.black,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(30),
                          //         side: BorderSide(
                          //             color: _tabController.index == 0
                          //                 ? Colors.transparent
                          //                 : primaryColor),
                          //       ),
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 20, vertical: 12),
                          //       elevation: 0,
                          //     ),
                          //     onPressed: () {
                          //       setState(() {
                          //         _tabController.index = 0;
                          //       });
                          //     },
                          //     child: const Text("Produk"),
                          //   ),
                          // ),
                          // const Gap(10),
                          // Expanded(
                          //   flex: 1,
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: _tabController.index == 1
                          //           ? primaryColor
                          //           : Colors.white,
                          //       foregroundColor: _tabController.index == 1
                          //           ? Colors.white
                          //           : Colors.black,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(30),
                          //         side: BorderSide(
                          //             color: _tabController.index == 1
                          //                 ? Colors.transparent
                          //                 : primaryColor),
                          //       ),
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 20, vertical: 12),
                          //       elevation: 0,
                          //     ),
                          //     onPressed: () {
                          //       setState(() {
                          //         _tabController.index = 1;
                          //       });
                          //     },
                          //     child: const Text("Kategori"),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_tabController.index == 0)
                ProductToolBar(context)
              else
                CategoryToolBar(context),
              const Gap(10),
              if (_selectedCategory != null) const Gap(10),
              if (_selectedCategory != null)
                IndexedStack(
                  index: _tabController.index,
                  children: [
                    if (_tabController.index == 0)
                      GestureDetector(
                        onTap: _filterCategory,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            color: Colors.white,
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 00),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Iconify(
                                      Mdi.filter_outline,
                                    ),
                                    Row(
                                      children: [
                                        const Text("Filter : "),
                                        Text(_selectedCategory != null &&
                                                _selectedCategory!.length > 15
                                            ? "${_selectedCategory!.substring(0, 15)}..."
                                            : _selectedCategory ?? "")
                                      ],
                                    )
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _cancelCategoryFilter,
                                  child: const Iconify(
                                    Ic.sharp_close,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      controller: _tabController,
                      children: [
                        FutureBuilder<List<Product>>(
                          future: _futureProducts,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return CustomRefreshWidget(
                                onRefresh: _pullRefresh,
                                child: Center(
                                  child: Text("Error: ${snapshot.error}"),
                                ),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return CustomRefreshWidget(
                                onRefresh: _pullRefresh,
                                child: Center(
                                    child: NotFoundPage(
                                  title: _searchController.text == ""
                                      ? "Tidak ada Produk"
                                      : 'Tidak ada Produk dengan nama "${_searchController.text}"',
                                )),
                              );
                            } else {
                              _filteredProduct = snapshot.data!;
                              return CustomRefreshWidget(
                                onRefresh: _pullRefresh,
                                child: ListView.builder(
                                  itemCount: _filteredProduct.length,
                                  itemBuilder: (context, index) {
                                    final product = _filteredProduct[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 5.0),
                                      child: ZoomTapAnimation(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  UpdateProductPage(
                                                product: product,
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(0.0, 1.0);
                                                const end = Offset.zero;
                                                const curve = Curves.easeInOut;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
                                                var offsetAnimation =
                                                    animation.drive(tween);

                                                return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 500),
                                            ),
                                          );
                                          if (result != false) {
                                            if (_selectedCategory == null) {
                                              setState(() {
                                                _futureProducts =
                                                    fetchProductsWithCategory();
                                              });
                                            } else {
                                              setState(() {
                                                _futureProducts =
                                                    fetchProductsByCategory(
                                                        _selectedCategory!);
                                              });
                                            }
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: cardColor,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5.0,
                                                horizontal: 12.0),
                                            child: Row(
                                              children: [
                                                // Kolom untuk gambar dan stok
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Hero(
                                                        tag:
                                                            "productImage_${product.productId}",
                                                        child: Image.file(
                                                          File(product
                                                              .productImage
                                                              .toString()),
                                                          width: 53,
                                                          height: 53,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Image.asset(
                                                              "assets/products/no-image.png",
                                                              width: 80,
                                                              height: 80,
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    // const SizedBox(height: 4),
                                                    // Text(
                                                    //   "Stok: ${product.productStock}",
                                                    //   style: const TextStyle(
                                                    //     fontSize: 12,
                                                    //     color: Colors.black,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                const Gap(10),
                                                // Kolom untuk nama produk dan harga
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Nama produk
                                                      Text(
                                                        product.productName,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      // Harga produk
                                                      Text(
                                                        "${ProductPage.formatCurrency(product.productSellPrice.toInt())}",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Stok: ${product.productStock}",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Tombol delete
                                                if (_isDeleteProductOn != true)
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return ConfirmDeleteDialog(
                                                            message:
                                                                "Hapus produk ini?",
                                                            onConfirm:
                                                                () async {
                                                              await _databaseService
                                                                  .deleteProduct(
                                                                      product
                                                                          .productId);
                                                              Navigator.pop(
                                                                  context,
                                                                  true);
                                                              showSuccessAlert(
                                                                  context,
                                                                  "Berhasil Terhapus!");

                                                              if (_selectedCategory ==
                                                                  null) {
                                                                setState(() {
                                                                  _futureProducts =
                                                                      fetchProductsWithCategory();
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  _futureProducts =
                                                                      fetchProductsByCategory(
                                                                          _selectedCategory!);
                                                                });
                                                              }
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: const Iconify(
                                                      Bi.x_circle,
                                                      size: 24,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                        FutureBuilder<List<Categories>>(
                            future: _futureCategories,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                    child: CustomRefreshWidget(
                                  child: NotFoundPage(
                                    title: _searchCategoryController.text == ""
                                        ? "Tidak ada Kategori"
                                        : 'Tidak ada Kategori dengan nama "${_searchCategoryController.text}"',
                                  ),
                                ));
                              } else {
                                _filteredCategories = snapshot.data!;
                                return CustomRefreshWidget(
                                  child: ListView.builder(
                                    itemBuilder: (context, index) {
                                      final category =
                                          _filteredCategories[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          children: [
                                            if (index == 0) Gap(5),
                                            const Gap(5),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                foregroundColor: Colors.black,
                                                backgroundColor: cardColor,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 18,
                                                        horizontal: 17),
                                              ),
                                              onPressed:
                                                  _isEditCategoryOn != true
                                                      ? () => _updateCategory(
                                                          category.categoryId,
                                                          category.categoryName,
                                                          category.dateAdded)
                                                      : () {},
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      category.categoryName,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 17),
                                                    ),
                                                  ),
                                                  if (_isDeleteCategoryOn !=
                                                      true)
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return ConfirmDeleteDialog(
                                                                  message:
                                                                      "Hapus kategori ini?",
                                                                  onConfirm:
                                                                      () async {
                                                                    try {
                                                                      await _databaseService
                                                                          .deleteCategory(
                                                                              category.categoryName);

                                                                      Navigator.pop(
                                                                          context,
                                                                          true);

                                                                      showSuccessAlert(
                                                                          context,
                                                                          'Berhasil menghapus ${category.categoryName}');

                                                                      setState(
                                                                          () {
                                                                        _futureCategories =
                                                                            fetchCategories();
                                                                      });
                                                                    } catch (e) {
                                                                      showFailedAlert(
                                                                        context,
                                                                      );
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: const Iconify(
                                                            Bi.x_circle,
                                                            size: 24,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const Gap(5),
                                          ],
                                        ),
                                      );
                                    },
                                    itemCount: _filteredCategories.length,
                                  ),
                                );
                              }
                            }),
                      ],
                    ),
                    if (_tabController.index == 0)
                      ExpensiveFloatingButton(
                        text: 'TAMBAH',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddProductPage(),
                            ),
                          );

                          if (result == true) {
                            setState(() {
                              _futureProducts = fetchProductsWithCategory();
                            });
                          }
                        },
                      )
                    else
                      ExpensiveFloatingButton(
                        text: 'TAMBAH',
                        onPressed: () async {
                          final result = await createCategoryModal(
                            context: context,
                            productCreateCategoryController:
                                _categoryController,
                            categoryFocusNode: _categoryFocusNode,
                            databaseService: _databaseService,
                          );

                          if (result) {
                            setState(() {
                              _futureCategories = fetchCategories();
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ],
      ),
      // ),
      // ),
    );
  }

  Row ProductToolBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchTextField(
            prefixIcon: const Icon(Icons.search, size: 24),
            obscureText: false,
            hintText: "Cari Spare Part",
            controller: _searchController,
            maxLines: 1,
            suffixIcon: null,
            color: cardColor,
          ),
        ),
        const Gap(10),
        // Container(
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(30),
        //     color: cardColor,
        //   ),
        //   child: GestureDetector(
        //     onTap: _filterCategory,
        //     child: const Padding(
        //       padding: EdgeInsets.all(12.0),
        //       child: Column(
        //         children: [
        //           Iconify(Mdi.filter_outline, size: 24),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        const Gap(10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: cardColor,
          ),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: const Iconify(Cil.sort_alpha_up),
                            title: const Text("A-Z"),
                            onTap: () {
                              setState(() {
                                _futureProducts = fetchProductsSorted(
                                    'product_name', 'asc', true);
                              });
                              Navigator.pop(context);
                              _searchController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Iconify(Cil.sort_alpha_down),
                            title: const Text("Z-A"),
                            onTap: () {
                              setState(() {
                                _futureProducts = fetchProductsSorted(
                                    'product_name', 'desc', true);
                              });
                              Navigator.pop(context);
                              _searchController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Iconify(Eva.trending_up_fill),
                            title: const Text("Terlaris"),
                            onTap: () {
                              setState(() {
                                _futureProducts = fetchProductsSorted(
                                    "product_sold", 'desc', true);
                              });
                              Navigator.pop(context);
                              _searchController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Iconify(Eva.trending_down_fill),
                            title: const Text("Tidak Laris"),
                            onTap: () {
                              setState(() {
                                _futureProducts = fetchProductsSorted(
                                    "product_sold", 'asc', true);
                              });
                              Navigator.pop(context);
                              _searchController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Iconify(Bxs.hot),
                            title: const Text("Terbaru"),
                            onTap: () {
                              setState(() {
                                _futureProducts = fetchProductsSortedByDate(
                                    "product_date_added", 'desc', true);
                              });
                              Navigator.pop(context);
                              _searchController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Iconify(
                              Wi.snowflake_cold,
                            ),
                            title: const Text("Terlama"),
                            onTap: () {
                              setState(() {
                                _futureProducts = fetchProductsSortedByDate(
                                    "product_date_added", 'asc', true);
                              });
                              Navigator.pop(context);
                              _searchController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Iconify(Mdi.cash_100),
                            title: const Text("Termahal"),
                            onTap: () {
                              setState(() {
                                _futureProducts = fetchProductsSorted(
                                    "product_sell_price", 'desc', true);
                              });
                              Navigator.pop(context);
                              _searchController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Iconify(Mdi.cash_100),
                            title: const Text("Termurah"),
                            onTap: () {
                              setState(() {
                                _futureProducts = fetchProductsSorted(
                                    "product_sell_price", 'asc', true);
                              });
                              Navigator.pop(context);
                              _searchController.text = "";
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Iconify(Uil.sort, size: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row CategoryToolBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchTextField(
            prefixIcon: const Icon(Icons.search, size: 24),
            obscureText: false,
            hintText: "Cari Kategori",
            controller: _searchCategoryController,
            maxLines: 1,
            suffixIcon: null,
            color: cardColor,
          ),
        ),
        const Gap(10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: cardColor,
          ),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.sort_by_alpha),
                            title: const Text("A-Z"),
                            onTap: () {
                              _sortCategories(true);
                              Navigator.pop(context);
                              _searchCategoryController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.sort),
                            title: const Text("Z-A"),
                            onTap: () {
                              _sortCategories(false);
                              Navigator.pop(context);
                              _searchCategoryController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.sort_by_alpha),
                            title: const Text("Terbaru"),
                            onTap: () {
                              _sortCategoriesByDate(false);
                              Navigator.pop(context);
                              _searchCategoryController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.sort_by_alpha),
                            title: const Text("Terlama"),
                            onTap: () {
                              _sortCategoriesByDate(true);
                              Navigator.pop(context);
                              _searchCategoryController.text = "";
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: const Column(
                children: [
                  Iconify(Uil.sort, size: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddProductCategory extends StatelessWidget {
  const AddProductCategory({super.key, required this.addText, this.onPressed});

  final String addText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 120.0, vertical: 25.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              flex: 1,
              child: Iconify(
                MaterialSymbols.add,
                color: Colors.white,
                size: 20,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(addText,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
