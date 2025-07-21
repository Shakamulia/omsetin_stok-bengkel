import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/model/services.dart'; // Changed from services.dart to service.dart
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/services/service_db_helper.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/not_enough_stock_alert.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/page/qr_code_scanner.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/card_select_product.dart';
import 'package:omzetin_bengkel/view/widget/card_select_services.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/search.dart';

class SelectProductPage extends StatefulWidget {
  final List<Product> selectedProducts;
  final List<Service> selectedServices; // Changed from Services to Service

  const SelectProductPage({
    super.key,
    required this.selectedProducts,
    required this.selectedServices,
  });

  @override
  State<SelectProductPage> createState() => _SelectProductPageState();
}

class _SelectProductPageState extends State<SelectProductPage> {
  // Removed SingleTickerProviderStateMixin since we're using index-based tabs now
  final DatabaseService _databaseService = DatabaseService.instance;
  final ServiceDatabaseHelper _serviceHelper = ServiceDatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchServicesController =
      TextEditingController();

  int _tabIndex = 0; // Using simple index instead of TabController
  List<Product> _selectedProducts = [];
  List<Service> _selectedServices = []; // Changed from Services to Service
  String? barcodeProduct;

  Future<List<Product>>? _futureProducts;
  Future<List<Service>>? _futureServices; // Changed from Services to Service

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(() => setState(() {}));
    _searchServicesController.addListener(() => setState(() {}));
  }

  void _initializeData() {
    _futureProducts = _databaseService.getProducts();
    _futureServices = _serviceHelper.getServices();
    _selectedProducts.addAll(widget.selectedProducts);
    _selectedServices.addAll(widget.selectedServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchServicesController.dispose();
    super.dispose();
  }

  // Filter methods remain the same but use Service instead of Services
  List<Product> _filterProducts(List<Product> products, String query) {
    return query.isEmpty
        ? products
        : products
            .where((p) =>
                p.productName.toLowerCase().contains(query.toLowerCase()))
            .toList();
  }

  List<Service> _filterServices(List<Service> services, String query) {
    // Changed parameter type
    return query.isEmpty
        ? services
        : services
            .where((s) =>
                s.serviceName.toLowerCase().contains(query.toLowerCase()))
            .toList(); // Changed to serviceName
  }

  // QR Code methods remain the same
  Future<void> _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrCodeScanner()),
    );
    if (result != null && mounted) {
      setState(() => barcodeProduct = result);
      await _handleScannedProduct();
    }
  }

  Future<void> _handleScannedProduct() async {
    try {
      final allProducts = await _databaseService.getProducts();
      final foundProduct = allProducts.firstWhere(
        (product) => product.productBarcode == barcodeProduct,
      );
      setState(() {
        if (!_selectedProducts
            .any((p) => p.productId == foundProduct.productId)) {
          _selectedProducts.add(foundProduct);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${foundProduct.productName} berhasil ditambahkan!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Produk tidak ditemukan!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  // Selection handlers updated for Service type
  void _onProductSelect(Product product) {
    setState(() {
      if (product.productStock < 1) {
        showNotEnoughStock(context);
      } else if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  void _onServiceSelect(Service service) {
    // Changed parameter type
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  void _onSavePressed() {
    Navigator.pop(context, {
      'products': _selectedProducts,
      'services': _selectedServices,
    });
  }

  // Simplified tab button builder
  Widget _buildTabButton(String title, int index) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _tabIndex = index),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
                color: isSelected ? Colors.transparent : primaryColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
        ),
        child: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab selector - simpler implementation without TabController
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTabButton("Produk", 1),
                    const Gap(10),
                    _buildTabButton("Layanan", 0),
                  ],
                ),
              ),

              // Search and QR code row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchTextField(
                        obscureText: false,
                        hintText:
                            _tabIndex == 1 ? "Cari Produk" : "Cari Layanan",
                        prefixIcon: const Icon(Icons.search, size: 24),
                        controller: _tabIndex == 1
                            ? _searchController
                            : _searchServicesController,
                        maxLines: 1,
                        suffixIcon: null,
                        color: cardColor,
                      ),
                    ),
                    const Gap(10),
                    if (_tabIndex == 1) ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: cardColor,
                        ),
                        child: GestureDetector(
                          onTap: _scanQRCode,
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Iconify(Bi.qr_code_scan, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Main content area
              Expanded(
                child:
                    _tabIndex == 1 ? _buildProductList() : _buildServiceList(),
              ),
            ],
          ),

          // Floating action button at bottom
          ExpensiveFloatingButton(
            text: _tabIndex == 1
                ? "Pilih Produk (${_selectedProducts.length})"
                : "Pilih Layanan (${_selectedServices.length})",
            onPressed: _onSavePressed,
          ),
        ],
      ),
    );
  }

  // AppBar remains similar but without TabBar in bottom
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 20),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [secondaryColor, primaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            title: Text(
              "PILIH PRODUK & LAYANAN",
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
            leading: const CustomBackButton(),
          ),
        ),
      ),
    );
  }

  // Product list builder
  Widget _buildProductList() {
    return FutureBuilder<List<Product>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError)
          return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: NotFoundPage(title: "Tidak Ada Produk!"));
        }

        final filteredProducts =
            _filterProducts(snapshot.data!, _searchController.text);
        return ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16),
              child: CardSelectProduct(
                key: ValueKey(product.productId),
                productSellPrice: product.productSellPrice.toInt(),
                productImage: product.productImage,
                dateAdded: product.productDateAdded,
                productName: product.productName,
                productSold: product.productSold.toString(),
                stock: product.productStock,
                productId: product.productId,
                isSelected: _selectedProducts.contains(product),
                onSelect: () => _onProductSelect(product),
              ),
            );
          },
        );
      },
    );
  }

  // Service list builder - updated for Service type
  Widget _buildServiceList() {
    return FutureBuilder<List<Service>>(
      future: _futureServices,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError)
          return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: NotFoundPage(title: "Tidak Ada Layanan!"));
        }

        final filteredServices =
            _filterServices(snapshot.data!, _searchServicesController.text);
        return ListView.builder(
          itemCount: filteredServices.length,
          itemBuilder: (context, index) {
            final service = filteredServices[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16),
              child: CardSelectService(
                key: ValueKey(service.serviceId), // Changed from servicesId
                servicePrice:
                    service.servicePrice, // Changed from servicesPrice
                serviceName: service.serviceName, // Changed from servicesName
                isSelected: _selectedServices.contains(service),
                onSelect: () => _onServiceSelect(service),
              ),
            );
          },
        );
      },
    );
  }
}
