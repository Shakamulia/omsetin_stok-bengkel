import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/transaction.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';

class ReportDetailServicesPage extends StatelessWidget {
  final String servicesName;
  final DateTime fromDate;
  final DateTime toDate;

  const ReportDetailServicesPage({
    super.key,
    required this.servicesName,
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
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  color: Colors.white,
                ),
                Text(
                  "DETAIL SERVICES",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: FutureBuilder<List<TransactionData>>(
              future: DatabaseService.instance.getTransaction(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada transaksi'));
                }

                final filteredTransactions = snapshot.data!.where((trx) {
                  final hasService = trx.transactionServices.any((p) =>
                      p['services_name'].toString().toLowerCase() ==
                      servicesName.toLowerCase());

                  final validStatus = trx.transactionStatus == "Selesai" ||
                      trx.transactionStatus == "Belum Lunas" ||
                      trx.transactionStatus == "Belum Dibayar" ||
                      trx.transactionStatus == "Dibatalkan";

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

                    return hasService &&
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
                    child: Text('Tidak ada transaksi services ini.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final trx = filteredTransactions[index];
                    final servicesDetails = trx.transactionServices
                        .where((services) =>
                            services['services_name']
                                .toString()
                                .toLowerCase() ==
                            servicesName.toLowerCase())
                        .toList();

                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Baris atas: ID dan Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'ID : #${trx.transactionId} ${trx.transactionCustomerName}',
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
                                    color:
                                        _getStatusColor(trx.transactionStatus),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Kasir
                            Row(
                              children: [
                                Icon(
                                  Icons.person_2_outlined,
                                  size: 16,
                                  color: Colors.blue.shade900,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Kasir: ${trx.transactionCashier}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: secondaryColor, thickness: 1),

                            // Detail services
                            ...servicesDetails.map((services) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.blue.shade900,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          trx.transactionDate,
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Jumlah: ${services['quantity']}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    Text(
                                      'Harga: Rp${NumberFormat("#,###", "id_ID").format(services['services_price'])}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                            // Total Bayar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Jumlah Bayar:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(trx.transactionPayAmount),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _getStatusColor(trx.transactionStatus),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
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
