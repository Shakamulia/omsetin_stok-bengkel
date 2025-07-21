import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/page/addStockProduct/select_product.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';

class ProfitPercent extends StatefulWidget {
  const ProfitPercent({super.key});

  @override
  State<ProfitPercent> createState() => _ProfitPercentState();
}

class _ProfitPercentState extends State<ProfitPercent> {
  final DatabaseService dbService = DatabaseService.instance;
  final TextEditingController _persenController = TextEditingController();

  int _tabIndex = 0;
  List<Product> selectedProducts = [];
  List<String> selectedServices = [];

  @override
  void initState() {
    super.initState();
    _persenController.text = '0';
  }

  void _onSubmitUpdateHarga() async {
    final percentage = double.tryParse(_persenController.text);
    if (percentage == null || percentage == 0) {
      showNullDataAlert(context, message: "Harap isi persentase!");
      return;
    }

    if (_tabIndex == 0) {
      await dbService.updateAllProductPrices(percentage);
    } else if (_tabIndex == 1) {
      for (final product in selectedProducts) {
        await dbService.updateProductPriceById(percentage, product.productId);
      }
    }

    showSuccessAlert(context, "Harga Berhasil Diperbarui!");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              leading: const CustomBackButton(),
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              scrolledUnderElevation: 0,
              title: Text(
                'PERSEN PROFIT',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const Gap(20),

                // Input persen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTextField(
                    fillColor: cardColor,
                    hintText: "Persen Profit (%)",
                    controller: _persenController,
                    maxLines: 1,
                    obscureText: false,
                    suffixIcon: const Icon(Icons.percent),
                    prefixIcon: null,
                    keyboardType: TextInputType.number,
                    inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const Gap(20),

                // Tab selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildTabButton("Semua", 0),
                      const Gap(10),
                      _buildTabButton("Spare Part", 1),
                    ],
                  ),
                ),
                const Gap(20),

                // Content area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      if (_tabIndex == 1) ...[
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SelectProduct(
                                    selectedProductStock: selectedProducts),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                selectedProducts = List<Product>.from(result);
                              });
                            }
                          },
                          child: _buildPilihButton(),
                        ),
                        const Gap(10),
                        ...selectedProducts.map((product) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            child: _buildProductCard(product: product),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ExpensiveFloatingButton(
                text: "TERAPKAN",
                onPressed: _onSubmitUpdateHarga,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _tabIndex = index),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
                color: isSelected ? Colors.transparent : primaryColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
        ),
        child: Text(title),
      ),
    );
  }

  Widget _buildPilihButton() {
    final text = _tabIndex == 1
        ? "Pilih Spare Part (${selectedProducts.length})"
        : "Pilih Layanan (${selectedServices.length})";

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({required Product product}) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: "productImage_${product.productId}",
                child: Image.file(
                  File(product.productImage),
                  width: 53,
                  height: 53,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/products/no-image.png",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(product.productSellPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Stok: ${product.productStock}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
