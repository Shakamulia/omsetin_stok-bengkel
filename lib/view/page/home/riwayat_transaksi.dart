import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/transaction.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/view/page/detail_history_transaction.dart';
import 'package:omsetin_bengkel/view/widget/Notfound.dart';
import 'package:omsetin_bengkel/view/widget/card_report_transaction.dart';
import 'package:omsetin_bengkel/view/widget/date_from_to/fromTo_v2.dart';
import 'package:omsetin_bengkel/view/widget/refresWidget.dart';
import 'package:omsetin_bengkel/view/widget/search.dart';
import 'package:sizer/sizer.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class RiwayatTransaksi extends StatefulWidget {
  const RiwayatTransaksi({super.key});

  @override
  State<RiwayatTransaksi> createState() => _RiwayatTransaksiState();
}

class _RiwayatTransaksiState extends State<RiwayatTransaksi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime dateFrom = DateTime.now().subtract(const Duration(days: 7));
  DateTime dateTo = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String keyword = '';

  Map<String, Future<List<TransactionData>>> transactionFutures = {};

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<TransactionData>> _getTransactionsData() async {
    try {
      return await _databaseService.getTransaction();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<List<TransactionData>> _getTransactionsDataByStatus(
      String status) async {
    try {
      return await _databaseService.getTransactionsByStatus(status);
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  void _refreshTab(String status) {
    setState(() {
      transactionFutures[status] = _getTransactionsDataByStatus(status);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        keyword = _searchController.text.toLowerCase();
      });
    });
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    for (var status in [
      'Selesai',
      'Belum Lunas',
      'Belum Dibayar',
      'Dibatalkan'
    ]) {
      transactionFutures[status] = _getTransactionsDataByStatus(status);
    }

    Future.delayed(Duration.zero, () {
      for (var s in [
        'Selesai',
        'Belum Lunas',
        'Belum Dibayar',
        'Dibatalkan',
      ]) {
        _refreshTab(s);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight + 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            secondaryColor,
                            primaryColor,
                          ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: AppBar(
                        title: Text(
                          "RIWAYAT TRANSAKSI",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: SizeHelper.Fsize_normalTitle(context),
                            color: bgColor,
                          ),
                        ),
                        centerTitle: true,
                        toolbarHeight: kToolbarHeight + 20,
                        backgroundColor: Colors.transparent,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        elevation: 0,
                      ),
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

          const Gap(8),
          Theme(
            data: Theme.of(context).copyWith(
              tabBarTheme: const TabBarThemeData(
                dividerColor: Colors.transparent,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicator: BoxDecoration(
                      color: _tabController.index == 0
                          ? greenColor
                          : _tabController.index == 1
                              ? yellowColor
                              : _tabController.index == 2
                                  ? redColor
                                  : greyColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: "Selesai"),
                      Tab(text: "Belum Lunas"),
                      Tab(text: "Belum Dibayar"),
                      Tab(text: "Dibatalkan"),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchTextField(
              prefixIcon: const Icon(Icons.search, size: 20),
              obscureText: false,
              hintText: "Cari Transaksi",
              controller: _searchController,
              maxLines: 1,
              suffixIcon: null,
              color: cardColor,
            ),
          ),
          const Gap(4),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionPage('Selesai'),
                _buildTransactionPage('Belum Lunas'),
                _buildTransactionPage('Belum Dibayar'),
                _buildTransactionPage('Dibatalkan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionPage(String status) {
    return FutureBuilder<List<TransactionData>>(
      future: transactionFutures[status],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: CustomRefreshWidget(
                  onRefresh: () async {
                    _refreshTab(status);
                  },
                  child: NotFoundPage()));
        } else {
          final transactions = snapshot.data!.where((transaction) {
            try {
              String dateStr = transaction.transactionDate.split(', ')[1];
              DateTime transactionDate =
                  DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();
              DateTime startDate =
                  DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
              DateTime endDate =
                  DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59);

              final matchDate = (transactionDate.isAfter(startDate) ||
                      transactionDate.isAtSameMomentAs(startDate)) &&
                  (transactionDate.isBefore(endDate) ||
                      transactionDate.isAtSameMomentAs(endDate));

              final matchSearch = keyword.isEmpty ||
                  transaction.transactionCustomerName
                      .toLowerCase()
                      .contains(keyword) ||
                  transaction.transactionId
                      .toString()
                      .toLowerCase()
                      .contains(keyword);

              return matchDate && matchSearch;
            } catch (e) {
              print(
                  "Error parsing date: ${transaction.transactionDate}, Error: $e");
              return false;
            }
          }).toList();

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const Gap(8),
                  Text(
                    'Tidak ada transaksi',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Transaksi dengan status "$status" tidak ditemukan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomRefreshWidget(
            onRefresh: () async {
              _refreshTab(status);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ZoomTapAnimation(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailHistoryTransaction(
                          transactionDetail: transaction,
                        ),
                      ),
                    );

                    for (var s in [
                      'Selesai',
                      'Belum Lunas',
                      'Belum Dibayar',
                      'Dibatalkan',
                    ]) {
                      _refreshTab(s);
                    }
                  },
                  child: CardReportTransactions(transaction: transaction),
                );
              },
            ),
          );
        }
      },
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
