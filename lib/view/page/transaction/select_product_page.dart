import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:omsetin_stok/model/category.dart';
import 'package:omsetin_stok/model/product.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/not_enough_stock_alert.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/view/page/qr_code_scanner.dart';
import 'package:omsetin_stok/view/page/transaction/transactions_page.dart';
import 'package:omsetin_stok/view/widget/Notfound.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/card_select_product.dart';
import 'package:omsetin_stok/view/widget/search.dart';

class SelectProductPage extends StatefulWidget {
  final List<Product> selectedProducts;
  const SelectProductPage({super.key, required this.selectedProducts});

  @override
  State<SelectProductPage> createState() => _SelectProductPageState();
}

class _SelectProductPageState extends State<SelectProductPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final DatabaseService _databaseService = DatabaseService.instance;
  String? barcodeProduct;

  // List untuk menyimpan produk yang dipilih
  final List<Product> _selectedProducts = [];
  List<Product> _filteredProduct = [];
  Future<List<Product>>? _futureProducts;
  List<Categories>? _categories;
  bool _isTabControllerInitialized = false;

  // Controller for the search TextField
  final TextEditingController _searchController = TextEditingController();

  Future<List<Product>> fetchProductsWithCategory() async {
    final productData = await _databaseService.getProducts();
    print("Fetched products: $productData");
    return productData;
  }

  Future<void> _initializeCategories() async {
    if (_categories != null) return;

    try {
      _categories = await _databaseService.getCategoriesSorted(
          "category_name", "ASC", true);

      if (!_isTabControllerInitialized &&
          _categories != null &&
          _categories!.isNotEmpty) {
        setState(() {
          _tabController =
              TabController(length: _categories!.length, vsync: this);
          _isTabControllerInitialized = true;
        });
      }
    } catch (e) {
      print("Error initializing categories: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _futureProducts = fetchProductsWithCategory();
    _initializeCategories();

    // Add listener to the search controller
    _searchController.addListener(() {
      setState(() {}); // Trigger a rebuild when the search text changes
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose(); // Dispose the search controller
    super.dispose();
  }

  double totalTransaksi = 0; // Variabel untuk menyimpan total transaksi

  // Fungsi untuk menerima data selectedProducts dari TransactionPage
  void updateSelectedProducts(List<Product> products) {
    setState(() {
      _selectedProducts.clear();
      _selectedProducts.addAll(products);
    });
  }

  // Panggil fungsi ini ketika kembali dari TransactionPage
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final List<Product>? updatedProducts =
        ModalRoute.of(context)?.settings.arguments as List<Product>?;
    if (updatedProducts != null) {
      updateSelectedProducts(updatedProducts);
    }
  }

  // Function to filter products based on search query
  List<Product> _filterProducts(List<Product> products, String query) {
    if (query.isEmpty) {
      return products; // Return all products if the search query is empty
    } else {
      return products
          .where((product) =>
              product.productName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrCodeScanner()),
    );

    if (result != null && mounted) {
      setState(() {
        barcodeProduct = result;
      });

      // Cari produk berdasarkan barcode
      List<Product> allProducts = await _databaseService.getProducts();
      Product? foundProduct = allProducts.firstWhere(
        (product) => product.productBarcode == barcodeProduct,
        orElse: () => throw Exception('Product not found'),
      );

      // Tambahkan ke selectedProducts yang dikirim ke TransactionPage
      setState(() {
        if (!widget.selectedProducts
            .any((p) => p.productId == foundProduct.productId)) {
          widget.selectedProducts.add(foundProduct);
        }
      });

      if (mounted) {
        // Optional: Kasih toast atau snackbar biar user tau
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${foundProduct.productName} berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TransaksiPage(
          selectedProducts: List.from(widget.selectedProducts),
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan lebar layar
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20)
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
                "PILIH Spare Part",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              toolbarHeight: kToolbarHeight + 20,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(), // Custom back button
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      // TextField Search Responsif
                      Expanded(
                        child: SearchTextField(
                            obscureText: false,
                            hintText: "Cari Spare Part",
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 24,
                            ),
                            controller: _searchController,
                            maxLines: 1,
                            suffixIcon: null,
                            color: cardColor),
                      ),

                      // Tombol Scan Responsif
                      const Gap(10),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: cardColor),
                        child: GestureDetector(
                          onTap: scanQRCode,
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Iconify(
                                  Bi.qr_code_scan,
                                  size: 24,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
              const Gap(10), // Add spacing between search bar and navbar

              // Navbar for switching between categories
              Container(
                height: 50, // Sesuaikan tinggi container
                decoration: BoxDecoration(
                  color: bgColor, // Warna latar belakang abu-abu muda
                  borderRadius: BorderRadius.circular(15), // Sudut melengkung
                ),
                child: FutureBuilder<List<Categories>>(
                  future: _databaseService.getCategoriesSorted(
                    "category_name",
                    "ASC",
                    true,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}"),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Tidak ada kategori"),
                      );
                    } else {
                      // Check if categories changed or controller needs initialization
                      if (_categories == null ||
                          _categories!.length != snapshot.data!.length) {
                        _categories = snapshot.data;
                        // Only initialize if not already done
                        if (!_isTabControllerInitialized &&
                            _categories != null) {
                          _tabController = TabController(
                            length: _categories!.length,
                            vsync: this,
                          );
                          _isTabControllerInitialized = true;
                        }
                      }

                      return _tabController == null
                          ? Center(child: CircularProgressIndicator())
                          : TabBar(
                              // indicatorPadding:
                              //     EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: secondaryColor, // Warna tab yang dipilih
                                borderRadius: BorderRadius.circular(
                                    15), // Sudut melengkung
                              ),
                              labelColor:
                                  Colors.white, // Warna teks tab yang dipilih
                              unselectedLabelColor: Colors
                                  .grey, // Warna teks tab yang tidak dipilih
                              labelStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              isScrollable:
                                  true, // Memungkinkan tab dapat di-scroll
                              // padding: EdgeInsets.symmetric(
                              //     vertical: 4), // Padding container
                              labelPadding: EdgeInsets.symmetric(
                                  horizontal: 24), // Padding antar tab
                              tabs: snapshot.data!.map((category) {
                                return Tab(text: category.categoryName);
                              }).toList(),
                              indicatorSize: TabBarIndicatorSize
                                  .tab, // Mengatur ukuran indikator mengikuti lebar tab
                            );
                    }
                  },
                ),
              ),

              // Content for each category
              Gap(10),
              Expanded(
                child: _tabController == null
                    ? Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<Categories>>(
                        future: _databaseService.getCategoriesSorted(
                          "category_name",
                          "ASC",
                          true,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text("Tidak ada kategori"),
                            );
                          } else {
                            return TabBarView(
                              controller: _tabController,
                              children: snapshot.data!.map((category) {
                                return FutureBuilder<List<Product>>(
                                  future:
                                      _databaseService.getProductsByCategory(
                                          category.categoryName),
                                  builder: (context, productSnapshot) {
                                    if (productSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (productSnapshot.hasError) {
                                      return Center(
                                        child: Text(
                                            "Error: ${productSnapshot.error}"),
                                      );
                                    } else if (!productSnapshot.hasData ||
                                        productSnapshot.data!.isEmpty) {
                                      return const Center(
                                        child: NotFoundPage(
                                          title:
                                              "Tidak Ada Spare Part Pada Kategori Ini!",
                                        ),
                                      );
                                    } else {
                                      // Filter products based on search query
                                      List<Product> filteredProducts =
                                          _filterProducts(productSnapshot.data!,
                                              _searchController.text);
                                      return ListView.builder(
                                        itemCount: filteredProducts.length,
                                        itemBuilder: (context, index) {
                                          final product =
                                              filteredProducts[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5.0, bottom: 5.0),
                                            child: CardSelectProduct(
                                              key: ValueKey(product.productId),
                                              productSellPrice: product
                                                  .productSellPrice
                                                  .toInt(),
                                              productImage:
                                                  product.productImage,
                                              dateAdded:
                                                  product.productDateAdded,
                                              productName: product.productName,
                                              productSold: product.productSold
                                                  .toString(),
                                              stock: product.productStock,
                                              category: product.categoryName
                                                  .toString(),
                                              productId: product.productId,
                                              isSelected: widget
                                                  .selectedProducts
                                                  .contains(product),
                                              onSelect: () {
                                                setState(() {
                                                  if (product.productStock <
                                                      1) {
                                                    showNotEnoughStock(context);
                                                  } else {
                                                    if (widget.selectedProducts
                                                        .contains(product)) {
                                                      widget.selectedProducts
                                                          .remove(product);
                                                    } else {
                                                      widget.selectedProducts
                                                          .add(product);
                                                    }
                                                    Navigator.pop(
                                                        context,
                                                        widget
                                                            .selectedProducts);
                                                  }
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}