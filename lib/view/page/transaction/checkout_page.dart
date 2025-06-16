// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/mekanik.dart';
import 'package:omsetin_stok/services/db_helper.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/view/page/transaction/transactions_page.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:provider/provider.dart';

import 'package:omsetin_stok/model/pelanggan.dart';
import 'package:omsetin_stok/model/product.dart';
import 'package:omsetin_stok/model/service.dart';
import 'package:omsetin_stok/services/authService.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/services/userService.dart';

class CheckoutPage extends StatefulWidget {
  final Pelanggan pelanggan;
  final List<dynamic> items; // Berisi Service atau Product
  final int total;
  final int? transactionId;
  final bool isUpdate;
  final VoidCallback? onTransactionSuccess;

  const CheckoutPage({
    Key? key,
    required this.pelanggan,
    required this.items,
    required this.total,
    this.transactionId,
    required this.isUpdate,
    this.onTransactionSuccess,
  }) : super(key: key);
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedMekanik;
  String keterangan = '';
  String metodeBayar = 'Cash';
  int diskon = 0;
  bool isDiskonRupiah = true;
  int biayaTambahan = 0;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(now);

    return Scaffold(
      appBar: PreferredSize(
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
                    end: Alignment.bottomCenter)),
            child: AppBar(
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              leading: const CustomBackButton(),
              title: Text(
                'CHECKOUT',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: bgColor,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Pelanggan
            Text(widget.pelanggan.namaPelanggan,
                style: TextStyle(fontSize: 16)),
            Text(widget.pelanggan.noHandphone, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),

            // Detail Order
            Text(
              'Detail Order',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            ...widget.items.map(
              (item) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item is Service
                              ? item.name
                              : item is ProductWithQuantity
                                  ? item.product.productName
                                  : item
                                      .productName, // Fallback untuk Product biasa
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp',
                        ).format(item is Service
                            ? item.price.toInt()
                            : item is ProductWithQuantity
                                ? item.product.productSellPrice
                                : item.productSellPrice),
                        // 'Rp.${item is Service ? item.price.toInt() : item is ProductWithQuantity ? item.product.productSellPrice : item.productSellPrice}', // Fallback untuk Product biasa
                        style: TextStyle(fontSize: 16),
                      ),
                      if (item is ProductWithQuantity)
                        Text(' x${item.quantity}'),
                    ],
                  ),
                );
              },
            ).toList(),

            Divider(thickness: 2),

            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp',
                  ).format(widget.total),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Text(
                //   'Rp.${widget.total}',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
              ],
            ),

            Divider(thickness: 2),
            SizedBox(height: 16),

            // Keterangan
            Text(
              'Keterangan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '(Opsional)',
              ),
              onChanged: (value) => keterangan = value,
            ),
            SizedBox(height: 16),

            // Tanggal Transaksi
            Row(
              children: [
                Text('Tanggal Transaksi :'),
                SizedBox(width: 8),
                Text(formattedDate),
                Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
            SizedBox(height: 16),

            // Mekanik
            Text(
              'Mekanik',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectMekanik(context),
              child: Text('Tambah Mekanik'),
            ),
            if (selectedMekanik != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(selectedMekanik!),
              ),
            SizedBox(height: 16),

            // Langsung Bayar
            Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: null,
                ),
                Text('Langsung bayar'),
                Spacer(),
                OutlinedButton(
                  onPressed: () => _addBiayaTambahan(context),
                  child: Text('+ Tambah Biaya Tambahan'),
                ),
              ],
            ),
            if (biayaTambahan > 0)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Biaya Tambahan: Rp.$biayaTambahan'),
              ),
            SizedBox(height: 16),

            // Metode Bayar
            Text(
              'Metode Bayar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: metodeBayar,
              items: ['Cash', 'Transfer Bank', 'Kredit'].map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => metodeBayar = value!);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Diskon
            Text(
              'Diskon / Rupiah',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: isDiskonRupiah,
                  onChanged: (value) {
                    setState(() => isDiskonRupiah = value!);
                  },
                ),
                Text('Rupiah Rp'),
                SizedBox(width: 16),
                Checkbox(
                  value: !isDiskonRupiah,
                  onChanged: (value) {
                    setState(() => isDiskonRupiah = !value!);
                  },
                ),
                Text('Person'),
                Icon(Icons.close, size: 20),
              ],
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '0',
                prefixText: 'Rp.',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => diskon = int.tryParse(value) ?? 0);
              },
            ),
            SizedBox(height: 24),

            // Total Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Harga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp',
                  ).format(_calculateFinalTotal()),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Tombol Bayar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final authService =
                      Provider.of<AuthService>(context, listen: false);
                  _processPayment(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  'Bayar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateFinalTotal() {
    return widget.total + biayaTambahan - diskon;
  }

  void _selectMekanik(BuildContext context) async {
    final mekanikList = await DatabaseHelper.instance.getAllMekanik();
    // Contoh sederhana pilih mekanik
    final result = await showDialog<Mekanik>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Pilih Mekanik'),
        children: mekanikList.map((mekanik) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, mekanik),
            child: Text(mekanik.namaMekanik),
          );
        }).toList(),
      ),
    );

    if (result != null) {
      setState(() => selectedMekanik = result.namaMekanik);
    }
  }

  void _addBiayaTambahan(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Biaya Tambahan'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Jumlah Biaya Tambahan',
            prefixText: 'Rp.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 0;
              Navigator.pop(context, value);
            },
            child: Text('Tambah'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => biayaTambahan = result);
    }
  }

  Future<void> _processPayment(BuildContext context) async {
    // Proses pembayaran disini
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final cashierName = await authService.getCurrentUsername();
      // Validasi input
      if (widget.pelanggan.namaPelanggan.isEmpty) {
        throw Exception('Nama pelanggan tidak boleh kosong');
      }
      if (widget.items.isEmpty) {
        throw Exception('Tidak ada item untuk diproses');
      }
      if (metodeBayar.isEmpty) {
        throw Exception('Metode pembayaran tidak boleh kosong');
      }
      if (isDiskonRupiah && diskon < 0) {
        throw Exception('Diskon tidak boleh negatif');
      }
      if (!isDiskonRupiah && diskon < 0) {
        throw Exception('Jumlah diskon tidak boleh negatif');
      }
      if (biayaTambahan < 0) {
        throw Exception('Biaya tambahan tidak boleh negatif');
      }
      if (selectedMekanik == null) {
        selectedMekanik = '(Tidak ada mekanik yang dipilih)';
      }
      // Jika update transaksi, pastikan transactionId ada
      if (widget.isUpdate && widget.transactionId == null) {
        throw Exception('ID transaksi tidak ditemukan untuk update');
      }
      // Jika bukan update, pastikan transactionId tidak ada
      if (!widget.isUpdate && widget.transactionId != null) {
        throw Exception('ID transaksi tidak boleh ada untuk transaksi baru');
      }
      // Jika update, gunakan transactionId yang ada
      if (widget.isUpdate && widget.transactionId != null) {
        print('Updating transaction with ID: ${widget.transactionId}');
      } else {
        print('Creating new transaction');
      }
      // Jika semua validasi berhasil, lanjutkan dengan proses pembayaran
      print('All validations passed, proceeding with payment processing...');
      // Siapkan data transaksi

      final transactionData = {
        'transaction_date': DateTime.now().toIso8601String(),
        'transaction_customer_name': widget.pelanggan.namaPelanggan,
        'transaction_cashier': cashierName, // Ganti dengan nama user yang login
        'transaction_total': widget.total,
        'transaction_pay_amount': _calculateFinalTotal(),
        'transaction_discount': diskon,
        'transaction_method': metodeBayar,
        'transaction_note': keterangan,
        'transaction_tax': 0,
        'transaction_status': 'Selesai',
        'transaction_quantity': widget.items.length,
        'transaction_products': jsonEncode(widget.items.map((item) {
          if (item is Service) {
            return {
              'type': 'service',
              'id': item.id,
              'name': item.name,
              'price': item.price,
            };
          } else if (item is ProductWithQuantity) {
            return {
              'type': 'product',
              'id': item.product.productId, // Perhatikan perubahan di sini
              'name': item.product.productName, // Dan di sini
              'price': item.product.productSellPrice,
              'quantity': item.quantity,
            };
          } else if (item is Product) {
            // Untuk kompatibilitas backward
            return {
              'type': 'product',
              'id': item.productId,
              'name': item.productName,
              'price': item.productSellPrice,
              'quantity': 1,
            };
          }
          return {}; // Fallback
        }).toList()),
        'transaction_queue_number': 0, // Sesuaikan jika perlu
        'transaction_profit':
            _calculateProfit(), // Fungsi baru untuk hitung profit
      };

      // Simpan ke database
      final dbService = DatabaseService.instance;
      await dbService.addTransaction(transactionData);

      // Tampilkan konfirmasi
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Transaksi Berhasil'),
          content: Text('Transaksi telah berhasil diproses.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                if (widget.onTransactionSuccess != null) {
                  widget.onTransactionSuccess!();
                }
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error processing transaction: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Gagal memproses transaksi: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  int _calculateProfit() {
    int profit = 0;
    for (var item in widget.items) {
      if (item is ProductWithQuantity) {
        profit += ((item.product.productSellPrice -
                    item.product.productPurchasePrice) *
                item.quantity)
            .toInt();
      } else if (item is Product) {
        profit += (item.productSellPrice - item.productPurchasePrice).toInt();
      }
    }
    return profit;
  }
}
