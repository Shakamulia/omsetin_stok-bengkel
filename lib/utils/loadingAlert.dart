import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_stok/utils/modal_animation.dart';
import 'package:lottie/lottie.dart';
import 'package:gap/gap.dart';

void showLoadingAlert(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/lottie/loading-2.json',
                        width: 150,
                        height: 150,
                      ),
                      const Gap(10),
                      Text(
                        message ?? 'Sedang diproses, tunggu sebentar!',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Positioned(
                //   top: 0,
                //   right: 0,
                //   child: GestureDetector(
                //     onTap: () {
                //       Navigator.pop(context);
                //     },
                //     child: Image.asset(
                //       "assets/images/close.png",
                //       height: 40,
                //       width: 40,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
