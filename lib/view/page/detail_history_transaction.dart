import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/product.dart';
import 'package:omsetin_bengkel/model/services.dart';
import 'package:omsetin_bengkel/model/transaction.dart';
import 'package:omsetin_bengkel/providers/bluetoothProvider.dart';
import 'package:omsetin_bengkel/providers/securityProvider.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/bluetoothAlert.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/pinModalWithAnimation.dart';
import 'package:omsetin_bengkel/utils/printer_helper.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/utils/successAlert.dart';
import 'package:omsetin_bengkel/view/page/transaction/share_struck_page.dart';
import 'package:omsetin_bengkel/view/page/transaction/transactions_page.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/confirm_delete_dialog.dart';
import 'package:omsetin_bengkel/view/widget/pinModal.dart';
import 'package:provider/provider.dart';

class DetailHistoryTransaction extends StatefulWidget {
  final TransactionData? transactionDetail;
  const DetailHistoryTransaction({super.key, this.transactionDetail});

  @override
  State<DetailHistoryTransaction> createState() =>
      _DetailHistoryTransactionState();
}

class _DetailHistoryTransactionState extends State<DetailHistoryTransaction> {
  late TransactionData? _transactionDetail;

  @override
  void initState() {
    super.initState();
    _transactionDetail = widget.transactionDetail!;
    print(_transactionDetail!.transactionServices);
  }

