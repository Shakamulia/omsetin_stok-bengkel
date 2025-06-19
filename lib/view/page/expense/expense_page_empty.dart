import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/view/page/expense/input_expense_page.dart';
import 'package:omsetin_bengkel/view/widget/dateFrom-To.dart';
import 'package:omsetin_bengkel/view/widget/floating_button.dart';
import 'package:omsetin_bengkel/view/widget/search.dart';

class ExpensePageEmpty extends StatefulWidget {
  const ExpensePageEmpty({super.key});

  @override
  State<ExpensePageEmpty> createState() => _ExpensePageEmptyState();
}

class _ExpensePageEmptyState extends State<ExpensePageEmpty> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: primaryColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 1,
                            spreadRadius: 1,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Color(0xfffffaf5),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'LIST PENGELUARAN',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
              const Gap(20),
              WidgetDateFromTo(
                  initialEndDate: _toDate,
                  initialStartDate: _fromDate,
                  onDateRangeChanged: (start, end) {
                    setState(() {
                      _fromDate = start;
                      _toDate = end;
                    });
                  }),
              const Gap(20),
              const SearchTextField(
                  obscureText: false,
                  hintText: "Search Data",
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24,
                  ),
                  controller: null,
                  maxLines: 1,
                  suffixIcon: null,
                  color: Colors.white),
              const Gap(20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, color: primaryColor, size: 80),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada Produk di kategori ini !!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 150.0, end: 0.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  child: CustomButton(
                    text: 'Pengeluaran',
                    icon: MaterialSymbols.add,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const InputExpensePage()));
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
