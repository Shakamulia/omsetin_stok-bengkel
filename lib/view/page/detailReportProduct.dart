import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/transaction.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';

class ReportProductDetailPage extends StatelessWidget {
  final String productName;
  final DateTime fromDate;
  final DateTime toDate;

  const ReportProductDetailPage({
    super.key,
    required this.productName,
    required this.fromDate,
    required this.toDate,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green.shade600;
      case 'belum lunas':
      case 'belum dibayar':
        return Colors.orange.shade700;
      case 'dibatalkan':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                "DETAIL PRODUK",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Periode: ${DateFormat('dd/MM/yyyy').format(fromDate)} - ${DateFormat('dd/MM/yyyy').format(toDate)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TransactionData>>(
              future: DatabaseService.instance.getTransaction(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada transaksi'));
                }

                final filteredTransactions = snapshot.data!.where((trx) {
                  // Check if product exists in transaction
                  final hasProduct = trx.transactionProduct.any((p) =>
                      p['product_name'].toString().toLowerCase() ==
                      productName.toLowerCase());

                  // Check status
                  final validStatus = trx.transactionStatus == "Selesai" ||
                      trx.transactionStatus == "Belum Lunas" ||
                      trx.transactionStatus == "Belum Dibayar" ||
                      trx.transactionStatus == "Dibatalkan";

                  // Check date range
                  try {
                    String dateStr = trx.transactionDate.split(', ')[1];
                    DateTime transactionDate =
                        DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();
                    DateTime startDate = DateTime(fromDate.year, fromDate.month,
                            fromDate.day, 0, 0, 0)
                        .toLocal();
                    DateTime endDate = DateTime(
                            toDate.year, toDate.month, toDate.day, 23, 59, 59)
                        .toLocal();

                    return hasProduct &&
                        validStatus &&
                        (transactionDate.isAfter(startDate) ||
                            transactionDate.isAtSameMomentAs(startDate)) &&
                        (transactionDate.isBefore(endDate) ||
                            transactionDate.isAtSameMomentAs(endDate));
                  } catch (e) {
                    print(
                        "Error parsing date: ${trx.transactionDate}, Error: $e");
                    return false;
                  }
                }).toList();

                if (filteredTransactions.isEmpty) {
                  return const Center(
                    child: Text(
                        'Tidak ada transaksi produk ini pada periode yang dipilih.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final trx = filteredTransactions[index];
                    final productDetails = trx.transactionProduct
                        .where((product) =>
                            product['product_name'].toString().toLowerCase() ==
                            productName.toLowerCase())
                        .toList();

                    return Card(
                        color: cardColor,
                        margin: const EdgeInsets.all(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'ID : #${trx.transactionId}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    trx.transactionStatus,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(
                                          trx.transactionStatus),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Divider(
                                  color: secondaryColor, thickness: 1),
                              ...productDetails.map((product) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 16,
                                              color: Colors.blue.shade900),
                                          const SizedBox(width: 4),
                                          Text(
                                            trx.transactionDate,
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Jumlah: ${product['quantity']}',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      Text(
                                        'Harga: Rp${NumberFormat("#,###", "id_ID").format(product['product_sell_price'])}',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Jumlah Bayar:',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp. ',
                                            decimalDigits: 0)
                                        .format(trx.transactionPayAmount),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(
                                          trx.transactionStatus),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
