import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/transaction.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/floating_button.dart';
import 'package:omzetin_bengkel/view/widget/modals.dart';
import 'package:omzetin_bengkel/view/widget/formatter/Rupiah.dart';
import 'package:sizer/sizer.dart';

class ReportPaymentMethod extends StatefulWidget {
  const ReportPaymentMethod({super.key});

  @override
  State<ReportPaymentMethod> createState() => _ReportPaymentMethodState();
}

class _ReportPaymentMethodState extends State<ReportPaymentMethod> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

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
                //
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
                    "LAPORAN METODE PEMBAYARAN",
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
                    initialStartDate: dateFrom,
                    initialEndDate: dateTo,
                    onDateRangeChanged: (startDate, endDate) {
                      setState(() {
                        this.dateFrom = startDate;
                        this.dateTo = endDate;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: FutureBuilder(
              future: Future.wait([
                DatabaseService.instance.getTransaction(),
                DatabaseService.instance.getPaymentMethods(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data![0].isEmpty) {
                  return NotFoundPage(
                    title: 'Tidak ada transaksi!',
                  );
                } else {
                  final transactions =
                      (snapshot.data![0] as List<TransactionData>)
                          .where((transaction) {
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

                      return (transactionDate.isAfter(startDate) ||
                              transactionDate.isAtSameMomentAs(startDate)) &&
                          (transactionDate.isBefore(endDate) ||
                              transactionDate.isAtSameMomentAs(endDate));
                    } catch (e) {
                      print(
                          "Error parsing date: ${transaction.transactionDate}, Error: $e");
                      return false;
                    }
                  }).toList();

                  final groupedTransactions = <String, int>{};
                  for (var transaction in transactions) {
                    final method = transaction.transactionPaymentMethod;
                    groupedTransactions[method] =
                        (groupedTransactions[method] ?? 0) +
                            transaction.transactionPayAmount.toInt();
                  }

                  if (groupedTransactions.isEmpty) {
                    return NotFoundPage(
                      title: 'Tidak ada transaksi!',
                    );
                  }

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: groupedTransactions.length,
                          separatorBuilder: (context, index) => const Gap(12),
                          itemBuilder: (context, index) {
                            final entry =
                                groupedTransactions.entries.elementAt(index);
                            return MetodePembayaran(
                              name: entry.key,
                              total: entry.value,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: ExpensiveFloatingButton(
                          text: 'Export',
                          onPressed: () {
                            final paymentData =
                                groupedTransactions.entries.map((entry) {
                              return {
                                'paymentMethod': entry.key,
                                'totalAmount': entry.value,
                                'paymentDateFrom':
                                    DateFormat("dd/MM/yyyy").format(dateFrom),
                                'paymentDateTo':
                                    DateFormat("dd/MM/yyyy").format(dateTo),
                              };
                            }).toList();
                            CustomModals.modalExportPaymentMethodData(
                                context, paymentData);
                          },
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

class MetodePembayaran extends StatelessWidget {
  final String name;
  final int total;

  const MetodePembayaran({
    super.key,
    required this.name,
    required this.total,
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
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeHelper.Fsize_mainTextCard(context),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormat.convertToIdr(total, 0),
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
