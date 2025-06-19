import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:omsetin_bengkel/model/product.dart';
import 'package:omsetin_bengkel/model/services.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/not_enough_stock_alert.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/view/page/qr_code_scanner.dart';
import 'package:omsetin_bengkel/view/widget/Notfound.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/card_select_product.dart';
import 'package:omsetin_bengkel/view/widget/card_select_services.dart';
import 'package:omsetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_bengkel/view/widget/search.dart';

class SelectProductPage extends StatefulWidget {
  final List<Product> selectedProducts;
  final List<Service> selectedServices;

  const SelectProductPage({
    super.key,
    required this.selectedProducts,
    required this.selectedServices,
  });

  @override
  State<SelectProductPage> createState() => _SelectProductPageState();
}

class _SelectProductPageState extends State<SelectProductPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  late final TextEditingController _searchServicesController;
  final DatabaseService _databaseService = DatabaseService.instance;

  final List<Product> _selectedProducts = [];
  final List<Service> _selectedServices = [];
  String? barcodeProduct;

  Future<List<Product>>? _futureProducts;
  Future<List<Service>>? _futureServices;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupControllers();
  }

  void _initializeData() {
    _futureProducts = _databaseService.getProducts();
    _futureServices = _databaseService.getServices() as Future<List<Service>>?;
    _selectedProducts.addAll(widget.selectedProducts);
    _selectedServices.addAll(widget.selectedServices);
  }

  void _setupControllers() {
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
    _searchServicesController = TextEditingController();

    _searchController.addListener(() => setState(() {}));
    _searchServicesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchServicesController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products, String query) {
    return query.isEmpty
        ? products
        : products
            .where((p) =>
                p.productName.toLowerCase().contains(query.toLowerCase()))
            .toList();
  }

  List<Service> _filterServices(List<Service> service, String query) {
    return query.isEmpty
        ? service
        : service
            .where((s) =>
                s.serviceName.toLowerCase().contains(query.toLowerCase()))
            .toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProductTab(),
            _buildServiceTab(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight + 20),
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
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Produk'),
                Tab(text: 'Layanan'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildProductSearchRow(),
          const Gap(10),
          Expanded(child: _buildProductList()),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildProductSearchRow() {
    return Row(
      children: [
        Expanded(
          child: SearchTextField(
            obscureText: false,
            hintText: "Cari Produk",
            prefixIcon: const Icon(Icons.search, size: 24),
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
            onTap: _scanQRCode,
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Iconify(Bi.qr_code_scan, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return FutureBuilder<List<Product>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

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
              padding: const EdgeInsets.symmetric(vertical: 5.0),
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

  Widget _buildServiceTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildServiceSearchRow(),
          const Gap(10),
          Expanded(child: _buildServiceList()),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildServiceSearchRow() {
    return Row(
      children: [
        Expanded(
          child: SearchTextField(
            obscureText: false,
            hintText: "Cari Layanan",
            prefixIcon: const Icon(Icons.search, size: 24),
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
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child:
                Iconify(Bi.qr_code_scan, size: 24, color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceList() {
    return FutureBuilder<List<Service>>(
      future: _futureServices,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

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
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: CardSelectService(
                key: ValueKey(service.serviceId),
                servicePrice: service.servicePrice,
                serviceName: service.serviceName,
                isSelected: _selectedServices.contains(service),
                onSelect: () => _onServiceSelect(service),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return ExpensiveFloatingButton(
      text: 'SIMPAN',
      onPressed: _onSavePressed,
      left: 15,
      right: 15,
      bottom: 15,
    );
  }
}
