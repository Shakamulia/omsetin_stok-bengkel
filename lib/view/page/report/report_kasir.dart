import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/report_cashier.dart';
import 'package:omsetin_stok/model/transaction.dart';
import 'package:omsetin_stok/providers/cashierProvider.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/view/widget/Notfound.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_stok/view/widget/floating_button.dart';
import 'package:omsetin_stok/view/widget/modals.dart';
import 'package:omsetin_stok/view/widget/refresWidget.dart';
import 'package:provider/provider.dart';

class ReportKasir extends StatefulWidget {
  const ReportKasir({super.key});

  @override
  State<ReportKasir> createState() => _ReportKasirState();
}

class _ReportKasirState extends State<ReportKasir> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [secondaryColor, primaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    title: Text(
                      "LAPORAN KASIR",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: SizeHelper.Fsize_normalTitle(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DateRangePickerButton(
                      initialStartDate: startDate,
                      initialEndDate: endDate,
                      onDateRangeChanged: (startDate, endDate) {
                        setState(() {
                          this.startDate = startDate;
                          this.endDate = endDate;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: CustomRefreshWidget(
                child: FutureBuilder<List<ReportCashierData>>(
                  future: _fetchReportData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: NotFoundPage(
                          title: 'Tidak ada data kasir yang ditemukan',
                        ),
                      );
                    }
                    return _buildReportList(snapshot.data!);
                  },
                ),
              ),
            ),

            // Export Button
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
                left: 16,
                right: 16,
              ),
              child: ExpensiveFloatingButton(
                text: 'Export',
                onPressed: () => _exportReportData(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<ReportCashierData>> _fetchReportData() async {
    final cashiers = await Provider.of<CashierProvider>(context, listen: false)
        .fetchCashiers();

    List<ReportCashierData> reportDataList = [];

    for (var cashierName in cashiers) {
      final transactions = await DatabaseService.instance
          .getTransactionsByCashierAndStatus(cashierName);

      final filteredTransactions = transactions.where((t) {
        try {
          final dateStr = t.transactionDate.split(', ')[1];
          final transactionDate =
              DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();
          final startDateLocal =
              DateTime(startDate.year, startDate.month, startDate.day);
          final endDateLocal =
              DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

          return transactionDate.isAfter(startDateLocal) &&
              transactionDate.isBefore(endDateLocal);
        } catch (e) {
          print("Error parsing date: ${t.transactionDate}, Error: $e");
          return false;
        }
      }).toList();

      if (filteredTransactions.isNotEmpty) {
        reportDataList
            .add(_createReportData(cashierName, filteredTransactions));
      }
    }

    return reportDataList;
  }

  ReportCashierData _createReportData(
      String cashierName, List<TransactionData> transactions) {
    return ReportCashierData(
      cashierId: 0,
      cashierName: cashierName,
      selesai:
          transactions.where((t) => t.transactionStatus == 'Selesai').length,
      proses: transactions
          .where((t) => t.transactionStatus == 'Belum Lunas')
          .length,
      pending: transactions
          .where((t) => t.transactionStatus == 'Belum Dibayar')
          .length,
      batal:
          transactions.where((t) => t.transactionStatus == 'Dibatalkan').length,
      cashierTotalTransactionMoney:
          transactions.fold(0, (sum, t) => sum! + t.transactionTotal),
      cashierTotalTransaction: transactions.length,
      transactionProfit:
          transactions.fold(0, (sum, t) => sum + t.transactionProfit),
    );
  }

  Widget _buildReportList(List<ReportCashierData> data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CashierReportCard(cashierData: data[index]),
        );
      },
    );
  }

  Future<void> _exportReportData(BuildContext context) async {
    final reportDataList = await _fetchReportData();
    CustomModals.modalExportCashierDataExcel(context, reportDataList);
  }
}

class CashierReportCard extends StatelessWidget {
  final ReportCashierData cashierData;

  const CashierReportCard({super.key, required this.cashierData});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cashier Name
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cashierData.cashierName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3.5, // Increased aspect ratio
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            padding: EdgeInsets.zero,
            children: [
              _StatusItem(
                title: 'Selesai',
                count: cashierData.selesai ?? 0,
                color: Colors.green,
              ),
              _StatusItem(
                title: 'Belum Lunas',
                count: cashierData.proses ?? 0,
                color: Colors.orange,
              ),
              _StatusItem(
                title: 'Belum Dibayar',
                count: cashierData.pending ?? 0,
                color: Colors.blue,
              ),
              _StatusItem(
                title: 'Dibatalkan',
                count: cashierData.batal ?? 0,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Total Transactions
          _buildSummaryRow(
            'Total Transaksi:',
            '${cashierData.cashierTotalTransaction ?? 0}',
          ),
          const SizedBox(height: 6),

          // Total Amount
          _buildSummaryRow(
            'Total Nilai:',
            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                .format(cashierData.cashierTotalTransactionMoney ?? 0),
            isAmount: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isAmount ? primaryColor : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _StatusItem({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "${DateFormat('dd MMM').format(initialStartDate)} - ${DateFormat('dd MMM yyyy').format(initialEndDate)}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => _showDatePicker(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    "Pilih",
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontSize: 13,
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

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
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
  }
}
