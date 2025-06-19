import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/report_sold_product.dart';
import 'package:omsetin_bengkel/model/report_sold_services.dart';
import 'package:omsetin_bengkel/model/transaction.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/view/page/detailReportProduct.dart';
import 'package:omsetin_bengkel/view/page/detailReportServices.dart';
import 'package:omsetin_bengkel/view/widget/Notfound.dart';
import 'package:omsetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_bengkel/view/widget/floating_button.dart';
import 'package:omsetin_bengkel/view/widget/modal_status.dart';
import 'package:omsetin_bengkel/view/widget/modals.dart';
import 'package:omsetin_bengkel/view/widget/refresWidget.dart';
import 'package:omsetin_bengkel/view/widget/search.dart';
import 'package:sizer/sizer.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ReportService extends StatefulWidget {
  const ReportService({super.key});

  @override
  State<ReportService> createState() => _ReportServiceState();
}

class _ReportServiceState extends State<ReportService> {
  late Future<List<TransactionData>> Dateproductterjual;
  final DatabaseService _databaseService = DatabaseService.instance;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  Future<List<TransactionData>> _getTransactions() async {
    try {
      return await _databaseService.getTransaction();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  List<TransactionData> _filterTransactions(
      List<TransactionData> transactions) {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return transactions;
    } else {
      return transactions.where((transaction) {
        return transaction.transactionServices.any((services) {
          return services['services_name'].toLowerCase().contains(query);
        });
      }).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    Dateproductterjual = DatabaseService.instance.getServicesSell();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Column(
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
                        icon: Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: Text(
                        "LAPORAN SERVICES",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: SizeHelper.Fsize_normalTitle(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Changed Date Picker Widget
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: DateRangePickerButton(
                        initialStartDate: fromDate,
                        initialEndDate: toDate,
                        onDateRangeChanged: (startDate, endDate) {
                          setState(() {
                            fromDate = startDate;
                            toDate = endDate;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SearchTextField(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  obscureText: false,
                  hintText: "Cari Services",
                  controller: _searchController,
                  maxLines: 1,
                  suffixIcon: null,
                  color: cardColor,
                ),
              ),
              Expanded(
                child: CustomRefreshWidget(
                  child: FutureBuilder<List<TransactionData>>(
                    future: _getTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_outlined,
                                  size: 60, color: Colors.black),
                              Text('Tidak ada transaksi!',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, color: Colors.black)),
                            ],
                          ),
                        );
                      } else {
                        final transactions = snapshot.data!;
                        final filteredTransactions =
                            _filterTransactions(transactions)
                                .where((transaction) {
                          try {
                            String dateStr =
                                transaction.transactionDate.split(', ')[1];
                            DateTime transactionDate =
                                DateFormat("dd/MM/yyyy HH:mm")
                                    .parse(dateStr)
                                    .toLocal();
                            DateTime startDate = DateTime(fromDate.year,
                                    fromDate.month, fromDate.day, 0, 0, 0)
                                .toLocal();
                            DateTime endDate = DateTime(toDate.year,
                                    toDate.month, toDate.day, 23, 59, 59)
                                .toLocal();

                            return (transactionDate.isAfter(startDate) ||
                                    transactionDate
                                        .isAtSameMomentAs(startDate)) &&
                                (transactionDate.isBefore(endDate) ||
                                    transactionDate.isAtSameMomentAs(endDate));
                          } catch (e) {
                            print(
                                "Error parsing date: ${transaction.transactionDate}, Error: $e");
                            return false;
                          }
                        }).toList();

                        Map<String, int> servicesQuantity = {};

                        for (var transaction in filteredTransactions) {
                          for (var services
                              in transaction.transactionServices) {
                            servicesQuantity.update(
                              services['services_name'],
                              (value) => value + (services['quantity'] as int),
                              ifAbsent: () => services['quantity'] ?? 0,
                            );
                          }
                        }

                        List<MapEntry<String, int>> sortedServicesQuantity =
                            servicesQuantity.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value));

                        List<ReportSoldServices> reportSoldServices =
                            sortedServicesQuantity.map((entry) {
                          int servicesId = 0;
                          for (var transaction in filteredTransactions) {
                            for (var services
                                in transaction.transactionServices) {
                              if (services['services_name'] == entry.key) {
                                servicesId = services['services_id'] ?? 0;
                                break;
                              }
                            }
                            if (servicesId != 0) break;
                          }
                          return ReportSoldServices(
                            servicesId: servicesId,
                            servicesName: entry.key,
                            servicesSold: entry.value,
                            dateRange:
                                DateFormat('dd/MM/yyyy').format(fromDate) +
                                    ' - ' +
                                    DateFormat('dd/MM/yyyy').format(toDate),
                          );
                        }).toList();

                        if (filteredTransactions.isEmpty) {
                          return Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NotFoundPage(
                                title: 'Tidak ada transaksi!',
                              ),
                            ],
                          ));
                        }
                        return Stack(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: reportSoldServices.length,
                                      itemBuilder: (context, index) {
                                        final report =
                                            reportSoldServices[index];
                                        return Column(children: [
                                          ZoomTapAnimation(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReportDetailServicesPage(
                                                            servicesName: report
                                                                .servicesName,
                                                          )));
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: cardmain(
                                                product: report.servicesName,
                                                total: report.servicesSold,
                                              ),
                                            ),
                                          ),
                                        ]);
                                      },
                                    ),
                                  ),
                                  services_terlarisCard(
                                    context,
                                    sortedServicesQuantity.isNotEmpty
                                        ? sortedServicesQuantity.first.key
                                        : "Tidak ada",
                                    sortedServicesQuantity.isNotEmpty
                                        ? sortedServicesQuantity.first.value
                                        : 0,
                                  ),
                                ],
                              ),
                            ),
                            ExpensiveFloatingButton(
                              bottom: 100,
                              left: 20,
                              right: 20,
                              text: 'Export',
                              onPressed: () async {
                                CustomModals.modalExportSoldServices(
                                    context, reportSoldServices);
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container services_terlarisCard(
      BuildContext context, String servicesName, int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Produk Terlaris:',
                style: GoogleFonts.poppins(
                  color: whiteMerona,
                  fontSize: SizeHelper.Fsize_textdate(context),
                ),
              ),
              Text(
                '${servicesName.length > 15 ? servicesName.substring(0, 15) + "..." : servicesName}',
                style: GoogleFonts.poppins(
                  color: whiteMerona,
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_textdate(context),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Jumlah Terjual:',
                style: GoogleFonts.poppins(
                  color: whiteMerona,
                  fontSize: SizeHelper.Fsize_textdate(context),
                ),
              ),
              Text(
                quantity.toString(),
                style: GoogleFonts.poppins(
                  color: whiteMerona,
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_textdate(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class cardmain extends StatelessWidget {
  final product;
  final int total;

  const cardmain({
    super.key,
    required this.product,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cardColor,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/products/no-image.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: SizeHelper.Fsize_mainTextCard(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              total.toString(),
              style: GoogleFonts.poppins(
                fontSize: SizeHelper.Fsize_mainTextCard(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
