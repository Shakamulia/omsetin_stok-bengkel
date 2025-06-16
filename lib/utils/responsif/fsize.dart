import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SizeHelper {
  // for page where the appbar isn't blue background
  static double Fsize_normalTitle(BuildContext context) {
    return MediaQuery.of(context).size.width <= 500 ? 18.sp : 18.sp;
  }

// FONT SIZE

  static double Fsize_title(BuildContext context) {
    return 21.sp;
  }

  static double Fsize_title1(BuildContext context) {
    return 17.sp;
  }

  static double Fsize_textdate(BuildContext context) {
    return 16.sp;
  }

  static double Fsize_mainTextCard(BuildContext context) {
    return 16.sp;
  }

  // alert (success, failed, null (warning) )
  static double Fsize_alert(BuildContext context) {
    return 14.sp;
  }

  static double Fsize_expensiveFloatingButton(BuildContext context) {
    return MediaQuery.of(context).size.width <= 400 ? 18.sp : 14.sp;
  }

  // keuntungan product
  static double Fsize_productProfit(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return 7.sp;
    }
    return MediaQuery.of(context).size.width <= 400 ? 12.sp : 10.sp;
  }

  // setting font (like pengaturan suara, printer, lainnya)
  static double Fsize_spaceBetweenTextAndButton(BuildContext context) {
    return MediaQuery.of(context).size.width <= 400 ? 16.sp : 15.sp;
  }

  static double Fsize_settingLabel(BuildContext context) {
    return MediaQuery.of(context).size.width <= 360 ? 18.sp : 16.sp;
  }

// SELAIN FONT

  static double Size_headerCard(BuildContext context) {
    return 26.h;
  }

  static double Size_cardDate(BuildContext context) {
    return 7.h;
  }

  // report stock product
  static double Size_headerStockProduct(BuildContext context) {
    return 1.h;
  }

  // floating button
  static double Size_floatingButton(BuildContext context) {
    return 100.w;
  }

  // border radius
  static double Size_borderRadius(BuildContext context) {
    return 20;
  }
}
