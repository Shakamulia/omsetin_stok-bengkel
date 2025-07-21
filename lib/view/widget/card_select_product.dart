import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CardSelectProduct extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onSelect;
  final String? productImage;
  final int productId;
  final String? productName;
  final String? dateAdded;
  final int? productSellPrice;
  final String? productSold;
  final int? stock;
  final String? category;

  const CardSelectProduct({
    super.key,
    required this.isSelected,
    required this.onSelect,
    this.productImage,
    required this.productId,
    this.productName,
    this.dateAdded,
    this.productSellPrice,
    this.productSold,
    this.stock,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final rupiahPrice = formatter.format(productSellPrice);

    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: double.infinity,
      height: screenWidth * 0.20,
      child: ZoomTapAnimation(
        onTap: onSelect,
        child: Card(
          color:
              isSelected ? const Color.fromARGB(171, 46, 204, 112) : cardColor,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      productImage != null && File(productImage!).existsSync()
                          ? Image.file(
                              File(productImage!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "assets/products/no-image.png",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName ?? "Unknown Product",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        stock != null ? stock.toString() : "Out of Stock",
                        style: TextStyle(
                          fontSize: 14,
                          color: stock != null && stock! < 1
                              ? Colors.red
                              : (isSelected ? Colors.white : Colors.grey),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        productSellPrice != null
                            ? rupiahPrice
                            : "Unknown Price",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// widget/select_product_card.dart
// import 'package:flutter/material.dart';
// import 'package:omzetin_bengkel/model/products.dart';

// class SelectProductCard extends StatelessWidget {
//   final Produq product;
//   final bool isSelected;
//   final VoidCallback onSelect;

//   const SelectProductCard({
//     Key? key,
//     required this.product,
//     required this.isSelected,
//     required this.onSelect,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onSelect,
//       child: Card(
//         color: isSelected ? Colors.green : Colors.white, // Ubah warna berdasarkan status
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(product.productName),
//             // Tambahkan informasi produk lainnya di sini
//           ],
//         ),
//       ),
//     );
//   }
// }