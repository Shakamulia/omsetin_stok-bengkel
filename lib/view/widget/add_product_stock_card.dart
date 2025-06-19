import 'package:flutter/material.dart';
import 'package:omsetin_bengkel/model/product.dart';
import 'package:gap/gap.dart';
import 'package:omsetin_bengkel/utils/colors.dart';

class StockCardScreen extends StatefulWidget {
  final Product product;
  final int initialQuantity;
  final Function(int amount)? onAmountChanged;
  final TextEditingController? noteController;

  const StockCardScreen({
    super.key,
    required this.product,
    this.initialQuantity = 0,
    this.onAmountChanged,
    this.noteController,
  });

  @override
  _StockCardScreenState createState() => _StockCardScreenState();
}

class _StockCardScreenState extends State<StockCardScreen> {
  late int amount;

  @override
  void initState() {
    super.initState();
    amount = widget.initialQuantity;
  }

  int get newStock => widget.product.productStock + amount;

  void setAmount(int value) {
    if (value < 0) return; // Pastikan jumlah tidak negatif
    setState(() {
      amount = value;
      widget.onAmountChanged?.call(amount); // Memanggil callback jika ada
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.03,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Produk
          Text(
            widget.product.productName,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: primaryColor),

          // Bagian Penambahan Stok
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol - Jumlah +
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove,
                        color: primaryColor, size: screenWidth * 0.06),
                    onPressed: () => setAmount(amount - 1),
                  ),
                  SizedBox(
                    width: screenWidth * 0.1,
                    child: Center(
                      child: TextField(
                        controller: TextEditingController(text: "$amount"),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: screenWidth * 0.045),
                        onSubmitted: (value) {
                          final int? newValue = int.tryParse(value);
                          if (newValue != null) {
                            setAmount(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add,
                        color: primaryColor, size: screenWidth * 0.06),
                    onPressed: () => setAmount(amount + 1),
                  ),
                ],
              ),

              // Catatan
              Container(
                width: screenWidth * 0.35,
                height: screenHeight * 0.05,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: widget.noteController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Catatan',
                    icon: Icon(Icons.notes, color: Colors.grey),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: TextStyle(fontSize: screenWidth * 0.035),
                ),
              ),
            ],
          ),
          Gap(10),
          // Informasi Stok
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.015,
            ),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Stok sekarang: ${widget.product.productStock} ${widget.product.productUnit}",
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.03),
                ),
                Text(
                  "Setelah ditambah: $newStock ${widget.product.productUnit}",
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.03),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
