import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/cashier.dart';
import 'package:omsetin_bengkel/model/mekanik.dart';
import 'package:omsetin_bengkel/model/pelanggan.dart';
import 'package:omsetin_bengkel/providers/cashierProvider.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/alert.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/view/page/detail_history_transaction.dart';
import 'package:omsetin_bengkel/view/page/transaction/success_transaction_page.dart';
import 'package:omsetin_bengkel/utils/successAlert.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

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

int calculateTotalPurchasePrice(List<Map<String, dynamic>> products) {
  int totalPurchasePrice = 0;
  for (var product in products) {
    int purchasePrice = product['product_purchase_price'];
    int quantity = product['quantity'];
    totalPurchasePrice += purchasePrice * quantity;
  }
  return totalPurchasePrice;
}

int calculateProfit(
    int totalPrice, int jumlahBayar, List<Map<String, dynamic>> products) {
  int totalPurchasePrice = calculateTotalPurchasePrice(products);
  return (jumlahBayar >= totalPrice)
      ? totalPrice - totalPurchasePrice
      : jumlahBayar - totalPurchasePrice;
}

Future<void> addTransactionToDatabase(
  String formattedDate,
  String cashierName,
  String customerName,
  int totalPrice,
  int jumlahBayar,
  int discountAmount,
  String selectedPaymentMethod,
  List<Map<String, dynamic>> products,
  List<Map<String, dynamic>> services,
  int queueNumber,
  String employeeName, // Add employeeName parameter
) async {
  final DatabaseService databaseService = DatabaseService.instance;

  Map<String, dynamic> transaction = {
    'transaction_date': formattedDate,
    'transaction_cashier': cashierName,
    'transaction_customer_name':
        customerName.isNotEmpty ? customerName : "Pelanggan",
    'transaction_total': totalPrice,
    'transaction_pay_amount': jumlahBayar,
    'transaction_discount': discountAmount,
    'transaction_method': selectedPaymentMethod,
    'transaction_note': "Beli",
    'transaction_tax': 0,
    'transaction_status':
        await calculateTransactionStatus(jumlahBayar, totalPrice),
    'transaction_products': jsonEncode(products),
    'transaction_services': jsonEncode(services),
    'transaction_quantity': products
        .map((e) => e['quantity'] as int)
        .fold(0, (prev, curr) => prev + curr),
    'transaction_quantity_services': services
        .map((e) => e['quantity'] as int)
        .fold(0, (prev, curr) => prev + curr),
    'transaction_queue_number': queueNumber,
    'transaction_profit': calculateProfit(totalPrice, jumlahBayar, products),
    'transaction_pegawai_name': employeeName, // Add employee name
  };

  try {
    await databaseService.addTransaction(transaction);
    print("Transaction added successfully");

    for (var product in products) {
      int productId = product['productId'];
      int quantity = product['quantity'];

      final int? currentStock =
          await databaseService.getProductStockById(productId);

      if (currentStock == null) {
        print(
            "WARNING: Product ID $productId not found in database. Skipping stock update...");
        continue;
      }

      int updatedStock = currentStock - quantity;
      await databaseService.updateProductStock(productId, updatedStock);
      print(
          "Stock updated for product ID $productId: $currentStock -> $updatedStock");
    }
  } catch (e, stackTrace) {
    print("ERROR TO ADD TRANSACTION: $e");
    print("Stacktrace: $stackTrace");
    rethrow; // Re-throw the error to handle it in the calling function
  }
}

