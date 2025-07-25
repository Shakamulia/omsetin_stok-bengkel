import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:sizer/sizer.dart';

// ignore: camel_case_types
class WidgetDateFromTo_v2 extends StatelessWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Color? bg;

  final void Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;

  const WidgetDateFromTo_v2({
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
          width: double.infinity,
          decoration: BoxDecoration(
              color: bg ?? primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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
                        size: 15.sp,
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
