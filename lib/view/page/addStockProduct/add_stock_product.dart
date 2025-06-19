import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/stock_addition.dart';
import 'package:omsetin_bengkel/providers/securityProvider.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/utils/successAlert.dart';
import 'package:omsetin_bengkel/utils/toast.dart';
import 'package:omsetin_bengkel/view/page/addStockProduct/select_and_add_stock.dart';
import 'package:omsetin_bengkel/view/page/expense/expense_page.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/date_from_to/fromTo_v2.dart';
import 'package:omsetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_bengkel/view/widget/refresWidget.dart';
import 'package:omsetin_bengkel/view/widget/stock_addition_card.dart';
import 'package:provider/provider.dart';

class AddStockProductPage extends StatefulWidget {
  const AddStockProductPage({super.key});

  @override
  State<AddStockProductPage> createState() => _AddStockProductPageState();
}

class _AddStockProductPageState extends State<AddStockProductPage> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  Future<List<StockAdditionData>> _stockAdditionList = Future.value([]);
  Timer? _timer;

  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _searchController = TextEditingController();
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _loadStockAddition();
    // _startAutoRefresh(); // Mulai timer untuk refresh otomatis
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hentikan timer saat widget dibuang
    super.dispose();
  }

  Future<void> _loadStockAddition() async {
    setState(() {
      _stockAdditionList = DatabaseService.instance.getStockAddition();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? dateFrom : dateTo,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          dateFrom = picked;
        } else {
          dateTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var securityProvider = Provider.of<SecurityProvider>(context);
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    secondaryColor,
                    primaryColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  AppBar(
                    leading: const CustomBackButton(),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    title: Text(
                      "STOK SPARE PART",
                      style: GoogleFonts.poppins(
                        color: bgColor,
                        fontSize: SizeHelper.Fsize_normalTitle(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DateRangePickerButton(
                      initialStartDate: dateFrom,
                      initialEndDate: dateTo,
                      onDateRangeChanged: (startDate, endDate) {
                        setState(() {
                          dateFrom = startDate;
                          dateTo = endDate;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Gap(10),
            Expanded(
              child: FutureBuilder<List<StockAdditionData>>(
                future: _stockAdditionList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon(Icons.search_off_outlined,
                          //     size: 50, color: Colors.black),
                          Text("Tidak ada data penambahan stok spare part",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              )),
                        ],
                      ),
                    );
                  } else {
                    final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
                    // Set dateFrom ke awal hari dan dateTo ke akhir hari
                    DateTime startDate = DateTime(
                        dateFrom.year, dateFrom.month, dateFrom.day, 0, 0, 0);
                    DateTime endDate = DateTime(
                        dateTo.year, dateTo.month, dateTo.day, 23, 59, 59);

                    final filteredStock = snapshot.data!.where((stock) {
                      try {
                        // Hapus nama hari sebelum parsing
                        String stockDateStr = stock
                            .stockAdditionDate; // Misalkan formatnya "yyyy-MM-dd"
                        final DateTime stockDate =
                            dateFormat.parse(stockDateStr);

                        // Pastikan stockDate berada dalam rentang tanggal yang benar
                        bool isWithinRange = (stockDate.isAfter(startDate) ||
                                stockDate.isAtSameMomentAs(startDate)) &&
                            (stockDate.isBefore(endDate) ||
                                stockDate.isAtSameMomentAs(endDate));

                        return isWithinRange;
                      } catch (e) {
                        debugPrint(
                            "Error parsing date: ${stock.stockAdditionDate} - $e");
                        return false; // Jika terjadi error, abaikan data ini
                      }
                    }).toList();

                    // Tambahkan log untuk memeriksa hasil filter
                    debugPrint("Filtered stock count: ${filteredStock.length}");

                    return CustomRefreshWidget(
                      onRefresh: _loadStockAddition,
                      child: filteredStock.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.search_off_outlined,
                                      size: 50, color: Colors.black),
                                  Text("Tidak ada data dalam rentang tanggal"),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                              itemCount: filteredStock.length,
                              itemBuilder: (context, index) {
                                final stock = filteredStock[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: StockAdditionCard(stock: stock),
                                );
                              },
                            ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        if (securityProvider.tambahStokProduk != true)
          ExpensiveFloatingButton(
            right: 12,
            left: 12,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectAndAddStockProduct(),
                ),
              );

              if (result == true) {
                _loadStockAddition();
                showSuccessAlert(
                    context, "Berhasil Menambahkan Stok Spare Part!");
              }
            },
            child: Text(
              "TAMBAH",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: SizeHelper.Fsize_expensiveFloatingButton(context),
              ),
            ),
          ),
      ]),
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
