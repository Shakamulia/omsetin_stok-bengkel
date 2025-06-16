import 'package:flutter/material.dart';
import 'package:omsetin_stok/model/product.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/view/page/product/product.dart';

class NewProductHome extends StatefulWidget {
  final Widget child;

  const NewProductHome({super.key, required this.child});

  @override
  NewProductHomeState createState() => NewProductHomeState();
}

class NewProductHomeState extends State<NewProductHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Produk Terbaru",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "Baru ditambahkan",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductPage(),
                      ));
                },
                child: const Row(
                  children: [
                    Text(
                      "Lihat semua",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: primaryColor,
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 12,
          ),
          SizedBox(height: 100, child: widget.child)
        ],
      ),
    );
  }
}
