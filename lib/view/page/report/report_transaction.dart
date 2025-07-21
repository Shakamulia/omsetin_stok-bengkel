import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/transaction.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/card_report_transaction.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/refresWidget.dart';
import 'package:sizer/sizer.dart';

class ReportTransaction extends StatefulWidget {
  const ReportTransaction({super.key});

  @override
  _ReportTransactionState createState() => _ReportTransactionState();
}

class _ReportTransactionState extends State<ReportTransaction> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  bool test = false;
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<TransactionData>> _getTransactions() async {
    try {
      return await _databaseService.getTransaction();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  int _calculateTotalProfit(List<TransactionData> transactions) {
    int totalProfit = 0;
    for (var transaction in transactions) {
      totalProfit += transaction.transactionProfit;
    }
    return totalProfit;
  }

  int _calculateTotalOmzet(List<TransactionData> transactions) {
    int totalOmzet = 0;
    for (var transaction in transactions) {
      totalOmzet += transaction.transactionTotal;
    }
    return totalOmzet;
  }

  int _countTransactions(List<TransactionData> transactions) {
    return transactions.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                AppBar(
                  leading: IconButton(
                    icon:
                        Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    "LAPORAN TRANSAKSI",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: SizeHelper.Fsize_normalTitle(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Replaced with the new DateRangePickerButton
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: DateRangePickerButton(
                    initialStartDate: dateFrom,
                    initialEndDate: dateTo,
                    onDateRangeChanged: (startDate, endDate) {
                      setState(() {
                        dateFrom = startDate;
                        dateTo = endDate;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TransactionData>>(
              future: _getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: CustomRefreshWidget(child: NotFoundPage()));
                } else {
                  final transactions = snapshot.data!.where((transaction) {
                    try {
                      String dateStr =
                          transaction.transactionDate.split(', ')[1];
                      DateTime transactionDate = DateFormat("dd/MM/yyyy HH:mm")
                          .parse(dateStr)
                          .toLocal();
                      DateTime startDate = DateTime(dateFrom.year,
                              dateFrom.month, dateFrom.day, 0, 0, 0)
                          .toLocal();
                      DateTime endDate = DateTime(
                              dateTo.year, dateTo.month, dateTo.day, 23, 59, 59)
                          .toLocal();

                      bool statusValid =
                          transaction.transactionStatus == "Selesai" ||
                              transaction.transactionStatus == "Belum Lunas";

                      return statusValid &&
                          (transactionDate.isAfter(startDate) ||
                              transactionDate.isAtSameMomentAs(startDate)) &&
                          (transactionDate.isBefore(endDate) ||
                              transactionDate.isAtSameMomentAs(endDate));
                    } catch (e) {
                      print(
                          "Error parsing date: ${transaction.transactionDate}, Error: $e");
                      return false;
                    }
                  }).toList();

                  int totalProfit = _calculateTotalProfit(transactions);
                  int totalCount = _countTransactions(transactions);

                  if (transactions.isEmpty) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Gap(10),
                        NotFoundPage(
                          title: 'Tidak ada transaksi yang ditemukan',
                        ),
                      ],
                    ));
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: CustomRefreshWidget(
                          child: ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              return Column(children: [
                                Gap(10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: CardReportTransactions(
                                      transaction: transaction),
                                ),
                              ]);
                            },
                          ),
                        ),
                      ),
                      Gap(10),
                      Container(
                        width: double.infinity,
                        height: 10.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: primaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Jumlah Transaksi: $totalCount",
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                      Text(
                                          "Total Omzet:  ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(_calculateTotalOmzet(transactions))}",
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white)),
                                    ],
                                  ),
                                  Text(
                                    "Total Profit: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(totalProfit)}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Add the DateRangePickerButton widget class
class DateRangePickerButton extends StatelessWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime, DateTime) onDateRangeChanged;

  const DateRangePickerButton({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onDateRangeChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "${DateFormat('dd MMM yyyy').format(initialStartDate)} - ${DateFormat('dd MMM yyyy').format(initialEndDate)}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Date picker button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 2,
              ),
              onPressed: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDateRange: DateTimeRange(
                    start: initialStartDate,
                    end: initialEndDate,
                  ),
                  builder: (context, child) {
                    return Dialog(
                      insetPadding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 40,
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: primaryColor,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        ),
                      ),
                    );
                  },
                );
                if (picked != null) {
                  onDateRangeChanged(picked.start, picked.end);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 18, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    "Pilih Tanggal",
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
