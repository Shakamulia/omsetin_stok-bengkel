import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/view/widget/custom_textfield.dart';
import 'package:omsetin_stok/view/widget/expensiveAnimatedButton.dart';

Future<dynamic> bottomSheetModal(BuildContext context,
    {String? title,
    String? hintText,
    VoidCallback? onPressed,
    TextEditingController? controller}) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Wrap(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25)),
                      color: primaryColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title ?? "Default",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          child: Iconify(Ic.round_close, color: Colors.white),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CustomTextField(
                            obscureText: false,
                            hintText: hintText ?? "Default",
                            prefixIcon: null,
                            controller: controller,
                            fillColor: Colors.grey[300],
                            maxLines: 1,
                            suffixIcon: null),
                        Gap(10),
                        ExpensiveAnimatedButton(
                          onPressed: onPressed,
                          text: "SIMPAN",
                        ),
                        Gap(20),
                      ],
                    ),
                  )
                  // Add more widgets here as needed
                ],
              ),
            );
          },
        );
      });
}
