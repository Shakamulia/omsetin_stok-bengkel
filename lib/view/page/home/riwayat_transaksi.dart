import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/transaction.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/view/widget/formatter/Rupiah.dart';

class RiwayatTransaksiList extends StatefulWidget {
  final DateTime date;
  final VoidCallback? onRefresh;

  const RiwayatTransaksiList({super.key, required this.date, this.onRefresh});

  @override
  State<RiwayatTransaksiList> createState() => _RiwayatTransaksiListState();
}

class _RiwayatTransaksiListState extends State<RiwayatTransaksiList> {
  DatabaseService db = DatabaseService.instance;
  List<TransactionData> transactionData = [];
  // Removed invalid top-level await expression.

  @override
  void initState() {
    super.initState();
    getTransaction();
    // Auto-refresh setiap 30 detik (opsional)
    Timer.periodic(Duration(seconds: 30), (timer) => getTransaction());
  }

  void refreshData() {
    getTransaction(); // Panggil ulang getTransaction()
    if (widget.onRefresh != null) {
      widget.onRefresh!(); // Jika ada callback eksternal
    }
  }

  Future<void> getTransaction() async {
    List<TransactionData> allTransactions = await db.getTransaction();

    setState(() {
      transactionData = allTransactions.where((transaction) {
        try {
          DateTime transactionDate =
              DateTime.parse(transaction.transactionDate);
          return transactionDate.year == widget.date.year &&
              transactionDate.month == widget.date.month &&
              transactionDate.day == widget.date.day;
        } catch (e) {
          print(
              "Error parsing date: ${transaction.transactionDate}, Error: $e");
          return false;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getTransaction(); // Refresh data saat di-tarik
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: transactionData.length,
        itemBuilder: (context, index) {
          final statusColorMap = {
            "Selesai": greenColor,
            "Belum Lunas": yellowColor,
            "Belum Dibayar": redColor,
            "Dibatalkan": greyColor,
          };

          final statusColor =
              statusColorMap[transactionData[index].transactionStatus] ??
                  secondaryColor;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: Center(child: Icon(Icons.receipt_long_rounded)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Antrian ${transactionData[index].transactionQueueNumber}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(
                            transactionData[index].transactionDate)),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      CurrencyFormat.convertToIdr(
                          transactionData[index].transactionTotal, 2),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
