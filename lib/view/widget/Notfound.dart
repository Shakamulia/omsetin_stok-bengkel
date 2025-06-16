import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NotFoundPage extends StatelessWidget {
  final String? title;
  const NotFoundPage({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
    mainAxisAlignment: MainAxisAlignment.center, 
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Icon(Icons.search, size: 35.sp),
      Gap(10),
      Text(title ?? 'Data Tidak Ditemukan',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
          ), textAlign: TextAlign.center,),
          
    ]);
  }
}
