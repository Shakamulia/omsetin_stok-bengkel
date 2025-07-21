import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/report_sold_product.dart';
import 'package:omzetin_bengkel/model/transaction.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/page/detailReportProduct.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/modals.dart';
import 'package:omzetin_bengkel/view/widget/refresWidget.dart';
import 'package:omzetin_bengkel/view/widget/search.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ReportProduct extends StatefulWidget {
  const ReportProduct({super.key});

  @override
  State<ReportProduct> createState() => _ReportProductState();
}

class _ReportProductState extends State<ReportProduct> {
  final DatabaseService _databaseService = DatabaseService.instance;
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  List<ReportSoldProduct> reportSoldProducts = [];
  String mostPopularProduct = "Tidak ada";
  int mostPopularQuantity = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await _databaseService.getTransaction();
    _filterAndGenerateReport(transactions);
  }

  void _filterAndGenerateReport(List<TransactionData> transactions) {
    final searchFiltered = _filterTransactionsBySearch(transactions);
    final dateFiltered = _filterTransactionsByDate(searchFiltered);
    _generateReportData(dateFiltered);
  }

  List<TransactionData> _filterTransactionsBySearch(
      List<TransactionData> transactions) {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) return transactions;

    return transactions.where((transaction) {
      return transaction.transactionProduct.any((product) {
        return product['product_name'].toLowerCase().contains(query);
      });
    }).toList();
  }

  List<TransactionData> _filterTransactionsByDate(
      List<TransactionData> transactions) {
    return transactions.where((transaction) {
      try {
        String dateStr = transaction.transactionDate.split(', ')[1];
        DateTime transactionDate =
            DateFormat("dd/MM/yyyy HH:mm").parse(dateStr);
        DateTime startDate =
            DateTime(fromDate.year, fromDate.month, fromDate.day);
        DateTime endDate =
            DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
        return transactionDate.isAfter(startDate) &&
            transactionDate.isBefore(endDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  void _generateReportData(List<TransactionData> filteredTransactions) {
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

    List<MapEntry<String, int>> sortedProductQuantity = productQuantity.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      reportSoldProducts = sortedProductQuantity.map((entry) {
        String productUnit = '';
        String productImage = '';
        int productId = 0;
        String productCategory = '';
        for (var transaction in filteredTransactions) {
          for (var product in transaction.transactionProduct) {
            if (product['product_name'] == entry.key) {
              productUnit = product['product_unit'] ?? 'pcs';
              productImage =
                  product['product_image'] ?? 'assets/products/no-image.png';
              productId = product['productId'] ?? 0;
              productCategory = product['category_name'] ?? '';
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
              '${DateFormat('dd/MM/yyyy').format(fromDate)} - ${DateFormat('dd/MM/yyyy').format(toDate)}',
        );
      }).toList();

      mostPopularProduct = sortedProductQuantity.isNotEmpty
          ? sortedProductQuantity.first.key
          : "Tidak ada";
      mostPopularQuantity = sortedProductQuantity.isNotEmpty
          ? sortedProductQuantity.first.value
          : 0;
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
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: Text(
                        "LAPORAN SPARE PART",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: SizeHelper.Fsize_normalTitle(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: DateRangePickerButton(
                        initialStartDate: fromDate,
                        initialEndDate: toDate,
                        onDateRangeChanged: (startDate, endDate) {
                          setState(() {
                            fromDate = startDate;
                            toDate = endDate;
                            _loadData();
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
                  onRefresh: _loadData,
                  child: reportSoldProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_outlined,
                                  size: 60, color: Colors.black),
                              Text('Tidak ada spare part terjual!',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, color: Colors.black)),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: reportSoldProducts.length,
                                itemBuilder: (context, index) {
                                  final report = reportSoldProducts[index];
                                  return Column(
                                    children: [
                                      ZoomTapAnimation(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ReportProductDetailPage(
                                                productName: report.productName,
                                                fromDate: fromDate,
                                                toDate: toDate,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            color: Colors.white,
                                            elevation: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        child: Image.file(
                                                          File(report
                                                              .productImage),
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Image.asset(
                                                              'assets/products/no-image.png',
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            report.productName,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: SizeHelper
                                                                  .Fsize_mainTextCard(
                                                                      context),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            report.productUnit,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: SizeHelper
                                                                  .Fsize_mainTextCard(
                                                                      context),
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    report.productSold
                                                        .toString(),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: SizeHelper
                                                          .Fsize_mainTextCard(
                                                              context),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(5),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 25),
                              width: double.infinity,
                              decoration: BoxDecoration(color: primaryColor),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Spare Part Terlaris:',
                                        style: GoogleFonts.poppins(
                                          color: whiteMerona,
                                          fontSize: SizeHelper.Fsize_textdate(
                                              context),
                                        ),
                                      ),
                                      Text(
                                        mostPopularProduct.length > 15
                                            ? "${mostPopularProduct.substring(0, 15)}..."
                                            : mostPopularProduct,
                                        style: GoogleFonts.poppins(
                                          color: whiteMerona,
                                          fontWeight: FontWeight.bold,
                                          fontSize: SizeHelper.Fsize_textdate(
                                              context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Jumlah Terjual:',
                                        style: GoogleFonts.poppins(
                                          color: whiteMerona,
                                          fontSize: SizeHelper.Fsize_textdate(
                                              context),
                                        ),
                                      ),
                                      Text(
                                        mostPopularQuantity.toString(),
                                        style: GoogleFonts.poppins(
                                          color: whiteMerona,
                                          fontWeight: FontWeight.bold,
                                          fontSize: SizeHelper.Fsize_textdate(
                                              context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          if (reportSoldProducts.isNotEmpty)
            ExpensiveFloatingButton(
              bottom: 100,
              left: 20,
              right: 20,
              text: 'Export',
              onPressed: () {
                CustomModals.modalExportSoldProduct(
                    context, reportSoldProducts);
              },
            ),
        ],
      ),
    );
  }
}
