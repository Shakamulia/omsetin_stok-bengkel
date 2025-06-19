import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_bengkel/utils/colors.dart';

class IncomeCard extends StatefulWidget {
  final String title;
  final String date;
  final String dateAdded;
  final String amount;
  final String note;

  const IncomeCard({
    super.key,
    required this.title,
    required this.date,
    required this.dateAdded,
    required this.note,
    required this.amount,
  });

  @override
  _IncomeCardState createState() => _IncomeCardState();

  static String truncate(String text,
      {int length = 20, String omission = '...'}) {
    if (text.length <= length) {
      return text;
    }
    return text.substring(0, length) + omission;
  }
}

class _IncomeCardState extends State<IncomeCard> {
  Color _isntNow = Colors.black;

  String _getDateText(String date) {
    DateTime inputDate = DateTime.parse(date);
    DateTime now = DateTime.now();
    Duration difference = now.difference(inputDate);

    setState(() {
      _isntNow = difference.inDays == 0 ? greenColor : Colors.black;
    });

    if (difference.inDays == 0) {
      return "Ditambahkan Hari ini";
    } else if (difference.inDays == 1) {
      return "Ditambahkan Kemarin";
    } else {
      return "${difference.inDays.abs()} hari yang lalu";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.2),
            //     spreadRadius: 2,
            //     blurRadius: 5,
            //     offset: const Offset(0, 3),
            //   ),
            // ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      IncomeCard.truncate(widget.title),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      IncomeCard.truncate(widget.amount,
                                          length: widget.title.length > 15
                                              ? 10
                                              : 100),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(IncomeCard.truncate(widget.note,
                                    length: 8,
                                    omission: "... (Lihat lebih banyak)")),
                                const Divider(
                                  color: primaryColor,
                                  thickness: 1,
                                ),
                                const Gap(2),
                                // Changed color of date to black
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        IncomeCard.truncate(widget.date),
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        _getDateText(widget.dateAdded),
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: _isntNow,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
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
              ),
              // Positioned delete icon
            ],
          ),
        ),
      ),
    );
  }
}