  Future<void> refreshTransactionDetail() async {
    try {
      final updated = await DatabaseService.instance
          .getTransactionById(_transactionDetail!.transactionId);
      if (mounted) {
        setState(() {
          _transactionDetail = updated;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data transaksi: $e')),
        );
      }
    }
  }

  Future<String> calculateTransactionStatus(
      int jumlahBayar, int totalPrice) async {
    if (jumlahBayar < 1) {
      return 'Belum Dibayar';
    } else if (jumlahBayar >= totalPrice) {
      return 'Selesai';
    } else {
      return 'Belum Lunas';
    }
  }

  void showBayarSisaModal(
    BuildContext context, {
    required int transactionId,
    required int currentPayAmount,
    required int transactionTotal,
    required String paymentMethod,
  }) {
    final jumlahSisa = transactionTotal - currentPayAmount;
    final jumlahBayarController =
        TextEditingController(text: jumlahSisa.toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Bayar Sisa",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Sisa yang harus dibayar:\n${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(jumlahSisa)}",
                      style:
                          GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: jumlahBayarController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Jumlah Bayar",
                        prefixText: "Rp. ",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: const InputDecoration(
                        labelText: "Metode Pembayaran",
                        border: OutlineInputBorder(),
                      ),
                      items: ['Cash', 'Transfer', 'QRIS'].map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () async {
                        final cleaned = jumlahBayarController.text
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        final bayarBaru = int.tryParse(cleaned) ?? 0;

                        if (bayarBaru <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Jumlah pembayaran tidak valid')),
                          );
                          return;
                        }

                        final totalBaru = currentPayAmount + bayarBaru;
                        final isLunas = totalBaru >= transactionTotal;

                        await DatabaseService.instance
                            .updateTransactionPayAmount(
                          transactionId,
                          totalBaru,
                          isLunas
                              ? 'Selesai'
                              : 'Belum Lunas', // Gunakan status yang konsisten
                          paymentMethod,
                        );

                        Navigator.pop(context);
                        await refreshTransactionDetail(); // Tambahkan await

                        // Tampilkan notifikasi sukses
                        showSuccessAlert(
                            context,
                            isLunas
                                ? "Pembayaran lunas!"
                                : "Pembayaran berhasil dicatat");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                      ),
                      child: Text(
                        "Bayar",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Product mapToProduct(Map<String, dynamic> data) {
    return Product(
      productId: data['productId'] ?? data['product_id'] ?? 0,
      productBarcode: data['product_barcode']?.toString() ?? '',
      productBarcodeType: data['product_barcode_type']?.toString() ?? '',
      productName: data['product_name']?.toString() ?? '',
      productStock: data['product_stock'] ?? 0,
      productUnit: data['product_unit']?.toString() ?? '',
      productSold: data['product_sold'] ?? 0,
      productPurchasePrice: data['product_purchase_price'] ?? 0,
      productSellPrice: data['product_sell_price'] ?? 0,
      productDateAdded: data['product_date_added']?.toString() ?? '',
      productImage: data['product_image']?.toString() ?? '',
    );
  }

  Service mapToService(Map<String, dynamic> data) {
    return Service(
      serviceId:
          data['serviceId'] ?? data['service_id'] ?? data['services_id'] ?? 0,
      serviceName:
          (data['service_name'] ?? data['services_name'])?.toString() ?? '',
      servicePrice: (data['service_price'] ?? data['services_price']) ?? 0,
      dateAdded: (data['service_date_added'] ?? data['services_date_added'])
              ?.toString() ??
          '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColorMap = {
      "Selesai": greenColor,
      "Belum Lunas": yellowColor,
      "Belum Dibayar": redColor,
      "Dibatalkan": greyColor,
    };

    final statusColor =
        statusColorMap[_transactionDetail!.transactionStatus] ?? secondaryColor;

    var bluetoothProvider = Provider.of<BluetoothProvider>(context);
    var securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              secondaryColor,
              primaryColor,
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: AppBar(
              title: Text(
                "DETAIL TRANSAKSI",
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
              leading: CustomBackButton(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: const Center(
                            child: Icon(Icons.receipt_long_rounded)),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "ID #${_transactionDetail!.transactionId}",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                const Spacer(),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  height: 25,
                                  decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Center(
                                      child: Text(
                                          _transactionDetail!.transactionDate,
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500))),
                                ),
                              ],
                            ),
                            Text(
                              widget.transactionDetail!.transactionCustomerName,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 130,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                              "Kasir ${_transactionDetail!.transactionCashier}",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(
                              "Antrian ${_transactionDetail!.transactionQueueNumber}",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Pegawai ${_transactionDetail!.transactionPegawaiName}",
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      Row(
                        children: [
                          Text("Jumlah pesanan :",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(
                              "${_transactionDetail!.transactionQuantity + _transactionDetail!.transactionQuantityServices}",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text("Metode pembayaran :",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(_transactionDetail!.transactionPaymentMethod,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text("Total harga :",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp. ',
                                      decimalDigits: 0)
                                  .format(widget
                                      .transactionDetail!.transactionTotal),
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Gap(10),
                      Container(
                        width: double.infinity,
                        height: 25,
                        decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: Text(
                                "Transaksi ${_transactionDetail!.transactionStatus}",
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700))),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(10),
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(children: [
                    Text("Total bayar :",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      width: 120,
                      height: 30,
                      decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: (_transactionDetail!.transactionPayAmount <
                              _transactionDetail!.transactionTotal)
                          ? TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.center,
                              ),
                              onPressed: () {
                                showBayarSisaModal(
                                  context,
                                  transactionId:
                                      widget.transactionDetail!.transactionId,
                                  currentPayAmount: widget
                                      .transactionDetail!.transactionPayAmount,
                                  transactionTotal: widget
                                      .transactionDetail!.transactionTotal,
                                  paymentMethod: widget.transactionDetail!
                                      .transactionPaymentMethod,
                                );
                              },
                              child: Center(
                                child: Text(
                                  "Bayar Sisa",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp. ',
                                  decimalDigits: 0,
                                ).format(
                                    _transactionDetail!.transactionPayAmount),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                  ]),
                ),
              ),
              const Gap(10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  children: [
                    Text("Detail Pesanan",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    GestureDetector(
                        onTap: () {
                          List<Product> selectedProducts = [];
                          List<Service> selectedServices = [];
                          Map<int, int> quantities = {};

                          // Handle products
                          for (var p
                              in widget.transactionDetail!.transactionProduct) {
                            final product = mapToProduct(p);
                            selectedProducts.add(product);
                            quantities[product.productId] = p['quantity'];
                          }

                          // Handle services (jika ada)
                          if (widget.transactionDetail!.transactionServices !=
                              null) {
                            for (var s in widget
                                .transactionDetail!.transactionServices) {
                              final service = mapToService(s);
                              selectedServices.add(service);
                              quantities[service.serviceId] = s['quantity'];
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionPage(
                                selectedItems: [
                                  ...selectedProducts,
                                  ...selectedServices
                                ],
                                initialQuantities: quantities,
                                transactionId:
                                    _transactionDetail!.transactionId,
                                isUpdate: false,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(15)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: Center(
                              child: Text(
                                "Order Ulang",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        )),
                    const Gap(6),
                    _transactionDetail!.transactionStatus == "Dibatalkan"
                        ? const Gap(1)
                        : GestureDetector(
                            onTap: () {
                              List<Product> selectedProducts = [];
                              List<Service> selectedServices = [];
                              Map<int, int> quantities = {};

                              // Handle products
                              for (var p in widget
                                  .transactionDetail!.transactionProduct) {
                                final product = mapToProduct(p);
                                selectedProducts.add(product);
                                quantities[product.productId] = p['quantity'];
                              }

                              // Handle services (jika ada)
                              if (widget
                                      .transactionDetail!.transactionServices !=
                                  null) {
                                for (var s in widget
                                    .transactionDetail!.transactionServices) {
                                  final service = mapToService(s);
                                  selectedServices.add(service);
                                  quantities[service.serviceId] = s['quantity'];
                                }
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionPage(
                                    selectedItems: [
                                      ...selectedProducts,
                                      ...selectedServices
                                    ],
                                    initialQuantities: quantities,
                                    transactionId:
                                        widget.transactionDetail!.transactionId,
                                    isUpdate: true,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(15)),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Center(
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            )),
                  ],
                ),
              ),
              const Gap(5),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 100,
                  maxHeight: 300,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: (_transactionDetail!.transactionProduct.length +
                      (_transactionDetail!.transactionServices?.length ?? 0)),
                  itemBuilder: (context, index) {
                    // Jika index masih dalam range produk
                    if (index < _transactionDetail!.transactionProduct.length) {
                      return _buildProductItem(
                          _transactionDetail!.transactionProduct[index]);
                    }
                    // Jika ada services dan index dalam range services
                    else if (_transactionDetail!.transactionServices != null &&
                        index - _transactionDetail!.transactionProduct.length <
                            _transactionDetail!.transactionServices!.length) {
                      return _buildServiceItem(
                          _transactionDetail!.transactionServices![index -
                              _transactionDetail!.transactionProduct.length]);
                    }
                    return const SizedBox();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            if (securityProvider.kunciCetakStruk) {
                              showPinModalWithAnimation(context,
                                  pinModal: PinModal(onTap: () {
                                if (bluetoothProvider.isConnected) {
                                  PrinterHelper.printReceiptAndOpenDrawer(
                                      context,
                                      services: _transactionDetail!
                                          .transactionServices,
                                      bluetoothProvider.connectedDevice!,
                                      products: _transactionDetail!
                                          .transactionProduct);
                                  showSuccessAlert(context,
                                      "Berhasil mencetak, silahkan tunggu sebentar!.");
                                }
                              }));
                            } else {
                              if (bluetoothProvider.isConnected) {
                                PrinterHelper.printReceiptAndOpenDrawer(
                                    context, bluetoothProvider.connectedDevice!,
                                    services:
                                        _transactionDetail!.transactionServices,
                                    products:
                                        _transactionDetail!.transactionProduct);
                                showSuccessAlert(context,
                                    "Berhasil mencetak, silahkan tunggu sebentar!.");
                              } else {
                                showBluetoothAlert2(context);
                              }
                            }
                          },
                          child: Container(
                            width: 150,
                            height: 40,
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.print_outlined,
                                      color: Colors.white, size: 20),
                                  Gap(4),
                                  Text("Cetak",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600))
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SharePage(
                                        queueNumber: _transactionDetail!
                                            .transactionQueueNumber,
                                        products: _transactionDetail!
                                            .transactionProduct,
                                        transactionId:
                                            _transactionDetail!.transactionId,
                                        transactionDate:
                                            _transactionDetail!.transactionDate,
                                        totalPrice: _transactionDetail!
                                            .transactionTotal,
                                        amountPrice: _transactionDetail!
                                            .transactionPayAmount,
                                        discountAmount: _transactionDetail!
                                            .transactionDiscount,
                                      )),
                            );
                          },
                          child: Container(
                            width: 150,
                            height: 40,
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.share_outlined,
                                      color: Colors.white, size: 20),
                                  Gap(4),
                                  Text("Bagikan",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600))
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          if (_transactionDetail!.transactionStatus !=
                              "Dibatalkan") ...[
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await DatabaseService.instance
                                      .updateTransactionStatus(
                                    _transactionDetail!.transactionId,
                                    "Dibatalkan",
                                  );
                                  Navigator.pop(context);
                                  await refreshTransactionDetail();
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: redColor,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.close_outlined,
                                            color: Colors.white, size: 20),
                                        Gap(4),
                                        Text("Batalkan Pesanan",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(10),
                          ],
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmDeleteDialog(
                                      message: "Hapus transaksi ini?",
                                      onConfirm: () async {
                                        try {
                                          // Tutup dialog konfirmasi
                                          Navigator.pop(context);

                                          // Tampilkan loading indicator
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          );

                                          // Hapus transaksi
                                          await DatabaseService.instance
                                              .deleteTransaction(
                                                  _transactionDetail!
                                                      .transactionId);

                                          // Tutup loading indicator
                                          Navigator.pop(context);

                                          // Kembali ke halaman sebelumnya dengan hasil sukses
                                          Navigator.pop(context, true);
                                          await refreshTransactionDetail();
                                        } catch (e) {
                                          // Tutup loading indicator jika ada error
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Gagal menghapus transaksi: $e')),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete_outline_outlined,
                                          color: redColor, size: 20),
                                      Gap(4),
                                      Text("Hapus Pesanan",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: redColor,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildProductItem(Map<String, dynamic> product) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Hero(
            tag: "productImage_${product['productId']}",
            child: Image.file(
              File(product['product_image'].toString()),
              width: 45,
              height: 45,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/products/no-image.png",
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['product_name'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${product['quantity']} x ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(product['product_sell_price'])}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Subtotal: ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format((product['quantity'] as int) * (product['product_sell_price'] as int))}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildServiceItem(Map<String, dynamic> service) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.construction, color: Colors.grey),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service['services_name'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${service['quantity']} x ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(service['services_price'])}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Subtotal: ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format((service['quantity'] as int) * (service['services_price'] as int))}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
