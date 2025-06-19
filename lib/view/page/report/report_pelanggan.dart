import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/report_pelanggan_data.dart';

import 'package:omsetin_bengkel/model/transaction.dart';
import 'package:omsetin_bengkel/providers/pelangganProvider.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/view/widget/Notfound.dart';
import 'package:omsetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_bengkel/view/widget/modals.dart';
import 'package:omsetin_bengkel/view/widget/refresWidget.dart';
import 'package:provider/provider.dart';

class ReportPelanggan extends StatefulWidget {
  const ReportPelanggan({super.key});

  @override
  State<ReportPelanggan> createState() => _ReportPelangganState();
}

class _ReportPelangganState extends State<ReportPelanggan> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  ReportPelangganData? topCustomer;
  bool isLoading = false;
  List<ReportPelangganData> reportDataList = [];

  Future<List<TransactionData>> fetchTransactions(String pelangganName) async {
    try {
      return await DatabaseService.instance
          .getTransactionsByPelangganAndStatus(pelangganName);
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<void> loadReportData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      reportDataList = [];
      topCustomer = null;
    });

    try {
      final pelangganList =
          await Provider.of<Pelangganprovider>(context, listen: false)
              .fetchPelanggan();

      List<ReportPelangganData> tempList = [];

      for (var pelanggan in pelangganList) {
        final transactions = await fetchTransactions(pelanggan);
        final filteredTransactions = transactions.where((t) {
          try {
            String dateStr = t.transactionDate.split(', ')[1];
            DateTime transactionDate =
                DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();
            DateTime startDateLocal = DateTime(
                startDate.year, startDate.month, startDate.day, 0, 0, 0);
            DateTime endDateLocal =
                DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

            return (transactionDate.isAfter(startDateLocal) ||
                    transactionDate.isAtSameMomentAs(startDateLocal)) &&
                (transactionDate.isBefore(endDateLocal) ||
                    transactionDate.isAtSameMomentAs(endDateLocal));
          } catch (e) {
            print("Error parsing date: ${t.transactionDate}, Error: $e");
            return false;
          }
        }).toList();

        if (filteredTransactions.isNotEmpty) {
          final selesaiCount = filteredTransactions
              .where((t) => t.transactionStatus == 'Selesai')
              .length;
          final prosesCount = filteredTransactions
              .where((t) => t.transactionStatus == 'Belum Lunas')
              .length;
          final pendingCount = filteredTransactions
              .where((t) => t.transactionStatus == 'Belum Dibayar')
              .length;
          final batalCount = filteredTransactions
              .where((t) => t.transactionStatus == 'Dibatalkan')
              .length;

          tempList.add(ReportPelangganData(
            pelangganId: 0,
            pelangganName: pelanggan,
            selesai: selesaiCount,
            proses: prosesCount,
            pending: pendingCount,
            batal: batalCount,
            pelangganTotalTransactionMoney: filteredTransactions.fold(
                0, (sum, t) => sum! + t.transactionTotal),
            pelangganTotalTransaction: filteredTransactions.length,
            transactionProfit: filteredTransactions.fold(
                0, (sum, t) => sum + t.transactionProfit),
          ));
        }
      }

      if (tempList.isNotEmpty) {
        tempList.sort((a, b) => (b.pelangganTotalTransaction ?? 0)
            .compareTo(a.pelangganTotalTransaction ?? 0));
        setState(() {
          topCustomer = tempList.first;
          reportDataList = tempList;
        });
      }
    } catch (e) {
      print('Error loading report data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadReportData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // AppBar with back button and title
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
                    "LAPORAN Pelanggan",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: SizeHelper.Fsize_normalTitle(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Date Picker
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: DateRangePickerButton(
                    initialStartDate: startDate,
                    initialEndDate: endDate,
                    onDateRangeChanged: (startDate, endDate) {
                      setState(() {
                        this.startDate = startDate;
                        this.endDate = endDate;
                      });
                      loadReportData();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Top Customer Section
          if (topCustomer != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pelanggan Teraktif",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topCustomer!.pelangganName,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Total Transaksi: ${topCustomer!.pelangganTotalTransaction}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "Terbanyak",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child: CustomRefreshWidget(
              onRefresh: loadReportData,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reportDataList.isEmpty
                      ? Center(
                          child: NotFoundPage(
                            title: 'Tidak ada data pelanggan yang ditemukan',
                          ),
                        )
                      : Stack(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ListView.separated(
                                itemCount: reportDataList.length,
                                separatorBuilder: (context, index) =>
                                    const Gap(12),
                                itemBuilder: (context, index) {
                                  final data = reportDataList[index];
                                  return PelangganReportCard(
                                    pelangganData: data,
                                  );
                                },
                              ),
                            ),
                            ExpensiveFloatingButton(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              text: 'Export',
                              onPressed: () async {
                                final exportData = reportDataList.map((e) {
                                  return ReportPelangganData(
                                    pelangganId: e.pelangganId,
                                    pelangganName: e.pelangganName,
                                    selesai: e.selesai,
                                    proses: e.proses,
                                    pending: e.pending,
                                    batal: e.batal,
                                    pelangganTotalTransactionMoney:
                                        e.pelangganTotalTransactionMoney,
                                    pelangganTotalTransaction:
                                        e.pelangganTotalTransaction,
                                    transactionProfit: e.transactionProfit,
                                    transactionDateRange:
                                        '${DateFormat("dd/MM/yyyy").format(startDate.toLocal())} - ${DateFormat("dd/MM/yyyy").format(endDate.toLocal())}',
                                  );
                                }).toList();

                                CustomModals.modalExportPelangganDataExcel(
                                    context, exportData);
                              },
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

class PelangganReportCard extends StatelessWidget {
  final ReportPelangganData pelangganData;

  const PelangganReportCard({super.key, required this.pelangganData});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // pegawai Name
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
                  pelangganData.pelangganName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _StatusItem(
                title: 'Selesai',
                count: pelangganData.selesai ?? 0,
                color: Colors.green,
              ),
              _StatusItem(
                title: 'Belum Lunas',
                count: pelangganData.proses ?? 0,
                color: Colors.orange,
              ),
              _StatusItem(
                title: 'Belum Dibayar',
                count: pelangganData.pending ?? 0,
                color: Colors.blue,
              ),
              _StatusItem(
                title: 'Dibatalkan',
                count: pelangganData.batal ?? 0,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Transaksi:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${pelangganData.pelangganTotalTransaction ?? 0}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Nilai:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                NumberFormat.currency(
                        locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                    .format(pelangganData.pelangganTotalTransactionMoney ?? 0),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
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
