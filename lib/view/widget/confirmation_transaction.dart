import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/cashier.dart';
import 'package:omsetin_stok/providers/cashierProvider.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/alert.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/view/page/detail_history_transaction.dart';
import 'package:omsetin_stok/view/page/transaction/success_transaction_page.dart';
import 'package:omsetin_stok/utils/successAlert.dart';
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
  discountAmount,
  String selectedPaymentMethod,
  List<Map<String, dynamic>> products,
  int queueNumber,
) async {
  final DatabaseService databaseService = DatabaseService.instance;
  // Create a transaction map
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
    'transaction_quantity':
        products.map((e) => e['quantity']).reduce((a, b) => a + b),
    'transaction_queue_number': queueNumber,
    'transaction_profit': calculateProfit(totalPrice, jumlahBayar, products)
  };

  // Add the transaction to the database
  try {
    await databaseService.addTransaction(transaction);
    print("Transaction added successfully");

    // Update product stock
    for (var product in products) {
      int productId = product['productId'];
      int quantity = product['quantity'];

      // Fetch current stock from database
      final int? currentStock =
          await databaseService.getProductStockById(productId);

      // Cek apakah currentStock null
      if (currentStock == null) {
        print(
            " WARNING: Product ID $productId not found in database. Skipping stock update...");
        continue; // Skip update stock untuk produk ini
      }

      // Update stock dengan value yang valid
      int updatedStock = currentStock - quantity;

      await databaseService.updateProductStock(productId, updatedStock);
      print(
          " Stock updated for product ID $productId: $currentStock -> $updatedStock");
    }
  } catch (e, stackTrace) {
    print(" ERROR TO ADD TRANSACTION: $e");
    print(" Stacktrace: $stackTrace");
  }
}

Future<void> updateTransactionInDatabase(
  int transactionId,
  String formattedDate,
  String cashierName,
  String customerName,
  int totalPrice,
  int jumlahBayar,
  discountAmount,
  String selectedPaymentMethod,
  List<Map<String, dynamic>> products,
  int queueNumber,
) async {
  final DatabaseService databaseService = DatabaseService.instance;

  final oldTransaction =
      await databaseService.getTransactionById(transactionId);

  if (oldTransaction == null) {
    print("Transaction not found!");
    return;
  }

  List<Map<String, dynamic>> oldProducts = oldTransaction.transactionProduct;

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
    'transaction_quantity':
        products.map((e) => e['quantity'] as int).reduce((a, b) => a + b),
    'transaction_queue_number': queueNumber,
    'transaction_profit': calculateProfit(totalPrice, jumlahBayar, products),
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

      await databaseService.updateProductStock(
        productId,
        updatedStock,
      );
      print("Updated stock for $productId: $currentStock → $updatedStock");
    }
  } catch (e, stackTrace) {
    print("Failed to update transaction: $e");
    print("Stacktrace: $stackTrace");
  }
}

void showModalKonfirmasi(
  BuildContext context,
  int totalPrice,
  totalItems,
  discountAmount,
  List<Map<String, dynamic>> products,
  Map<int, int> quantities,
  String selectedPaymentMethod,
  int queueNumber,
  DateTime? lastTransactionDate, {
  bool isUpdate = false,
  int? transactionId,
}) {
  showDialog(
    context: context,
    builder: (context) {
      String customerName = '';
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9),
                    child: Container(
                      width: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0)),
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
                                  "Konfirmasi Pembelian !",
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
                          // Total Harga
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Total Harga : ${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(totalPrice)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: deepGreen,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // TextField: Jumlah Bayar
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
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        border: InputBorder.none,
                                      ),
                                      obscureText: false,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          jumlahBayar = int.parse(
                                              value.replaceAll(
                                                  RegExp(r'[^0-9]'),
                                                  '')); // Update jumlah bayar
                                          jumlahBayarController.text =
                                              NumberFormat.currency(
                                                      locale: 'id_ID',
                                                      decimalDigits: 0,
                                                      symbol: '')
                                                  .format(jumlahBayar);
                                          jumlahBayarController.selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset:
                                                          jumlahBayarController
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
                          // TextField: Nama Customer
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: Colors.grey[400]!, width: 1.0),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    customerName = value;
                                  });
                                },
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: "Nama Customer",
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: InputBorder.none,
                                  prefixIcon:
                                      Icon(Icons.person, color: deepGreen),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Card: Tanggal Transaksi
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: _buildCard(
                              icon: Icons.calendar_today,
                              title: "Tanggal Transaksi",
                              subtitle: formattedDate,
                            ),
                          ),

                          Gap(10),
                          // Tombol Bayar
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
                                    parseJumlahBayar(
                                        jumlahBayarController.text),
                                    discountAmount,
                                    selectedPaymentMethod,
                                    products,
                                    queueNumber,
                                  );
                                  final updatedTransaction =
                                      await DatabaseService.instance
                                          .getTransactionById(transactionId);

                                  if (updatedTransaction != null) {
                                    showSuccessAlert(
                                        context, "Berhasil mengubah!");
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
                                    showErrorDialog(context,
                                        "Gagal mengambil data transaksi!");
                                  }
                                } else {
                                  await addTransactionToDatabase(
                                    formattedDate,
                                    cashierName,
                                    customerName,
                                    totalPrice,
                                    parseJumlahBayar(
                                        jumlahBayarController.text),
                                    discountAmount,
                                    selectedPaymentMethod,
                                    products,
                                    queueNumber,
                                  );
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionSuccessPage(
                                        amountPrice: jumlahBayar,
                                        totalPrice: totalPrice,
                                        products: products,
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
                );
              },
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
