import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/report_sold_product.dart';
import 'package:omsetin_stok/model/transaction.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/view/page/detailReportProduct.dart';
import 'package:omsetin_stok/view/widget/Notfound.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_stok/view/widget/floating_button.dart';
import 'package:omsetin_stok/view/widget/modal_status.dart';
import 'package:omsetin_stok/view/widget/modals.dart';
import 'package:omsetin_stok/view/widget/refresWidget.dart';
import 'package:omsetin_stok/view/widget/search.dart';
import 'package:sizer/sizer.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ReportProduct extends StatefulWidget {
  const ReportProduct({super.key});

  @override
  State<ReportProduct> createState() => _ReportProductState();
}

class _ReportProductState extends State<ReportProduct> {
  late Future<List<TransactionData>> Dateproductterjual;
  final DatabaseService _databaseService = DatabaseService.instance;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Dateproductterjual = DatabaseService.instance.getproductsell();
  }

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
        return transaction.transactionProduct.any((product) {
          return product['product_name'].toLowerCase().contains(query);
        });
      }).toList();
    }
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
                        "LAPORAN Spare Part",
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
                  hintText: "Cari Spare Part",
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

                        Map<String, int> productQuantity = {};

                        for (var transaction in filteredTransactions) {
                          for (var product in transaction.transactionProduct) {
                            productQuantity.update(
                              product['product_name'],
                              (value) => value + (product['quantity'] as int),
                              ifAbsent: () => product['quantity'] ?? 0,
                            );
                          }
                        }

                        List<MapEntry<String, int>> sortedProductQuantity =
                            productQuantity.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value));

                        List<ReportSoldProduct> reportSoldProducts =
                            sortedProductQuantity.map((entry) {
                          String productUnit = '';
                          String productImage = '';
                          int productId = 0;
                          String productCategory = '';
                          for (var transaction in filteredTransactions) {
                            for (var product
                                in transaction.transactionProduct) {
                              if (product['product_name'] == entry.key) {
                                productUnit = product['product_unit'] ?? 'pcs';
                                productImage = product['product_image'] ??
                                    'assets/products/no-image.png';
                                productId = product['productId'] ?? 0;
                                productCategory =
                                    product['category_name'] ?? '';
                                break;
                              }
                            }
                            if (productUnit.isNotEmpty) break;
                          }
                          return ReportSoldProduct(
                            productId: productId,
                            productName: entry.key,
                            productUnit: productUnit,
                            productImage: productImage,
                            productSold: entry.value,
                            productCategory: productCategory,
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
                            Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: reportSoldProducts.length,
                                    itemBuilder: (context, index) {
                                      final report = reportSoldProducts[index];
                                      return Column(children: [
                                        ZoomTapAnimation(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReportProductDetailPage(
                                                          productName: report
                                                              .productName,
                                                        )));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: cardmain(
                                              product: report.productCategory,
                                              satuan: report.productUnit,
                                              image: report.productImage,
                                              total: report.productSold,
                                            ),
                                          ),
                                        ),
                                      ]);
                                    },
                                  ),
                                ),
                              ],
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
                                        CustomModals.modalExportSoldProduct(
                                            context, reportSoldProducts);
                                      },
                                    ),
                                  ),
                                  const Gap(10),
                                  product_terlarisCard(
                                    context,
                                    sortedProductQuantity.first.key,
                                    sortedProductQuantity.first.value,
                                  ),
                                ],
                              ),
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

  Container product_terlarisCard(
      BuildContext context, String productName, int quantity) {
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
                'Spare Part Terlaris:',
                style: GoogleFonts.poppins(
                  color: whiteMerona,
                  fontSize: SizeHelper.Fsize_textdate(context),
                ),
              ),
              Text(
                '${productName.length > 15 ? productName.substring(0, 15) + "..." : productName}',
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
  final satuan;
  final String image;
  final int total;

  const cardmain({
    super.key,
    required this.product,
    required this.satuan,
    required this.image,
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
                  child: Image.file(
                    File(image),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/products/no-image.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
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
                    Text(
                      satuan.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: SizeHelper.Fsize_mainTextCard(context),
                        color: Colors.grey[600],
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
