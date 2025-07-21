import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/income.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/utils/search_utils.dart';
import 'package:omzetin_bengkel/view/page/Income/Income_detail.dart';
import 'package:omzetin_bengkel/view/page/income/input_expense_page.dart';
import 'package:omzetin_bengkel/view/page/product/product.dart';
import 'package:omzetin_bengkel/view/widget/Income_card.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/date_from_to/fromTo_v2.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/floating_button.dart';
import 'package:omzetin_bengkel/view/widget/modals.dart';
import 'package:omzetin_bengkel/view/widget/refresWidget.dart';
import 'package:omzetin_bengkel/view/widget/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => IncomePageState();
}

class IncomePageState extends State<IncomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  void _filterSearch(String query) {
    setState(() {
      _futureIncome = fetchIncomes().then((incomes) {
        return filterItems(
            incomes, _searchController.text, (income) => income.incomeName);
      });
    });
  }

  late Future<List<Income>> _futureIncome;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _futureIncome = fetchIncomes();
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
    });
  }

  Future<List<Income>> fetchIncomes() async {
    return await _databaseService.getIncome();
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _searchController.addListener(() {
      _filterSearch(_searchController.text);
    });
    _futureIncome = fetchIncomes();
  }

  //! SECURITY
  bool? _isAddIncomeOn;
  Future<void> _loadPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAddIncomeOn = prefs.getBool('tambahPemasukan') ?? false;
    });
  }

  Future<List<Income>> fetchincomesDate() async {
    final incomes = await _databaseService.getIncome();
    return incomes.where((income) {
      final incomeDate = DateTime.parse(income.incomeDate);
      return (incomeDate.isAtSameMomentAs(_fromDate) ||
              incomeDate.isAfter(_fromDate)) &&
          (_toDate == null ||
              incomeDate.isAtSameMomentAs(_toDate) ||
              incomeDate.isBefore(_toDate.add(const Duration(days: 1))));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Column(children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            secondaryColor, // Warna akhir gradient
                            primaryColor, // Warna awal gradient
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: AppBar(
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        centerTitle: true,
                        title: Text(
                          "DATA PEMASUKAN",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: SizeHelper.Fsize_normalTitle(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DateRangePickerButton(
                        initialStartDate: _fromDate,
                        initialEndDate: _toDate,
                        onDateRangeChanged: (startDate, endDate) {
                          setState(() {
                            _fromDate = startDate;
                            _toDate = endDate;
                            _futureIncome = fetchincomesDate();
                          });
                        },
                      ),
                    ),
                    Gap(10),
                  ])),
              Gap(13),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchTextField(
                  prefixIcon: const Icon(Icons.search, size: 24),
                  obscureText: false,
                  hintText: "Cari Pemasukan",
                  controller: _searchController,
                  maxLines: 1,
                  suffixIcon: null,
                  color: cardColor,
                ),
              ),
              Gap(10),
              Expanded(
                child: FutureBuilder(
                  future: _futureIncome,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return CustomRefreshWidget(
                          child: Center(child: NotFoundPage()));
                    } else {
                      final incomes = snapshot.data!.where((income) {
                        try {
                          String dateStr = income.incomeDate;
                          DateTime incomeDate =
                              DateFormat("yyyy-MM-dd").parse(dateStr).toLocal();
                          DateTime startDate = DateTime(_fromDate.year,
                                  _fromDate.month, _fromDate.day, 0, 0, 0)
                              .toLocal();
                          DateTime endDate = DateTime(_toDate.year,
                                  _toDate.month, _toDate.day, 23, 59, 59)
                              .toLocal();

                          return (incomeDate.isAfter(startDate) ||
                                  incomeDate.isAtSameMomentAs(startDate)) &&
                              (incomeDate.isBefore(endDate) ||
                                  incomeDate.isAtSameMomentAs(endDate));
                        } catch (e) {
                          print(
                              "Error parsing date: ${income.incomeDate}, Error: $e");
                          return false;
                        }
                      }).toList();
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: CustomRefreshWidget(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            itemCount: incomes.length,
                            itemBuilder: (context, index) {
                              final income = incomes[index];
                              final formattedAmount =
                                  ProductPage.formatCurrency(
                                      income.incomeAmount);
                              return ZoomTapAnimation(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => IncomeDetailPage(
                                                income: income,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    if (index == 0) const Gap(5),
                                    IncomeCard(
                                      title: income.incomeName,
                                      date: DateTime.parse(income.incomeDate)
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],
                                      amount: formattedAmount,
                                      dateAdded: income.incomeDateAdded,
                                      note: income.incomeNote,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          if (_isAddIncomeOn != true)
            ExpensiveFloatingButton(
              right: 12,
              left: 12,
              text: 'TAMBAH',
              onPressed: () async {
                final result = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const InputIncomePage()));

                if (result != null) {
                  setState(() {
                    _futureIncome = fetchIncomes();
                    _fromDate = DateTime.now();
                    _toDate = DateTime.now();
                  });
                }
              },
            )
        ],
      ),
    );
  }
}

class DateRangePickerButton extends StatelessWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime, DateTime) onDateRangeChanged;

  const DateRangePickerButton({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onDateRangeChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "${DateFormat('dd MMM yyyy').format(initialStartDate)} - ${DateFormat('dd MMM yyyy').format(initialEndDate)}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Date picker button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 2,
              ),
              onPressed: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDateRange: DateTimeRange(
                    start: initialStartDate,
                    end: initialEndDate,
                  ),
                  builder: (context, child) {
                    return Dialog(
                      insetPadding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 40,
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: primaryColor,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        ),
                      ),
                    );
                  },
                );
                if (picked != null) {
                  onDateRangeChanged(picked.start, picked.end);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 18, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    "Pilih Tanggal",
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
