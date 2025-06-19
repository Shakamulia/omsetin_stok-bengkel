import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_bengkel/utils/modal_animation.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:lottie/lottie.dart';

void showNotEnoughStock(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: ModalAnimation(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            width: 300,
            height: 300,
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 300,
                      maxHeight: 300,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/lottie/NullDataAlert.json',
                          width: 150,
                          height: 150,
                        ),
                        const Gap(10),
                        Text(
                          message ?? 'Stok tidak mencukupi!',
                          style: GoogleFonts.poppins(
                            fontSize: SizeHelper.Fsize_alert(context),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/images/close.png",
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
