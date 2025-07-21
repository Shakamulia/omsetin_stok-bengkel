import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/mekanik.dart';
import 'package:omzetin_bengkel/model/report_mekanik_data.dart';
import 'package:omzetin_bengkel/model/report_cashier.dart';
import 'package:omzetin_bengkel/model/transaction.dart';
import 'package:omzetin_bengkel/providers/cashierProvider.dart';
import 'package:omzetin_bengkel/providers/mekanikProvider.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/floating_button.dart';
import 'package:omzetin_bengkel/view/widget/modals.dart';
import 'package:omzetin_bengkel/view/widget/refresWidget.dart';
import 'package:provider/provider.dart';

class ReportMekanik extends StatefulWidget {
  const ReportMekanik({super.key});

  @override
  State<ReportMekanik> createState() => _ReportMekanikState();
}

class _ReportMekanikState extends State<ReportMekanik> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Future<List<TransactionData>> fetchTransactions(String mekanikName) async {
    try {
      return await DatabaseService.instance
          .getTransactionsByPegawaiAndStatus(mekanikName);
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
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
                    "LAPORAN MEKANIK",
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
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: CustomRefreshWidget(
              child: FutureBuilder<List<ReportMekanikData>>(
                future: Provider.of<MekanikProvider>(context, listen: false)
                    .fetchMekanik()
                    .then((mekanikList) async {
                  List<ReportMekanikData> reportDataList = [];
                  for (var mekanik in mekanikList) {
                    final transactions = await fetchTransactions(mekanik);
                    final filteredTransactions = transactions.where((t) {
                      try {
                        String dateStr = t.transactionDate.split(', ')[1];
                        DateTime transactionDate =
                            DateFormat("dd/MM/yyyy HH:mm")
                                .parse(dateStr)
                                .toLocal();
                        DateTime startDateLocal = DateTime(startDate.year,
                                startDate.month, startDate.day, 0, 0, 0)
                            .toLocal();
                        DateTime endDateLocal = DateTime(endDate.year,
                                endDate.month, endDate.day, 23, 59, 59)
                            .toLocal();

                        return (transactionDate.isAfter(startDateLocal) ||
                                transactionDate
                                    .isAtSameMomentAs(startDateLocal)) &&
                            (transactionDate.isBefore(endDateLocal) ||
                                transactionDate.isAtSameMomentAs(endDateLocal));
                      } catch (e) {
                        print(
                            "Error parsing date: ${t.transactionDate}, Error: $e");
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

                      reportDataList.add(ReportMekanikData(
                        mekanikId: 0,
                        mekanikName: mekanik,
                        selesai: selesaiCount,
                        proses: prosesCount,
                        pending: pendingCount,
                        batal: batalCount,
                        mekanikTotalTransactionMoney: filteredTransactions.fold(
                            0, (sum, t) => sum! + t.transactionTotal),
                        mekanikTotalTransaction: filteredTransactions.length,
                        transactionProfit: filteredTransactions.fold(
                            0, (sum, t) => sum + t.transactionProfit),
                      ));
                    }
                  }
                  return reportDataList;
                }).then((future) => future),
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
                  } else {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.separated(
                            itemCount: snapshot.data!.length,
                            separatorBuilder: (context, index) => const Gap(12),
                            itemBuilder: (context, index) {
                              final data = snapshot.data![index];
                              return MekanikReportCard(
                                mekanikData: data,
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
                            final reportDataList =
                                await Provider.of<MekanikProvider>(context,
                                        listen: false)
                                    .fetchMekanik()
                                    .then((mekanik) async {
                              List<ReportMekanikData> reportDataList = [];
                              for (var mekanikName in mekanik) {
                                final transactions =
                                    await fetchTransactions(mekanikName);
                                final filteredTransactions =
                                    transactions.where((t) {
                                  try {
                                    String dateStr =
                                        t.transactionDate.split(', ')[1];
                                    DateTime transactionDate =
                                        DateFormat("dd/MM/yyyy HH:mm")
                                            .parse(dateStr)
                                            .toLocal();
                                    DateTime startDateLocal = DateTime(
                                            startDate.year,
                                            startDate.month,
                                            startDate.day,
                                            0,
                                            0,
                                            0)
                                        .toLocal();
                                    DateTime endDateLocal = DateTime(
                                            endDate.year,
                                            endDate.month,
                                            endDate.day,
                                            23,
                                            59,
                                            59)
                                        .toLocal();

                                    return (transactionDate
                                                .isAfter(startDateLocal) ||
                                            transactionDate.isAtSameMomentAs(
                                                startDateLocal)) &&
                                        (transactionDate
                                                .isBefore(endDateLocal) ||
                                            transactionDate.isAtSameMomentAs(
                                                endDateLocal));
                                  } catch (e) {
                                    print(
                                        "Error parsing date: ${t.transactionDate}, Error: $e");
                                    return false;
                                  }
                                }).toList();

                                if (filteredTransactions.isNotEmpty) {
                                  final selesaiCount = filteredTransactions
                                      .where((t) =>
                                          t.transactionStatus == 'Selesai')
                                      .length;
                                  final prosesCount = filteredTransactions
                                      .where((t) =>
                                          t.transactionStatus == 'Belum Lunas')
                                      .length;
                                  final pendingCount = filteredTransactions
                                      .where((t) =>
                                          t.transactionStatus ==
                                          'Belum Dibayar')
                                      .length;
                                  final batalCount = filteredTransactions
                                      .where((t) =>
                                          t.transactionStatus == 'Dibatalkan')
                                      .length;

                                  reportDataList.add(ReportMekanikData(
                                    mekanikId: mekanik.indexOf(mekanikName) + 1,
                                    mekanikName: mekanikName,
                                    selesai: selesaiCount,
                                    proses: prosesCount,
                                    pending: pendingCount,
                                    batal: batalCount,
                                    mekanikTotalTransactionMoney:
                                        filteredTransactions.fold(
                                            0,
                                            (sum, t) =>
                                                sum! + t.transactionTotal),
                                    mekanikTotalTransaction:
                                        filteredTransactions.length,
                                    transactionProfit:
                                        filteredTransactions.fold(
                                            0,
                                            (sum, t) =>
                                                sum + t.transactionProfit),
                                    transactionDateRange:
                                        '${DateFormat("dd/MM/yyyy").format(startDate.toLocal())} - ${DateFormat("dd/MM/yyyy").format(endDate.toLocal())}',
                                  ));
                                }
                              }
                              return reportDataList;
                            });

                            CustomModals.modalExportMekanikDataExcel(
                                context, reportDataList);
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),

          // Export Button
        ],
      ),
    );
  }
}

class MekanikReportCard extends StatelessWidget {
  final ReportMekanikData mekanikData;

  const MekanikReportCard({super.key, required this.mekanikData});

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
                  mekanikData.mekanikName,
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
                count: mekanikData.selesai ?? 0,
                color: Colors.green,
              ),
              _StatusItem(
                title: 'Belum Lunas',
                count: mekanikData.proses ?? 0,
                color: Colors.orange,
              ),
              _StatusItem(
                title: 'Belum Dibayar',
                count: mekanikData.pending ?? 0,
                color: Colors.blue,
              ),
              _StatusItem(
                title: 'Dibatalkan',
                count: mekanikData.batal ?? 0,
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
                '${mekanikData.mekanikTotalTransaction ?? 0}',
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
                    .format(mekanikData.mekanikTotalTransactionMoney ?? 0),
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
