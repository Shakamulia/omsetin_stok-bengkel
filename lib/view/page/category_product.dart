// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:omzetin_bengkel/model/product.dart';
// import 'package:omzetin_bengkel/utils/colors.dart';
// import 'package:omzetin_bengkel/view/page/home-2.dart';
// import 'package:omzetin_bengkel/view/widget/category_product.dart';
// import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
// import 'package:omzetin_bengkel/view/widget/page_title.dart';
// import 'package:omzetin_bengkel/view/widget/primary_button.dart';

// class CategoryProductPage extends StatefulWidget {
//   const CategoryProductPage({super.key});

//   @override
//   State<CategoryProductPage> createState() => _CategoryProductPageState();
// }

// class _CategoryProductPageState extends State<CategoryProductPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: greyColor,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               children: [
//                 const PageTitle(title: "KATEGORI"),
//                 const Gap(20),
//                 Container(
//                   height: 155,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.white),
//                   child: Padding(
//                       padding: const EdgeInsets.only(
//                         top: 26,
//                         right: 12,
//                         left: 12,
//                       ),

//                       child: Column(
//                         children: [
//                           const CustomTextField(
//                               suffixIcon: null,
//                               maxLines: null,
//                               obscureText: false,
//                               hintText: "Nama Kategori",
//                               prefixIcon: Icon(Icons.email),
//                               controller: null),
//                           const Gap(14),
//                           PrimaryButton(
//                               widthPercent: 1.0,
//                               text: "SIMPAN",
//                               onPressed: () {
//                                 Navigator.push(context, MaterialPageRoute(builder: (_) => const Home()));
//                               })
//                         ],
//                       )),
//                 ),
//                 const Gap(20),
//                 const Row(
//                   children: [Text("Kategori Product")],
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                       itemCount: itemProduct.length,
//                       itemBuilder: (context, index) {
//                         return CategoryProduct(
//                             productCategory: itemProduct[index].productCategory,
//                             onTapEdit: () {
//                               print("waw");
//                             },
//                             onTapDelete: () {
//                               print("waw");
//                             });
//                       }),
//                 )
//               ],
//             ),
//           ),
//         ));
//   }
// }
