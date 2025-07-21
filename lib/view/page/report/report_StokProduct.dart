import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/formatter/Rupiah.dart';
import 'package:omzetin_bengkel/view/widget/modals.dart';
import 'package:omzetin_bengkel/view/widget/refresWidget.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:sizer/sizer.dart';

class ReportStokproduct extends StatefulWidget {
  const ReportStokproduct({super.key});

  @override
  State<ReportStokproduct> createState() => _ReportStokproductState();
}

class _ReportStokproductState extends State<ReportStokproduct> {
  late Future<List<Product>> _dataAllProduct;
  Map<String, int> _totalStockData = {'totalStock': 0, 'totalNilaiStock': 0};

  @override
  void initState() {
    super.initState();
    _dataAllProduct = DatabaseService.instance.getallProductsandSUM();
    fetchData();
  }

  void fetchData() async {
    final data = await DatabaseService.instance.getTotalStock();
    setState(() {
      _totalStockData = data;
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
            ),
            child: SafeArea(
              child: Column(
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
                      "LAPORAN STOK SPARE PART",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: SizeHelper.Fsize_normalTitle(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _StockProductCard(
                      totalStock: _totalStockData['totalStock'] ?? 0,
                      totalNilaiStock: _totalStockData['totalNilaiStock'] ?? 0,
                    ),
                  ),
                  const Gap(10),
                ],
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _dataAllProduct,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return CustomRefreshWidget(
                      child: Center(child: NotFoundPage()));
                } else {
                  final products = snapshot.data!;

                  return Stack(
                    children: [
                      CustomRefreshWidget(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 80, // Space for button
                            top: 10,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: _ProductStockCard(
                                namaProduk: product.productName,
                                kategori: product.categoryName ??
                                    '', // handle null case
                                stock: product.productStock,
                                nilaiStock: (product.productPurchasePrice *
                                        product.productStock)
                                    .toDouble(),
                                image: product.productImage,
                                hargamodal: product.productPurchasePrice,
                                hargajual: product.productSellPrice,
                              ),
                            );
                          },
                        ),
                      ),

                      // Export Button
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: ExpensiveFloatingButton(
                          text: 'EXPORT',
                          onPressed: () {
                            CustomModals.modalExportStockProduct(
                                context, products);
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

class _StockProductCard extends StatelessWidget {
  final int totalStock;
  final int totalNilaiStock;

  const _StockProductCard({
    required this.totalStock,
    required this.totalNilaiStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeHelper.Size_headerStockProduct(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Total Stok',
                style: GoogleFonts.poppins(
                  fontSize: SizeHelper.Fsize_mainTextCard(context),
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalStock.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Total Nilai Stok',
                style: GoogleFonts.poppins(
                  fontSize: SizeHelper.Fsize_mainTextCard(context),
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormat.convertToIdr(totalNilaiStock, 2),
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductStockCard extends StatelessWidget {
  final String namaProduk;
  final String kategori;
  final int stock;
  final double nilaiStock;
  final String image;
  final int hargamodal;
  final int hargajual;

  const _ProductStockCard({
    required this.namaProduk,
    required this.kategori,
    required this.stock,
    required this.nilaiStock,
    required this.image,
    required this.hargamodal,
    required this.hargajual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 12.h,
                  width: 25.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: image == "assets/products/no-image.png"
                        ? Image.asset("assets/products/no-image.png")
                        : Image.file(
                            File(image),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaProduk,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori: $kategori',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 1,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Harga Jual: ${CurrencyFormat.convertToIdr(hargajual.toInt(), 2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Harga Modal: ${CurrencyFormat.convertToIdr(hargamodal.toInt(), 2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stock Info Footer
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stok: $stock',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: stock < 1 ? Colors.red : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Nilai: ${CurrencyFormat.convertToIdr(nilaiStock.toInt(), 0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
