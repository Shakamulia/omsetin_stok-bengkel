import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:omsetin_stok/utils/colors.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          height: 4,
          width: 4,
          child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Stack(
                children: const [
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 6,
                    bottom: 0,
                    child: Center(
                        child: Iconify(MaterialSymbols.arrow_back_ios_rounded,
                            color: bgColor)),
                  )
                ],
              ))),
    );
  }
}
