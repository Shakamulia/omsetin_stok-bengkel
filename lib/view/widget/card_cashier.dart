import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omsetin_stok/model/cashier.dart';
import 'package:omsetin_stok/providers/cashierProvider.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/null_data_alert.dart';
import 'package:omsetin_stok/utils/successAlert.dart';
import 'package:omsetin_stok/view/page/cashier/update_cashier_page.dart';
import 'package:omsetin_stok/view/widget/confirm_delete_dialog.dart';
import 'package:omsetin_stok/view/widget/pin_input.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CardCashier extends StatefulWidget {
  final CashierData cashier;
  final VoidCallback onDeleted;

  const CardCashier({
    super.key,
    required this.cashier,
    required this.onDeleted,
  });

  @override
  State<CardCashier> createState() => _CardCashierState();
}

class _CardCashierState extends State<CardCashier> {
  @override
  Widget build(BuildContext context) {
    var cashierProvider = Provider.of<CashierProvider>(context);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: ZoomTapAnimation(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => UpdateCashierPage(cashier: widget.cashier)));
        },
        child: Card(
          elevation: 0,
          color: cardColor,
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      image: DecorationImage(
                        image: AssetImage(widget.cashier.cashierImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.cashier.cashierName,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 14, color: primaryColor),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.cashier.cashierPhoneNumber.toString(),
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12), // Increased spacing
                if (widget.cashier.cashierName != "Owner")
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmDeleteDialog(
                                message: "Hapus kasir ini?",
                                onConfirm: () async {
                                  await DatabaseService.instance
                                      .deleteProduct(widget.cashier.cashierId);
                                  Navigator.pop(context, true);
                                  showSuccessAlert(
                                      context, "Berhasil Terhapus!");
                                  widget.onDeleted();
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: redColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Hapus",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