Future<void> updateTransactionInDatabase(
  int transactionId,
  String formattedDate,
  String cashierName,
  String customerName,
  int totalPrice,
  int jumlahBayar,
  int discountAmount,
  String selectedPaymentMethod,
  List<Map<String, dynamic>> products,
  List<Map<String, dynamic>> services,
  int queueNumber,
  String employeeName, // Add employeeName parameter
) async {
  final DatabaseService databaseService = DatabaseService.instance;

  final oldTransaction =
      await databaseService.getTransactionById(transactionId);

  if (oldTransaction == null) {
    print("Transaction not found!");
    return;
  }

  List<Map<String, dynamic>> oldProducts = oldTransaction.transactionProduct;
  List<Map<String, dynamic>> oldServices =
      oldTransaction.transactionServices ?? [];

  Map<String, dynamic> updatedTransaction = {
    'transaction_date': formattedDate,
    'transaction_cashier': cashierName,
    'transaction_customer_name':
        customerName.isNotEmpty ? customerName : "Pelanggan",
    'transaction_total': totalPrice,
    'transaction_pay_amount': jumlahBayar,
    'transaction_discount': discountAmount,
    'transaction_method': selectedPaymentMethod,
    'transaction_note': "Beli",
    'transaction_tax': 0,
    'transaction_status':
        await calculateTransactionStatus(jumlahBayar, totalPrice),
    'transaction_products': jsonEncode(products),
    'transaction_services': jsonEncode(services),
    'transaction_quantity': products
        .map((e) => e['quantity'] as int)
        .fold(0, (prev, curr) => prev + curr),
    'transaction_quantity_services': services
        .map((e) => e['quantity'] as int)
        .fold(0, (prev, curr) => prev + curr),
    'transaction_queue_number': queueNumber,
    'transaction_profit': calculateProfit(totalPrice, jumlahBayar, products),
    'transaction_pegawai_name': employeeName, // Add employee name
  };

  try {
    await databaseService.updateTransaction(transactionId, updatedTransaction);
    print("Transaction updated successfully");

    for (var newProduct in products) {
      final int productId = newProduct['productId'];
      final int newQty = newProduct['quantity'];

      final int oldQty = oldProducts.firstWhere(
        (p) => p['productId'] == productId,
        orElse: () => {'quantity': 0},
      )['quantity'];

      final int? currentStock =
          await databaseService.getProductStockById(productId);

      if (currentStock == null) {
        print("Product $productId not found in stock.");
        continue;
      }

      final int updatedStock = currentStock - newQty + oldQty;
      await databaseService.updateProductStock(productId, updatedStock);
      print("Updated stock for $productId: $currentStock → $updatedStock");
    }
  } catch (e, stackTrace) {
    print("Failed to update transaction: $e");
    print("Stacktrace: $stackTrace");
    rethrow;
  }
}

