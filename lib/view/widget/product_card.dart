//! GA DI PAKAI LAGI
//! UDAH DI PINDAHIN KE PRODUCT.DART




// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:iconify_flutter/iconify_flutter.dart';
// import 'package:iconify_flutter/icons/bi.dart';
// import 'package:intl/intl.dart';
// import 'package:omzetin_bengkel/services/database_service.dart';
// import 'package:omzetin_bengkel/view/page/product/product.dart';

// class ProductCard extends StatelessWidget {
//   // product image (assets)
//   final String? productImage;
//   final int productId;

//   // product name
//   final String? productName;
//   final String? dateAdded;

//   // product price
//   final int? productSellPrice;
//   final String? productSold;

//   final int? stock;
//   final String? category;

//   const ProductCard({
//     super.key,
//     required this.productSellPrice,
//     required this.productImage,
//     required this.productName,
//     required this.stock,
//     required this.category,
//     required this.productId,
//     this.dateAdded,
//     this.productSold,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final DatabaseService _databaseService = DatabaseService.instance;

//     // Membuat instance NumberFormat untuk format mata uang dalam Rupiah
//     final formatter =
//         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
//     final rupiahPrice = formatter.format(productSellPrice);

//     return GestureDetector(
//       onTap: () {
//         // Tambahkan aksi saat card ditekan jika diperlukan
//       },
//       child: Container(
//         width: double.infinity,
//         height: 80,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color: Colors.white,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(
//                   File(productImage.toString()),
//                   width: 60,
//                   height: 60,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Image.asset(
//                       "assets/products/no-image.png",
//                       width: 60,
//                       height: 60,
//                       fit: BoxFit.cover,
//                     );
//                   },
//                 ),
//               ),
//               const Gap(10),
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               productName ?? "Unknown Product",
//                               style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black),
//                             ),
//                             const Gap(5),
//                             Text(
//                               productSold ?? "None",
//                               style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           category ?? "Unknown Category",
//                           style:
//                               TextStyle(fontSize: 14, color: Colors.grey[600]),
//                         ),
//                         Text(
//                           stock != null ? stock.toString() : "Out of Stock",
//                           style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           rupiahPrice,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           dateAdded != null
//                               ? DateFormat('dd MMMM yyyy')
//                                   .format(DateTime.parse(dateAdded!))
//                               : "Date not Included",
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             showModalBottomSheet(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return Container(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Text(
//                                         "Apakah Anda benar-benar ingin menghapusnya?",
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const Gap(20),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                         children: [
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.pop(context);
//                                             },
//                                             child: const Text("Batal"),
//                                           ),
//                                           ElevatedButton(
//                                             onPressed: () async {
//                                               await _databaseService
//                                                   .deleteProduct(productId);

//                                               Navigator.pop(context, true);
                                              
//                                               ScaffoldMessenger.of(context)
//                                                   .showSnackBar(
//                                                 SnackBar(
//                                                   content: Text(
//                                                       'Berhasil Menghapus Produk "$productImage"'),
//                                                 ),
//                                               );
//                                             },
//                                             child: const Text("Hapus"),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                           child: const Iconify(
//                             Bi.trash,
//                             size: 24,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
