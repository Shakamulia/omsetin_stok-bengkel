import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/model/services.dart';
import 'package:omzetin_bengkel/model/pelanggan.dart';
import 'package:omzetin_bengkel/model/mekanik.dart';
import 'package:omzetin_bengkel/providers/mekanikProvider.dart';
import 'package:omzetin_bengkel/providers/pelangganprovider.dart';
import 'package:omzetin_bengkel/providers/mekanikProvider.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/alert.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/page/transaction/checkout_page.dart';
import 'package:omzetin_bengkel/view/page/transaction/select_mekanik_page.dart';
import 'package:omzetin_bengkel/view/page/transaction/select_product_page.dart';
import 'package:omzetin_bengkel/view/page/transaction/select_customer_page.dart';
import 'package:omzetin_bengkel/view/widget/antrian.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/card_transaction.dart';
import 'package:omzetin_bengkel/view/widget/card_transaction_services.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionPage extends StatefulWidget {
  final List<dynamic> selectedItems;
  final Map<int, int>? initialQuantities;
  final int? transactionId;
  final bool isUpdate;
  final Pelanggan? selectedCustomer;
  final Mekanik? selectedEmployee;
  final DateTime? lastTransactionDate;

  const TransactionPage({
    super.key,
    required this.selectedItems,
    this.initialQuantities,
    this.transactionId,
    this.lastTransactionDate,
    this.isUpdate = false,
    this.selectedCustomer,
    this.selectedEmployee,
  });

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final Map<int, int> _productQuantities = {};
  final Map<int, int> _serviceQuantities = {};
  double totalTransaksi = 0;
  int queueNumber = 1;
  bool isAutoReset = false;
  bool nonActivateQueue = false;
  final DatabaseService databaseService = DatabaseService.instance;
  Pelanggan? _selectedCustomer;
  Mekanik? _selectedEmployee;
  DateTime? lastTransactionDate;
  bool _isLoadingEmployee = false;
  bool _isLoadingCustomer = false;

  List<Product> get selectedProducts =>
      widget.selectedItems.whereType<Product>().toList();
  List<Service> get selectedServices =>
      widget.selectedItems.whereType<Service>().toList();

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.selectedCustomer;
    _selectedEmployee = widget.selectedEmployee;
    _loadQueueAndisAutoResetValue();
    _initializeItemsWithValidation();
    _calculateTotalTransaksi();
  }

  Future<void> _loadQueueAndisAutoResetValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      queueNumber = prefs.getInt('queueNumber') ?? 1;
      isAutoReset = prefs.getBool('isAutoReset') ?? false;
      nonActivateQueue = prefs.getBool('nonActivateQueue') ?? false;
      if (nonActivateQueue) queueNumber = 0;
    });
  }

  Future<void> _initializeItemsWithValidation() async {
    final List<dynamic> validItems = [];

    for (var item in widget.selectedItems) {
      if (item is Product) {
        final initialQty =
            (widget.initialQuantities?[item.productId] ?? 1).clamp(1, 999);
        final availableStock =
            await databaseService.getProductStockById(item.productId) ?? 0;

        if (availableStock >= initialQty) {
          validItems.add(item);
          _productQuantities[item.productId] = initialQty;
        } else {
          if (widget.isUpdate) {
            validItems.add(item);
            _productQuantities[item.productId] = initialQty;
            showWarningDialog(
              context,
              "Stok Spare Part ${item.productName} sekarang kurang dari jumlah transaksi sebelumnya. Tetap edit?",
            );
          } else {
            showErrorDialog(
              context,
              "Stok Spare Part ${item.productName} tidak mencukupi!",
            );
          }
        }
      } else if (item is Service) {
        final initialQty =
            (widget.initialQuantities?[item.serviceId] ?? 1).clamp(1, 999);
        validItems.add(item);
        _serviceQuantities[item.serviceId] = initialQty;
      }
    }

    if (mounted) {
      setState(() {
        widget.selectedItems
          ..clear()
          ..addAll(validItems);
        _calculateTotalTransaksi();
      });
    }
  }

  void _calculateTotalTransaksi() {
    double total = 0;
    for (var item in widget.selectedItems) {
      if (item is Product) {
        total +=
            item.productSellPrice * (_productQuantities[item.productId] ?? 1);
      } else if (item is Service) {
        total += item.servicePrice * (_serviceQuantities[item.serviceId] ?? 1);
      }
    }
    setState(() => totalTransaksi = total);
  }

  void _updateProductQuantity(int productId, int quantity) {
    setState(() {
      _productQuantities[productId] = quantity;
      _calculateTotalTransaksi();
    });
  }

  void _updateServiceQuantity(int serviceId, int quantity) {
    setState(() {
      _serviceQuantities[serviceId] = quantity;
      _calculateTotalTransaksi();
    });
  }

  void _removeItem(dynamic item) {
    setState(() {
      widget.selectedItems.remove(item);
      if (item is Product) {
        _productQuantities.remove(item.productId);
      } else if (item is Service) {
        _serviceQuantities.remove(item.serviceId);
      }
      _calculateTotalTransaksi();
    });
  }

  void _selectCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectCustomerPage(
          selectedCustomer: _selectedCustomer,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _selectedCustomer = result);
    }
  }

  Future<void> _selectEmployee() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectMechanicPage(
          selectedEmployee: _selectedEmployee,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _selectedEmployee = result);
    }
  }

  void _navigateToCheckoutPage() {
    if (widget.selectedItems.isEmpty) {
      showNullDataAlert(context);
    } else if (_selectedEmployee == null) {
      showErrorDialog(context, "Silakan pilih mekanik terlebih dahulu");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            selectedProducts: selectedProducts,
            selectedServices: selectedServices,
            productQuantities: _productQuantities,
            serviceQuantities: _serviceQuantities,
            queueNumber: queueNumber,
            lastTransactionDate: lastTransactionDate,
            transactionId: widget.transactionId,
            isUpdate: widget.isUpdate,
            selectedCustomer: _selectedCustomer,
            selectedEmployee: _selectedEmployee,
          ),
        ),
      );
    }
  }

  void _navigateToSelectProductPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectProductPage(
          selectedProducts: selectedProducts,
          selectedServices: selectedServices,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        widget.selectedItems.clear();
        widget.selectedItems.addAll(result['products'] ?? []);
        widget.selectedItems.addAll(result['services'] ?? []);

        for (var product in result['products'] ?? []) {
          _productQuantities[product.productId] =
              _productQuantities[product.productId] ?? 1;
        }
        for (var service in result['services'] ?? []) {
          _serviceQuantities[service.serviceId] =
              _serviceQuantities[service.serviceId] ?? 1;
        }

        _calculateTotalTransaksi();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              title: Text(
                widget.isUpdate ? "EDIT TRANSAKSI" : "TRANSAKSI BARU",
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
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await showModalQueue(
                        context,
                        queueNumber,
                        isAutoReset,
                        nonActivateQueue,
                      );
                      if (result != null) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setInt(
                            'queueNumber', result['queueNumber']);
                        await prefs.setBool(
                            'isAutoReset', result['isAutoReset']);
                        if (mounted) {
                          setState(() => queueNumber = result['queueNumber']);
                        }
                        _loadQueueAndisAutoResetValue();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Antrian #${queueNumber == 0 ? '-' : queueNumber}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCustomerAndEmployeeSection(),
              Expanded(
                child: _buildCombinedItemList(),
              ),
              SizedBox(
                height: 80,
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment(0, 2),
                    end: Alignment(-0, -2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL TRANSAKSI',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp. ',
                                  decimalDigits: 0)
                              .format(totalTransaksi),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _navigateToCheckoutPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'BAYAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ExpensiveFloatingButton(
            left: 20,
            right: 20,
            bottom: 100,
            onPressed: _navigateToSelectProductPage,
            text: 'PILIH ITEM',
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAndEmployeeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Customer Selection Card
          Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: _selectCustomer,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    if (_isLoadingCustomer)
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _selectCustomer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Avatar Gradient with image
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: _selectedCustomer != null
                                        ? [Colors.teal, Colors.tealAccent]
                                        : [
                                            Colors.grey[400]!,
                                            Colors.grey[300]!
                                          ],
                                  ),
                                  image: _selectedCustomer != null
                                      ? _buildImageDecoration(
                                          _selectedCustomer!)
                                      : null,
                                ),
                                child: _selectedCustomer == null ||
                                        _selectedCustomer!.profileImage ==
                                            null ||
                                        _selectedCustomer!.profileImage!.isEmpty
                                    ? Icon(Icons.person,
                                        color: Colors.white, size: 24)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              // Text
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _selectedCustomer?.namaPelanggan ??
                                        "Belum ada pelanggan dipilih",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedCustomer != null
                                          ? Colors.black87
                                          : Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedCustomer?.noHandphone ??
                                        "Tap untuk memilih pelanggan",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_selectedCustomer != null && !_isLoadingCustomer)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            setState(() => _selectedCustomer = null),
                      ),
                  ],
                ),
              ),
            ),
          ),