void showModalKonfirmasi(
    BuildContext context,
    int totalPrice,
    int totalItems,
    int discountAmount,
    List<Map<String, dynamic>> products,
    List<Map<String, dynamic>> services,
    Map<int, int> quantities,
    String selectedPaymentMethod,
    int queueNumber,
    DateTime? lastTransactionDate,
    {bool isUpdate = false,
    int? transactionId,
    Pelanggan? selectedCustomer,
    Mekanik? selectedEmployee}) {
  showDialog(
    context: context,
    builder: (context) {
      String customerName = selectedCustomer?.namaPelanggan ?? '';
      String employeeName =
          selectedEmployee?.namaMekanik ?? 'Kasir'; // Default to 'Kasir' if n
      int jumlahBayar = totalPrice;
      TextEditingController jumlahBayarController =
          TextEditingController(text: jumlahBayar.toString());

      int parseJumlahBayar(String formattedValue) {
        final clean = formattedValue.replaceAll(RegExp(r'[^0-9]'), '');
        return clean.isEmpty ? 0 : int.parse(clean);
      }

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('EEEE, dd/MM/yyyy HH:mm', 'id_ID')
          .format(lastTransactionDate ?? now);

      var cashierProvider = Provider.of<CashierProvider>(context);
      String cashierName =
          cashierProvider.cashierData?['cashierName'] ?? "Kasir";

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9),
                child: Container(
                  width: 300,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Konfirmasi Pembelian",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: redColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      // Customer info (if selected)
                      if (selectedCustomer != null)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        selectedCustomer.profileImage != null
                                            ? FileImage(File(
                                                selectedCustomer.profileImage!))
                                            : null,
                                    child: selectedCustomer.profileImage == null
                                        ? Text(
                                            selectedCustomer.namaPelanggan[0])
                                        : null,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedCustomer.namaPelanggan,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(selectedCustomer.noHandphone),
                                        if (selectedCustomer.email != null &&
                                            selectedCustomer.email!.isNotEmpty)
                                          Text(selectedCustomer.email!),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 10),

                      // Item List
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Products section
                              if (products.isNotEmpty) ...[
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Produk:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                ...products
                                    .map((product) => Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 4.0),
                                          child: Card(
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Icon(
                                                      Icons.shopping_bag,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          product[
                                                              'product_name'],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                            "${product['quantity']} x ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0).format(product['product_sell_price'])}"),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    NumberFormat.currency(
                                                            locale: 'id_ID',
                                                            symbol: 'Rp.',
                                                            decimalDigits: 0)
                                                        .format(product[
                                                                'product_sell_price'] *
                                                            product[
                                                                'quantity']),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ],

                              // Services section
                              if (services.isNotEmpty) ...[
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Layanan:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                ...services
                                    .map((service) => Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 4.0),
                                          child: Card(
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Icon(
                                                      Icons.medical_services,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          service[
                                                              'services_name'],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                            "${service['quantity']} x ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0).format(service['services_price'])}"),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    NumberFormat.currency(
                                                            locale: 'id_ID',
                                                            symbol: 'Rp.',
                                                            decimalDigits: 0)
                                                        .format(service[
                                                                'services_price'] *
                                                            service[
                                                                'quantity']),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Summary section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            _buildSummaryRow("Subtotal:", totalPrice),
                            _buildSummaryRow("Diskon:", discountAmount),
                            Divider(),
                            _buildSummaryRow(
                              "Total:",
                              totalPrice - discountAmount,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      // Payment Input
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                                color: Colors.grey[400]!, width: 1.0),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.money, color: deepGreen),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: jumlahBayarController,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: "Jumlah Bayar",
                                    prefixText: "Rp. ",
                                    labelStyle: TextStyle(color: Colors.black),
                                    border: InputBorder.none,
                                  ),
                                  obscureText: false,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      jumlahBayar = parseJumlahBayar(value);
                                      jumlahBayarController.text =
                                          NumberFormat.currency(
                                                  locale: 'id_ID',
                                                  decimalDigits: 0,
                                                  symbol: '')
                                              .format(jumlahBayar);
                                      jumlahBayarController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: jumlahBayarController
                                                      .text.length));
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    jumlahBayarController.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),

                      // Payment Method
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Metode Pembayaran",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                DropdownButton<String>(
                                  value: selectedPaymentMethod,
                                  isExpanded: true,
                                  items: [
                                    DropdownMenuItem(
                                        value: "Cash", child: Text("Cash")),
                                    DropdownMenuItem(
                                        value: "Transfer",
                                        child: Text("Transfer")),
                                    DropdownMenuItem(
                                        value: "Debit", child: Text("Debit")),
                                    DropdownMenuItem(
                                        value: "Credit", child: Text("Credit")),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedPaymentMethod = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),

                      // Transaction Date
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.green),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tanggal Transaksi",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(formattedDate),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Pay Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            if (isUpdate && transactionId != null) {
                              await updateTransactionInDatabase(
                                  transactionId,
                                  formattedDate,
                                  cashierName,
                                  customerName,
                                  totalPrice,
                                  parseJumlahBayar(jumlahBayarController.text),
                                  discountAmount,
                                  selectedPaymentMethod,
                                  products,
                                  services,
                                  queueNumber,
                                  employeeName);
                              final updatedTransaction = await DatabaseService
                                  .instance
                                  .getTransactionById(transactionId);

                              if (updatedTransaction != null) {
                                showSuccessAlert(context, "Berhasil mengubah!");
                                Navigator.of(context, rootNavigator: true)
                                    .pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailHistoryTransaction(
                                      transactionDetail: updatedTransaction,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                showErrorDialog(
                                    context, "Gagal mengambil data transaksi!");
                              }
                            } else {
                              await addTransactionToDatabase(
                                formattedDate,
                                cashierName,
                                customerName,
                                totalPrice,
                                parseJumlahBayar(jumlahBayarController.text),
                                discountAmount,
                                selectedPaymentMethod,
                                products,
                                services,
                                queueNumber,
                                employeeName,
                              );
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => TransactionSuccessPage(
                                    amountPrice: parseJumlahBayar(
                                        jumlahBayarController.text),
                                    totalPrice: totalPrice,
                                    products: products,
                                    services: services,
                                    transactionDate: formattedDate,
                                    discountAmount: discountAmount,
                                    customerName: customerName,
                                    queueNumber: queueNumber,
                                  ),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          child: Text(
                            isUpdate ? "UPDATE" : "BAYAR",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildCard({
  required IconData icon,
  required String title,
  String? subtitle,
  IconData? trailingIcon,
  Color? trailingColor,
}) {
  return Container(
    padding: EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(color: Colors.grey[400]!, width: 1.0),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.green),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              if (subtitle != null && subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.black),
                ),
            ],
          ),
        ),
        if (trailingIcon != null)
          Icon(trailingIcon, color: trailingColor ?? Colors.white),
      ],
    ),
  );
}

Widget _buildSummaryRow(String label, int amount, {bool isTotal = false}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0)
              .format(amount),
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? deepGreen : Colors.black,
          ),
        ),
      ],
    ),
  );
}
