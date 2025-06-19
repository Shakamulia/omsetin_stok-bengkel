import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/services.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/model/services.dart';
import 'package:sizer/sizer.dart';

class CardTransactionService extends StatefulWidget {
  final Service service;
  final int initialQuantity;
  final Function(int)? onQuantityChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onChange;

  const CardTransactionService({
    super.key,
    required this.service,
    this.initialQuantity = 1,
    this.onQuantityChanged,
    this.onDelete,
    this.onChange,
  });

  @override
  _CardTransactionServiceState createState() => _CardTransactionServiceState();
}

class _CardTransactionServiceState extends State<CardTransactionService> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        widget.onQuantityChanged?.call(quantity);
      });
    }
  }

  void increment() {
    setState(() {
      quantity++;
      widget.onQuantityChanged?.call(quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return AspectRatio(
      aspectRatio: isSmallScreen ? 3 / 1.5 : 3 / 1.2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double totalHarga =
              (widget.service.servicePrice.toDouble() * quantity);
          final formattedTotalHarga = formatter.format(totalHarga);
          double hargaService = widget.service.servicePrice.toDouble();
          final formattedHargaService = formatter.format(hargaService);

          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      // Icon Layanan (bukan gambar produk)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.serviceName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              formattedHargaService,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tombol Hapus
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.red),
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(60, 40),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: widget.onChange,
                        child: Text(
                          'Ubah',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: cardColor,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: decrement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: redColor,
                              minimumSize: const Size(30, 30),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Iconify(
                              Ic.outline_minus,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: quantity.toString(),
                                  selection: TextSelection.collapsed(
                                      offset: quantity.toString().length),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                              onChanged: (value) {
                                final newQuantity =
                                    int.tryParse(value) ?? quantity;
                                if (newQuantity > 0) {
                                  setState(() {
                                    quantity = newQuantity;
                                    widget.onQuantityChanged?.call(quantity);
                                  });
                                }
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: increment,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(30, 30),
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Iconify(
                              Ic.outline_plus,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.blueGrey[100],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            'Total :',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formattedTotalHarga,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
