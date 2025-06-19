import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/product.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/colors.dart';

class SelectStockProductCard extends StatefulWidget {
  final bool isSelected;
  final Product product;
  final VoidCallback onSelect;
  final List<Product>? selectedProductStock;

  const SelectStockProductCard({
    super.key,
    required this.product,
    required this.onSelect,
    required this.isSelected,
    required this.selectedProductStock,
  });

  @override
  State<SelectStockProductCard> createState() => _SelectStockProductCardState();
}

class _SelectStockProductCardState extends State<SelectStockProductCard> {
  bool get isSelected =>
      widget.selectedProductStock
          ?.any((element) => element.productId == widget.product.productId) ??
      false;

  final DatabaseService databaseService = DatabaseService.instance;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelect,
      key: ValueKey(widget.product),
      child: Card(
        color: isSelected ? greenColor : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.product.productImage),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/products/no-image.png",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Gap(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(2),
                  Row(
                    children: [
                      Text(
                        widget.product.productStock.toString(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Gap(2),
                      Text(
                        widget.product.productUnit,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  Text(
                    NumberFormat.currency(
                            locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
                        .format(widget.product.productSellPrice),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
