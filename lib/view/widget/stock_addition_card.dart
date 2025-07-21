import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/stock_addition.dart';
import 'package:omzetin_bengkel/utils/colors.dart';

class StockAdditionCard extends StatefulWidget {
  const StockAdditionCard({
    super.key,
    required this.stock,
  });

  final StockAdditionData stock;

  @override
  State<StockAdditionCard> createState() => _StockAdditionCardState();
}

class _StockAdditionCardState extends State<StockAdditionCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Nama Produk & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "+${widget.stock.stockAdditionAmount}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    widget.stock.stockAdditionName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Center(
                  child: Text(
                    widget.stock.stockAdditionDate,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          if (widget.stock.stockAdditionNote.isNotEmpty)
            Text(
              "Catatan: ${widget.stock.stockAdditionNote}",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
