import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_stok/model/expenceModel.dart';
import 'package:omsetin_stok/model/transaction.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_stok/view/widget/modals.dart';
import 'package:omsetin_stok/view/widget/refresWidget.dart';
import 'package:sizer/sizer.dart';

class ReportProfit extends StatefulWidget {
  const ReportProfit({super.key});

  @override
  _ReportProfitState createState() => _ReportProfitState();
}

class _ReportProfitState extends State<ReportProfit> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  final DatabaseService _db = DatabaseService.instance;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  late Future<List<Map<String, dynamic>>> reportData;
  List<Map<String, dynamic>> reportExcel = [];

  @override
  void initState() {
    super.initState();
    reportData = _loadReportData();
    print(reportData);
  }

  Future<List<Map<String, dynamic>>> _loadReportData() async {
    try {
      final transactions = await _db.getTransaction();
      final expenses = await _db.getExpenseList();
      final stockData = await _db.getTotalStock();

      final filteredTransactions = _filterTransactions(transactions);
      final filteredExpenses = _filterExpenses(expenses);

      final omzet = _calculateTotalOmzet(filteredTransactions);
      final profitKotor = _calculateTotalProfit(filteredTransactions);
      final totalExpense = _calculateTotalExpense(filteredExpenses);
      final profitBersih = profitKotor - totalExpense;
      final totalModal = stockData['totalNilaiStock'] ?? 0;

      reportExcel.addAll([
        {'omzet': omzet},
        {'totalModal': totalModal},
        {'totalExpense': totalExpense},
        {'profitKotor': profitKotor},
        {'profitBersih': profitBersih},
      ]);

      return [
        {'teksLaporan': 'Omzet', 'nominal': currencyFormatter.format(omzet)},
        {
          'teksLaporan': 'Modal Produk',
          'nominal': currencyFormatter.format(totalModal)
        },
        {
          'teksLaporan': 'Total Pengeluaran',
          'nominal': currencyFormatter.format(totalExpense)
        },
        {
          'teksLaporan': 'Profit Kotor',
          'nominal': currencyFormatter.format(profitKotor)
        },
        {
          'teksLaporan': 'Profit Bersih',
          'nominal': currencyFormatter.format(profitBersih)
        },
      ];
    } catch (e) {
      print("❌ Error loading report data: $e");
      return [];
    }
  }

  List<TransactionData> _filterTransactions(
      List<TransactionData> transactions) {
    return transactions.where((transaction) {
      try {
        String dateStr = transaction.transactionDate.split(', ')[1];
        DateTime transactionDate =
            DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();

        DateTime startDate =
            DateTime(dateFrom.year, dateFrom.month, dateFrom.day, 0, 0, 0)
                .toLocal();
        DateTime endDate =
            DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59)
                .toLocal();

        bool statusValid = transaction.transactionStatus == "Selesai" ||
            transaction.transactionStatus == "Belum Lunas";

        return statusValid &&
            (transactionDate.isAfter(startDate) ||
                transactionDate.isAtSameMomentAs(startDate)) &&
            (transactionDate.isBefore(endDate) ||
                transactionDate.isAtSameMomentAs(endDate));
      } catch (e) {
        print(
            "❌ Error parsing transaction date: ${transaction.transactionDate}, $e");
        return false;
      }
    }).toList();
  }

  List<Expensemodel> _filterExpenses(List<Expensemodel> expenses) {
    return expenses.where((expense) {
      try {
        DateTime expenseDate = DateTime.parse(expense.date!).toLocal();

        DateTime startDate =
            DateTime(dateFrom.year, dateFrom.month, dateFrom.day, 0, 0, 0)
                .toLocal();
        DateTime endDate =
            DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59)
                .toLocal();

        return (expenseDate.isAfter(startDate) ||
                expenseDate.isAtSameMomentAs(startDate)) &&
            (expenseDate.isBefore(endDate) ||
                expenseDate.isAtSameMomentAs(endDate));
      } catch (e) {
        print("❌ Error parsing expense date: ${expense.date}, $e");
        return false;
      }
    }).toList();
  }

  int _calculateTotalProfit(List<TransactionData> transactions) {
    return transactions.fold(0, (sum, tx) => sum + tx.transactionProfit);
  }

  int _calculateTotalOmzet(List<TransactionData> transactions) {
    return transactions.fold(0, (sum, tx) => sum + tx.transactionTotal);
  }

  int _calculateTotalExpense(List<Expensemodel> expenses) {
    return expenses.fold(0, (sum, e) => sum + (e.amount ?? 0));
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
                    "LAPORAN PROFIT",
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
                      reportData = _loadReportData();
                    },
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: reportData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else {
                      final laporanList = snapshot.data ?? [];
                      return CustomRefreshWidget(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              16, 16, 16, 80), // Ruang untuk button
                          itemCount: laporanList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = laporanList[index];
                            return LaporanProfitWidget(
                              teksLaporan: item['teksLaporan'],
                              nominal: item['nominal'],
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ExpensiveFloatingButton(
                        left: 12,
                        right: 12,
                        text: 'Export',
                        onPressed: () async {
                          CustomModals.modalExportProfit(context, reportExcel);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

class LaporanProfitWidget extends StatelessWidget {
  final String teksLaporan;
  final String nominal;
  const LaporanProfitWidget({
    super.key,
    required this.teksLaporan,
    required this.nominal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5.w,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                topLeft: Radius.circular(15),
              ),
              color: primaryColor,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    teksLaporan,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeHelper.Fsize_mainTextCard(context),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    nominal.toString(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeHelper.Fsize_mainTextCard(context),
                      color: primaryColor,
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
