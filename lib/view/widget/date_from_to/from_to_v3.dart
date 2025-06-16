import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:sizer/sizer.dart';

// ignore: camel_case_types
class WidgetDateFromTov3 extends StatelessWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Color? bg;

  final void Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;

  const WidgetDateFromTov3({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    this.onDateRangeChanged,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    // Nilai default
    DateTime startDate = initialStartDate;
    DateTime endDate = initialEndDate;
    Color colore = Colors.black;

    return Stack(
      children: [
        Container(
          height: 10.h,
          // padding: EdgeInsets.only(bottom: 10),
          width: double.infinity,
          decoration: BoxDecoration(
              color: bg ?? primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(
                        SizeHelper.Size_borderRadius(context))),
                child: Row(
                  children: [
                    Flexible(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != startDate) {
                            startDate = picked;
                            onDateRangeChanged?.call(startDate, endDate);
                          }
                        },
                        child: _buildDateBox(
                          context: context,
                          fromTo: "Tanggal Awal",
                          label: DateFormat('y/M/d').format(startDate),
                          colore: colore,
                          bg: Colors.transparent,
                        ),
                      ),
                    ),
                    // Arrow Icon
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: primaryColor,
                      size: 10,
                    ),
                    // To Date Picker
                    Flexible(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != endDate) {
                            endDate = picked;
                            onDateRangeChanged?.call(startDate, endDate);
                          }
                        },
                        child: _buildDateBox(
                          context: context,
                          fromTo: "Tanggal Akhir",
                          label: DateFormat('y/M/d').format(endDate),
                          colore: colore,
                          bg: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateBox(
      {required String label,
      required String fromTo,
      required Color colore,
      required Color? bg,
      required BuildContext context}) {
    return Container(
      height: SizeHelper.Size_cardDate(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bg ?? Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  fromTo,
                  style: GoogleFonts.poppins(
                    color: colore,
                    fontSize: SizeHelper.Fsize_textdate(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: colore,
                        fontSize: SizeHelper.Fsize_textdate(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(5),
                    Icon(
                      Icons.date_range_outlined,
                      color: colore,
                      size: 17.sp,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
