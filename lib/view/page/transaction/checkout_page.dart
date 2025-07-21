import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/mekanik.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/model/pelanggan.dart';
import 'package:omzetin_bengkel/model/services.dart';
import 'package:omzetin_bengkel/providers/cashierProvider.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/alert.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/confirmation_transaction.dart';
import 'package:omzetin_bengkel/view/widget/modals.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  final List<Product> selectedProducts;
  final List<Service> selectedServices;
  final Map<int, int> productQuantities;
  final Map<int, int> serviceQuantities;
  final int queueNumber;
  final DateTime? lastTransactionDate;
  final int? transactionId;
  final bool isUpdate;
  final Pelanggan? selectedCustomer;
  final Mekanik? selectedEmployee;

  const CheckoutPage({
    super.key,
    required this.selectedProducts,
    required this.selectedServices,
    required this.productQuantities,
    required this.serviceQuantities,
    required this.queueNumber,
    required this.lastTransactionDate,
    this.transactionId,
    this.isUpdate = false,
    this.selectedCustomer,
    this.selectedEmployee,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPaymentMethod = "Cash";
  bool isPercentDiscount = false;
  int subtotal = 0;
  int discount = 0;
  int totalItems = 0;
  List<String> _paymentMethods = [];
  final TextEditingController _discountController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _loadPaymentMethods();
      _calculateSubtotalAndTotalItems();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, "Gagal memuat data: ${e.toString()}");
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPaymentMethods() async {
    final methods = await DatabaseService.instance.getPaymentMethods();
    if (mounted) {
      setState(() {
        _paymentMethods = methods.map((e) => e.paymentMethodName).toList();
        if (_paymentMethods.isNotEmpty) {
          selectedPaymentMethod = _paymentMethods.first;
        }
      });
    }
  }

  void _calculateSubtotalAndTotalItems() {
    int newSubtotal = 0;
    int newTotalItems = 0;

    for (final product in widget.selectedProducts) {
      final quantity = widget.productQuantities[product.productId] ?? 1;
      newSubtotal += product.productSellPrice * quantity;
      newTotalItems += quantity;
    }

    for (final service in widget.selectedServices) {
      final quantity = widget.serviceQuantities[service.serviceId] ?? 1;
      newSubtotal += service.servicePrice * quantity;
      newTotalItems += quantity;
    }

    if (mounted) {
      setState(() {
        subtotal = newSubtotal;
        totalItems = newTotalItems;
      });
    }
  }

  int get totalPrice =>
      subtotal - (isPercentDiscount ? (subtotal * discount) ~/ 100 : discount);

  void _updateDiscount(String value) {
    final parsedValue = int.tryParse(value) ?? 0;
    if (parsedValue < 0) return;

    setState(() {
      discount = parsedValue;
    });
  }

  void _navigateToConfirmation() {
    if (widget.selectedProducts.isEmpty && widget.selectedServices.isEmpty) {
      showErrorDialog(context, "Tidak ada item yang dipilih");
      return;
    }

    final productData = widget.selectedProducts.map((product) {
      final quantity = widget.productQuantities[product.productId] ?? 1;
      return {
        'productId': product.productId,
        'product_barcode': product.productBarcode,
        'product_barcode_type': product.productBarcodeType,
        'product_name': product.productName,
        'product_stock': product.productStock,
        'product_unit': product.productUnit,
        'product_sold': product.productSold,
        'product_purchase_price': product.productPurchasePrice,
        'product_sell_price': product.productSellPrice,
        'product_date_added': product.productDateAdded,
        'product_image': product.productImage,
        'quantity': quantity,
      };
    }).toList();

    final serviceData = widget.selectedServices.map((service) {
      final quantity = widget.serviceQuantities[service.serviceId] ?? 1;
      return {
        'servicesId': service.serviceId,
        'services_name': service.serviceName,
        'services_price': service.servicePrice,
        'quantity': quantity,
      };
    }).toList();

    final discountAmount = subtotal - totalPrice;

    showModalKonfirmasi(
      context,
      totalPrice,
      totalItems,
      discountAmount,
      productData,
      serviceData,
      {...widget.productQuantities, ...widget.serviceQuantities},
      selectedPaymentMethod,
      widget.queueNumber,
      widget.lastTransactionDate,
      isUpdate: widget.isUpdate,
      transactionId: widget.transactionId,
      selectedCustomer: widget.selectedCustomer,
      selectedEmployee: widget.selectedEmployee,
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final cashierProvider = Provider.of<CashierProvider>(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );

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
                "CHECKOUT",
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
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildCustomerAndEmployeeSection(),
                    if (widget.selectedProducts.isNotEmpty) ...[
                      _buildSectionHeader("Produk"),
                      ...widget.selectedProducts.map(_buildProductItem),
                    ],
                    if (widget.selectedServices.isNotEmpty) ...[
                      _buildSectionHeader("Layanan"),
                      ...widget.selectedServices.map(_buildServiceItem),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSubtotalCard(currencyFormat),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  color: bgColor,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildPaymentMethodSection(),
                      // const SizedBox(height: 8),
                      _buildDiscountSection(),
                    ],
                  ),
                ),
              ),
              Container(
                  color: bgColor,
                  child: _buildBottomPaymentButton(
                      currencyFormat, cashierProvider)),
            ],
          ),
          // Fixe
        ],
      ),
    );
  }

  Widget _buildCustomerAndEmployeeSection() {
    return Column(
      children: [
        if (widget.selectedCustomer != null)
          Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200], // Fallback color
                  image: widget.selectedCustomer!.profileImage != null
                      ? _buildImageDecoration(widget.selectedCustomer!)
                      : null,
                ),
                child: widget.selectedCustomer == null ||
                        widget.selectedCustomer!.profileImage == null ||
                        widget.selectedCustomer!.profileImage!.isEmpty
                    ? Text(
                        widget.selectedCustomer?.namaPelanggan[0] ?? 'E',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    : null,
              ),
              title: Text(widget.selectedCustomer!.namaPelanggan),
              subtitle: Text(widget.selectedCustomer!.noHandphone),
            ),
          ),
        if (widget.selectedCustomer != null)
          Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200], // Warna fallback
                  image: widget.selectedEmployee != null
                      ? _buildImageDecoration(widget.selectedEmployee!)
                      : null,
                ),
                child: widget.selectedEmployee == null ||
                        widget.selectedEmployee!.profileImage == null ||
                        widget.selectedEmployee!.profileImage!.isEmpty
                    ? Text(
                        widget.selectedEmployee?.namaMekanik[0] ?? 'E',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    : null,
              ),
              title: Text(widget.selectedEmployee?.namaMekanik ??
                  'Belum ada pegawai dipilih'),
              subtitle: Text(widget.selectedEmployee?.spesialis ??
                  'Tap untuk memilih pegawai'),
            ),
          ),
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

  Widget _buildProductItem(Product product) {
    final quantity = widget.productQuantities[product.productId] ?? 1;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]),
            child: product.productImage.isNotEmpty
                ? Image.file(
                    File(product.productImage),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultProductImage();
                    },
                  )
                : _buildDefaultProductImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "$quantity x ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0).format(product.productSellPrice)}",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "SubTotal ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0).format(product.productSellPrice * quantity)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultProductImage() {
    return Image.asset(
      "assets/products/no-image.png",
      width: 60,
      height: 60,
      fit: BoxFit.cover,
    );
  }

  Widget _buildServiceItem(Service service) {
    final quantity = widget.serviceQuantities[service.serviceId] ?? 1;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "$quantity x ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0).format(service.servicePrice)}",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "Total ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0).format(service.servicePrice * quantity)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtotalCard(NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: greenColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "SubTotal",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            currencyFormat.format(subtotal),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Metode Pembayaran",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: selectedPaymentMethod,
            isExpanded: true,
            underline: const SizedBox(),
            items: _paymentMethods
                .map((method) => DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedPaymentMethod = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountSection() {
    return Row(
      children: [
        const Icon(Icons.discount, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText:
                  isPercentDiscount ? "Diskon Persen %" : "Diskon Rupiah Rp",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: _updateDiscount,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Row(
              children: [
                const Text("Persen %"),
                Transform.scale(
                  scale: 0.6,
                  child: Switch(
                    value: isPercentDiscount,
                    activeColor: greenColor,
                    inactiveThumbColor: redColor,
                    inactiveTrackColor: redColor.withOpacity(0.5),
                    onChanged: (value) {
                      setState(() {
                        isPercentDiscount = value;
                        _discountController.clear();
                        discount = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Rupiah Rp"),
                Transform.scale(
                  scale: 0.6,
                  child: Switch(
                    value: !isPercentDiscount,
                    activeColor: greenColor,
                    inactiveThumbColor: redColor,
                    inactiveTrackColor: redColor.withOpacity(0.5),
                    onChanged: (value) {
                      setState(() {
                        isPercentDiscount = !value;
                        _discountController.clear();
                        discount = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomPaymentButton(
    NumberFormat currencyFormat,
    CashierProvider cashierProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: const Alignment(0, 2),
          end: const Alignment(-0, -2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Jumlah: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '$totalItems',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Text(
                'TOTAL HARGA',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                currencyFormat.format(totalPrice),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _navigateToConfirmation,
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
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
