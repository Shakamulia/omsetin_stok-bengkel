import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/utils/colors.dart';

class ReportCashierCard extends StatefulWidget {
  final String name;
  final int total;
  final int totalPrice;
  final int selesai;
  final int Blunas;
  final int Bbayar;
  final int batal;

  const ReportCashierCard({
    super.key,
    required this.name,
    required this.total,
    required this.totalPrice,
    required this.selesai,
    required this.Blunas,
    required this.Bbayar,
    required this.batal,
  });

  @override
  State<ReportCashierCard> createState() => _ReportCashierCardState();
}

class _ReportCashierCardState extends State<ReportCashierCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 4), // Arah bayangan
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar Section
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 60,
                    width: 60,
                    color: Colors.black,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const Gap(8),
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333), // Warna teks utama
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Status Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      rowStatus('Selesai', widget.selesai),
                      rowStatus('Belum Lunas', widget.Blunas),
                      rowStatus('Belum Dibayar', widget.Bbayar),
                      rowStatus('Batal', widget.batal),
                    ],
                  ),
                  const Gap(8),

                  // Total & Amount
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ${widget.total}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF777777), // Warna teks sekunder
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      NumberFormat.currency(
                              locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
                          .format(widget.totalPrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: primaryColor, // Warna utama
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget rowStatus(String label, int count) {
  return Column(
    children: [
      Text(
        count.toString(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primaryColor, // Warna utama
        ),
      ),
      const Gap(4),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF777777), // Warna teks sekunder
        ),
      ),
    ],
  );
}
