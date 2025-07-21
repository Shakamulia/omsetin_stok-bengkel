import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/utils/colors.dart';

// ignore: camel_case_types
class WidgetDateFromTo extends StatelessWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Color? bg;

  final void Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;

  const WidgetDateFromTo({
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
    Color colore = (bg != null) ? Colors.white : Colors.black;
    double sizere = (MediaQuery.of(context).size.width <= 360) ? 11 : 14;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // From Date Picker
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
                fsize: sizere,
                fromTo: "Tanggal Awal",
                label: DateFormat('y/M/d').format(startDate),
                colore: colore,
                bg: bg,
              ),
            ),
          ),
          // Arrow Icon
          Icon(
            Icons.play_arrow,
            color: primaryColor,
            size: 30,
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
                fromTo: "Tanggal Akhir",
                label: DateFormat('y/M/d').format(endDate),
                colore: colore,
                bg: bg,
                fsize: sizere,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox({
    required String label,
    required String fromTo,
    required Color colore,
    required Color? bg,
    required double? fsize,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bg ?? Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fromTo,
                    style: GoogleFonts.poppins(
                      color: colore,
                      fontSize: fsize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: colore,
                          fontSize: fsize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(10),
                      Icon(
                        Icons.date_range_outlined,
                        color: colore,
                        size: 15,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
