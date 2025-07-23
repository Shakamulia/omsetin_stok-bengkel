import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/model/services.dart';
import 'package:omzetin_bengkel/providers/securityProvider.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/services/service_db_helper.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/failedAlert.dart';
import 'package:omzetin_bengkel/utils/modal_animation.dart';
import 'package:omzetin_bengkel/utils/navigation_utils.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/utils/sort.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/page/product/add_product.dart';
import 'package:omzetin_bengkel/view/page/product/update_product.dart';
import 'package:omzetin_bengkel/view/page/service/add_service.dart';
import 'package:omzetin_bengkel/view/page/service/update_service.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/confirm_delete_dialog.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/floating_button.dart';
import 'package:omzetin_bengkel/view/widget/refresWidget.dart';
import 'package:omzetin_bengkel/view/widget/search.dart';
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
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService.instance;
  final ServiceDatabaseHelper _serviceHelper = ServiceDatabaseHelper();
  late TextEditingController _searchController = TextEditingController();
  late TextEditingController _searchServicesController =
      TextEditingController();

  List<Product> _filteredProduct = [];
  List<Service> _filteredServices = [];

  //! SECURITY
  bool? _isProductOn;
  bool? _isDeleteProductOn;
  bool? _isEditServicesOn;
  bool? _isDeleteServicesOn;

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isProductOn = prefs.getBool('tambahProduk') ?? false;
      _isDeleteProductOn = prefs.getBool('hapusProduk') ?? false;
      _isEditServicesOn = prefs.getBool('editServices') ?? false;
      _isDeleteServicesOn = prefs.getBool('hapusServices') ?? false;
    });
  }

  Future<List<Product>>? _futureProducts;
  Future<List<Service>>? _futureServices;

  Future<List<Product>> fetchProductsWithCategory() async {
    final productData = await _databaseService.getProducts();
    print("Fetched products: $productData");
    return productData;
  }

  Future<List<Product>> fetchProductsSorted(
      String column, String sortOrder) async {
    final productData = await fetchProductsWithCategory();
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
      String column, String sortOrder) async {
    final productData = await fetchProductsWithCategory();
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

  Future<List<Service>> fetchServices() async {
    final servicesData = await _databaseService.getServices();
    return servicesData;
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _futureProducts = (_tabController.index == 0)
          ? fetchProductsSortedByDate("product_date_added", "asc")
          : null;
      _futureServices = (_tabController.index != 0) ? fetchServices() : null;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();

    _futureProducts = fetchProductsWithCategory();
    _futureServices = fetchServices();

    _filteredServices.sort((a, b) =>
        DateTime.parse(b.dateAdded).compareTo(DateTime.parse(a.dateAdded)));
    _filteredProduct.sort((a, b) => DateTime.parse(b.productDateAdded)
        .compareTo(DateTime.parse(a.productDateAdded)));

    _searchController = TextEditingController();
    _searchController.addListener(_filterSearch);
    _searchServicesController = TextEditingController();
    _searchServicesController.addListener(_filterServicesSearch);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _filterSearch() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _futureProducts = fetchProductsWithCategory();
      } else {
        _futureProducts = fetchProductsWithCategory().then((products) {
          return products.where((product) {
            return product.productName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
          }).toList();
        });
      }
    });
  }

  void _filterServicesSearch() {
    setState(() {
      if (_searchServicesController.text.isEmpty) {
        _futureServices = fetchServices();
      } else {
        _futureServices = fetchServices().then((services) {
          return services.where((service) {
            return service.serviceName
                .toLowerCase()
                .contains(_searchServicesController.text.toLowerCase());
          }).toList();
        });
      }
    });
  }

  void _sortServicesByDate(bool newestFirst) {
    setState(() {
      sortItems(_filteredServices,
          (service) => DateTime.parse(service.dateAdded), newestFirst);
    });
  }

  void _sortServices(bool ascending) {
    setState(() {
      sortItems(_filteredServices, (service) => service.serviceName, ascending);
    });
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
                'KELOLA SPARE PART & LAYANAN',
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _tabController.index == 0
                                    ? primaryColor
                                    : Colors.white,
                                foregroundColor: _tabController.index == 0
                                    ? Colors.white
                                    : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                      color: _tabController.index == 0
                                          ? Colors.transparent
                                          : primaryColor),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                elevation: 0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _tabController.index = 0;
                                });
                              },
                              child: const Text("Spare Part"),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _tabController.index == 1
                                    ? primaryColor
                                    : Colors.white,
                                foregroundColor: _tabController.index == 1
                                    ? Colors.white
                                    : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                      color: _tabController.index == 1
                                          ? Colors.transparent
                                          : primaryColor),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                elevation: 0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _tabController.index = 1;
                                });
                              },
                              child: const Text("Layanan"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_tabController.index == 0)
                ProductToolBar(context)
              else
                ServicesToolBar(context),
              const Gap(10),
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
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return CustomRefreshWidget(
                                onRefresh: _pullRefresh,
                                child: Center(
                                    child: NotFoundPage(
                                  title: _searchController.text == ""
                                      ? "Tidak ada Spare Part"
                                      : 'Tidak ada Spare Part dengan nama "${_searchController.text}"',
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
                                      child: _isDeleteProductOn != true
                                          ? Slidable(
                                              key: ValueKey(product.productId),
                                              endActionPane: ActionPane(
                                                motion: const DrawerMotion(),
                                                extentRatio: 0.20,
                                                children: [
                                                  CustomSlidableAction(
                                                    onPressed: (context) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return ConfirmDeleteDialog(
                                                            message:
                                                                "Hapus Spare Part ini?",
                                                            onConfirm:
                                                                () async {
                                                              try {
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
                                                                setState(() {
                                                                  _futureProducts =
                                                                      fetchProductsWithCategory();
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
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    autoClose: true,
                                                    padding: EdgeInsets.zero,
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade400,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        color: Colors.white,
                                                        size: 28,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              child: ZoomTapAnimation(
                                                onTap: () async {
                                                  final result =
                                                      await Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context,
                                                              animation,
                                                              secondaryAnimation) =>
                                                          UpdateProductPage(
                                                        product: product,
                                                      ),
                                                      transitionsBuilder:
                                                          (context,
                                                              animation,
                                                              secondaryAnimation,
                                                              child) {
                                                        const begin =
                                                            Offset(0.0, 1.0);
                                                        const end = Offset.zero;
                                                        const curve =
                                                            Curves.easeInOut;

                                                        var tween = Tween(
                                                                begin: begin,
                                                                end: end)
                                                            .chain(CurveTween(
                                                                curve: curve));
                                                        var offsetAnimation =
                                                            animation
                                                                .drive(tween);

                                                        return SlideTransition(
                                                          position:
                                                              offsetAnimation,
                                                          child: FadeTransition(
                                                            opacity: animation,
                                                            child: child,
                                                          ),
                                                        );
                                                      },
                                                      transitionDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  500),
                                                    ),
                                                  );
                                                  if (result != false) {
                                                    setState(() {
                                                      _futureProducts =
                                                          fetchProductsWithCategory();
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: cardColor,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 12.0),
                                                    child: Row(
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              child: Hero(
                                                                tag:
                                                                    "productImage_${product.productId}",
                                                                child:
                                                                    Image.file(
                                                                  File(product
                                                                      .productImage
                                                                      .toString()),
                                                                  width: 80,
                                                                  height: 80,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
                                                                    return Image
                                                                        .asset(
                                                                      "assets/products/no-image.png",
                                                                      width: 80,
                                                                      height:
                                                                          80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const Gap(10),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                product
                                                                    .productName,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                "${ProductPage.formatCurrency(product.productSellPrice)}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              Text(
                                                                "Stok: ${product.productStock}",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : ZoomTapAnimation(
                                              onTap: () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) =>
                                                        UpdateProductPage(
                                                      product: product,
                                                    ),
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
                                                      const begin =
                                                          Offset(0.0, 1.0);
                                                      const end = Offset.zero;
                                                      const curve =
                                                          Curves.easeInOut;

                                                      var tween = Tween(
                                                              begin: begin,
                                                              end: end)
                                                          .chain(CurveTween(
                                                              curve: curve));
                                                      var offsetAnimation =
                                                          animation
                                                              .drive(tween);

                                                      return SlideTransition(
                                                        position:
                                                            offsetAnimation,
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
                                                  setState(() {
                                                    _futureProducts =
                                                        fetchProductsWithCategory();
                                                  });
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 12.0),
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
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
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Image
                                                                      .asset(
                                                                    "assets/products/no-image.png",
                                                                    width: 80,
                                                                    height: 80,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Gap(10),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              product
                                                                  .productName,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              "${ProductPage.formatCurrency(product.productSellPrice)}",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Stok: ${product.productStock}",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
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
                        FutureBuilder<List<Service>>(
                            future: _futureServices,
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
                                    title: _searchServicesController.text == ""
                                        ? "Tidak ada Layanan"
                                        : 'Tidak ada Layanan dengan nama "${_searchServicesController.text}"',
                                  ),
                                ));
                              } else {
                                _filteredServices = snapshot.data!;
                                return CustomRefreshWidget(
                                  child: ListView.builder(
                                    // Di bagian FutureBuilder<List<Services>>, ganti itemBuilder dengan ini:
                                    itemBuilder: (context, index) {
                                      final service = _filteredServices[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          children: [
                                            if (index == 0) Gap(5),
                                            const Gap(5),
                                            _isDeleteServicesOn != true
                                                ? Slidable(
                                                    key: ValueKey(
                                                        service.serviceName),
                                                    endActionPane: ActionPane(
                                                      motion:
                                                          const DrawerMotion(),
                                                      extentRatio: 0.20,
                                                      children: [
                                                        CustomSlidableAction(
                                                          onPressed: (context) {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return ConfirmDeleteDialog(
                                                                  message:
                                                                      "Hapus layanan ini?",
                                                                  onConfirm:
                                                                      () async {
                                                                    try {
                                                                      await _serviceHelper
                                                                          .deleteService(
                                                                              service.serviceId);
                                                                      Navigator.pop(
                                                                          context,
                                                                          true);
                                                                      showSuccessAlert(
                                                                          context,
                                                                          'Berhasil menghapus ${service.serviceName}');
                                                                      setState(
                                                                          () {
                                                                        _futureServices =
                                                                            fetchServices();
                                                                      });
                                                                    } catch (e) {
                                                                      showFailedAlert(
                                                                          context);
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          autoClose: true,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .red.shade400,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                            child: const Icon(
                                                              Icons
                                                                  .delete_outline_rounded,
                                                              color:
                                                                  Colors.white,
                                                              size: 28,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        foregroundColor:
                                                            Colors.black,
                                                        backgroundColor:
                                                            cardColor,
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 18,
                                                                horizontal: 17),
                                                      ),
                                                      onPressed:
                                                      () async {
                                                                  final result =
                                                                      await Navigator
                                                                          .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              UpdateServicesPage(
                                                                        services:
                                                                            service,
                                                                      ),
                                                                    ),
                                                                  );
                                                                  if (result ==
                                                                      true) {
                                                                    setState(
                                                                        () {
                                                                      _futureServices =
                                                                          fetchServices();
                                                                    });
                                                                  }
                                                                }
                                                              ,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  service
                                                                      .serviceName,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          17),
                                                                ),
                                                                Text(
                                                                  ProductPage
                                                                      .formatCurrency(
                                                                          service
                                                                              .servicePrice),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                      foregroundColor:
                                                          Colors.black,
                                                      backgroundColor:
                                                          cardColor,
                                                      elevation: 0,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 18,
                                                          horizontal: 17),
                                                    ),
                                                    onPressed:
                                                      () async {
                                                                final result =
                                                                    await Navigator
                                                                        .push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        UpdateServicesPage(
                                                                      services:
                                                                          service,
                                                                    ),
                                                                  ),
                                                                );
                                                                if (result ==
                                                                    true) {
                                                                  setState(() {
                                                                    _futureServices =
                                                                        fetchServices();
                                                                  });
                                                                }
                                                              }
                                                            ,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                service
                                                                    .serviceName,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        17),
                                                              ),
                                                              Text(
                                                                ProductPage
                                                                    .formatCurrency(
                                                                        service
                                                                            .servicePrice),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            const Gap(5),
                                          ],
                                        ),
                                      );
                                    },
                                    itemCount: _filteredServices.length,
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
                    if (!securityProvider.tambahServices)
                      ExpensiveFloatingButton(
                      text: 'TAMBAH',
                      onPressed: () async {
                        final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddServicePage(),
                        ),
                        );

                        if (result == true) {
                        setState(() {
                          _futureServices = fetchServices();
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
      ),
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
                                _futureProducts =
                                    fetchProductsSorted('product_name', 'asc');
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
                                _futureProducts =
                                    fetchProductsSorted('product_name', 'desc');
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
                                _futureProducts =
                                    fetchProductsSorted("product_sold", 'desc');
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
                                _futureProducts =
                                    fetchProductsSorted("product_sold", 'asc');
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
                                    "product_date_added", 'desc');
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
                                    "product_date_added", 'asc');
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
                                    "product_sell_price", 'desc');
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
                                    "product_sell_price", 'asc');
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

  Row ServicesToolBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchTextField(
            prefixIcon: const Icon(Icons.search, size: 24),
            obscureText: false,
            hintText: "Cari Layanan",
            controller: _searchServicesController,
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
                              _sortServices(true);
                              Navigator.pop(context);
                              _searchServicesController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.sort),
                            title: const Text("Z-A"),
                            onTap: () {
                              _sortServices(false);
                              Navigator.pop(context);
                              _searchServicesController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.sort_by_alpha),
                            title: const Text("Terbaru"),
                            onTap: () {
                              _sortServicesByDate(false);
                              Navigator.pop(context);
                              _searchServicesController.text = "";
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.sort_by_alpha),
                            title: const Text("Terlama"),
                            onTap: () {
                              _sortServicesByDate(true);
                              Navigator.pop(context);
                              _searchServicesController.text = "";
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
