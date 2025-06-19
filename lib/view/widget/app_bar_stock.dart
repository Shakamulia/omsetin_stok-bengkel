import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/view/widget/custom_textfield.dart';

class AppBarStock extends StatelessWidget {
  final String appBarText;
  final List<Widget>? children;

  const AppBarStock({
    super.key,
    required this.appBarText,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        gradient: LinearGradient(
            colors: const [secondaryColor, primaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                appBarText,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Gap(4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children ??
                  [
                    Expanded(
                      child: CustomTextField(
                        obscureText: false,
                        prefixIcon: null,
                        controller: null,
                        maxLines: null,
                        fillColor: Colors.white,
                        suffixIcon: Icon(Icons.search_outlined),
                        hintText: "Cari Produk",
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.qr_code_2_outlined,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
            )
          ],
        ),
      ),
    );
  }
}
