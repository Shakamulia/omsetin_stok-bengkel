import 'dart:io';

import 'package:flutter/material.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/view/widget/formatter/Rupiah.dart';
import 'package:sizer/sizer.dart';

class ProductTerbaruList extends StatefulWidget {
  const ProductTerbaruList({super.key});

  @override
  State<ProductTerbaruList> createState() => _ProductTerbaruListState();
}

class _ProductTerbaruListState extends State<ProductTerbaruList> {
  DatabaseService db = DatabaseService.instance;
  List<Product> data = [];

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  void getProduct() async {
    List<Product> products = await db.getProducts();
    setState(() {
      data = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: data.length > 3 ? 3 : data.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            children: [
              Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: data[index].productImage ==
                                  'assets/products/no-image.png' ||
                              !File(data[index].productImage).existsSync()
                          ? Image.asset('assets/products/no-image.png')
                          : Image.file(File(data[index].productImage),
                              fit: BoxFit.cover))),
              SizedBox(
                width: 95,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      data[index].productName,
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      CurrencyFormat.convertToIdr(
                          data[index].productSellPrice, 2),
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
