import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/transaction.dart';
import 'package:omsetin_stok/utils/colors.dart';

class CardReportTransactions extends StatelessWidget {
  CardReportTransactions({
    super.key,
    required this.transaction,
  });

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (transaction.transactionStatus) {
      case "Selesai":
        statusColor = greenColor;
        break;
      case "Belum Lunas":
        statusColor = yellowColor;
        break;
      case "Belum Dibayar":
        statusColor = redColor;
        break;
      case "Dibatalkan":
        statusColor = greyColor;
        break;
      default:
        statusColor = primaryColor;
    }
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Center(child: Icon(Icons.receipt_long_rounded)),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID #${transaction.transactionId} ${transaction.transactionCustomerName} ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                const SizedBox(width: 4),
                    Text(
                      transaction.transactionDate,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(
              thickness: 1,
              color: primaryColor,
            ),
                Text(
                  'Jumlah Pesanan : ${transaction.transactionQuantity}',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Harga : ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(transaction.transactionTotal)}',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
            Text(
              'Total Profit : ${NumberFormat.currency(symbol: 'Rp. ', decimalDigits: 0).format(transaction.transactionProfit)}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
              ],
            ),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