// Employee Selection Card
          Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: _selectEmployee,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    if (_isLoadingEmployee)
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _selectEmployee,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Avatar Gradient with image
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: _selectedEmployee != null
                                        ? [
                                            Colors.blueAccent,
                                            Colors.lightBlueAccent
                                          ]
                                        : [
                                            Colors.grey[400]!,
                                            Colors.grey[300]!
                                          ],
                                  ),
                                  image: _selectedEmployee != null
                                      ? _buildImageDecoration(
                                          _selectedEmployee!)
                                      : null,
                                ),
                                child: _selectedEmployee == null ||
                                        _selectedEmployee!.profileImage ==
                                            null ||
                                        _selectedEmployee!.profileImage!.isEmpty
                                    ? Icon(Icons.badge,
                                        color: Colors.white, size: 24)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              // Text
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _selectedEmployee?.namaMekanik ??
                                        "Belum ada pegawai dipilih",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedEmployee != null
                                          ? Colors.black87
                                          : Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedEmployee?.spesialis ??
                                        "Tap untuk memilih pegawai",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_selectedEmployee != null && !_isLoadingEmployee)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            setState(() => _selectedEmployee = null),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedItemList() {
    if (widget.selectedItems.isEmpty) {
      return _buildEmptyState();
    }
    return ListView(
      children: [
        if (selectedProducts.isNotEmpty) ...[
          _buildSectionHeader('Spare Part'),
          ...selectedProducts
              .map((product) => _buildProductItem(product))
              .toList(),
        ],
        if (selectedServices.isNotEmpty) ...[
          _buildSectionHeader('Layanan'),
          ...selectedServices
              .map((service) => _buildServiceItem(service))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return CardTransaction(
      key: ValueKey('product_${product.productId}'),
      initialQuantity: _productQuantities[product.productId] ?? 1,
      onQuantityChanged: (quantity) =>
          _updateProductQuantity(product.productId, quantity),
      onDelete: () => _removeItem(product),
      onChange: () {
        _removeItem(product);
        _navigateToSelectProductPage();
      },
      product: product,
    );
  }

  Widget _buildServiceItem(Service service) {
    return CardTransactionService(
      key: ValueKey('service_${service.serviceId}'),
      initialQuantity: _serviceQuantities[service.serviceId] ?? 1,
      onQuantityChanged: (quantity) =>
          _updateServiceQuantity(service.serviceId, quantity),
      onDelete: () => _removeItem(service),
      onChange: () {
        _removeItem(service);
        _navigateToSelectProductPage();
      },
      service: service,
    );
  }

  DecorationImage? _buildImageDecoration(dynamic data) {
    try {
      String? imagePath;

      if (data is Pelanggan) {
        imagePath = data.profileImage;
      } else if (data is Mekanik) {
        imagePath = data.profileImage;
      } else {
        return null;
      }

      if (imagePath == null || imagePath.isEmpty) return null;

      if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
        return DecorationImage(
          image: NetworkImage(imagePath),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        );
      } else if (imagePath.startsWith('assets/')) {
        return DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        );
      } else {
        return DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        );
      }
    } catch (e) {
      return null;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada item ditambahkan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan Spare Part atau layanan untuk memulai transaksi',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
