import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:omzetin_bengkel/view/page/home/history_page.dart';
import 'package:omzetin_bengkel/view/page/mekanik/mekanik_page.dart';
import 'package:omzetin_bengkel/view/page/percent_profit.dart';
import 'package:omzetin_bengkel/view/page/service/service_page.dart';
import 'package:omzetin_bengkel/view/page/settings/profilToko.dart';
import 'package:omzetin_bengkel/view/page/settings/scanDevicePrinter.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/cashier.dart';
import 'package:omzetin_bengkel/model/transaction.dart';
import 'package:omzetin_bengkel/providers/cashierProvider.dart';
import 'package:omzetin_bengkel/providers/securityProvider.dart';
import 'package:omzetin_bengkel/providers/settingProvider.dart';
import 'package:omzetin_bengkel/providers/userProvider.dart';
import 'package:omzetin_bengkel/services/authService.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/pinModalWithAnimation.dart';
import 'package:omzetin_bengkel/utils/toast.dart';
import 'package:omzetin_bengkel/view/page/History_transaksi.dart';
import 'package:omzetin_bengkel/view/page/aboutapplication/applicationAbout.dart';
import 'package:omzetin_bengkel/view/page/addStockProduct/add_stock_product.dart';
import 'package:omzetin_bengkel/view/page/full_icon_page.dart';
import 'package:omzetin_bengkel/view/page/cashier/cashier_page.dart';
import 'package:omzetin_bengkel/view/page/cashier/update_cashier_from_home_page.dart';
import 'package:omzetin_bengkel/view/page/change_password/changePassword.dart';
import 'package:omzetin_bengkel/view/page/expense/expense_page.dart';
import 'package:omzetin_bengkel/view/page/home/product_terbaru_list.dart';
import 'package:omzetin_bengkel/view/page/home/riwayat_transaksi.dart'
    hide RiwayatTransaksi;
import 'package:omzetin_bengkel/view/page/income/income_page.dart';
import 'package:omzetin_bengkel/view/page/dummy/dummy.dart';
import 'package:omzetin_bengkel/view/page/login_cashier/login_cashier.dart';
import 'package:omzetin_bengkel/view/page/print_resi/input_resi.dart';
import 'package:omzetin_bengkel/view/page/product/product.dart';
import 'package:omzetin_bengkel/view/page/report/report_page.dart';
import 'package:omzetin_bengkel/view/page/settings/securityPage.dart';
import 'package:omzetin_bengkel/view/page/settings/setting.dart';
import 'package:omzetin_bengkel/view/page/transaction/transactions_page.dart';
import 'package:omzetin_bengkel/view/page/usersProfile/usersProfile.dart';
import 'package:omzetin_bengkel/view/widget/menu_card.dart';
import 'package:omzetin_bengkel/view/widget/modals.dart';
import 'package:omzetin_bengkel/view/widget/pinModal.dart';
import 'package:omzetin_bengkel/view/widget/refresWidget.dart';
import 'package:omzetin_bengkel/view/widget/sidebar_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:omzetin_bengkel/view/page/pelanggan/pelanggan_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseService db = DatabaseService.instance;
  List<TransactionData> transactionData = [];
  @override
  void initState() {
    super.initState();

    getTransaction();

    Provider.of<CashierProvider>(context, listen: false)
        .loadCashierDataFromSharedPreferences();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTokenCheck(context);

      Provider.of<UserProvider>(context, listen: false)
          .getSerialNumberAsUser(context);
    });
    Future.microtask(() {
      Provider.of<SettingProvider>(context, listen: false).getSettingProfile();
    });
  }

  void getTransaction() async {
    List<TransactionData> data = await db.getTransaction();
    setState(() {
      transactionData = data;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final AuthService _authService = AuthService();

  void _logout() async {
    try {
      final secure = FlutterSecureStorage();

      await secure.delete(key: 'remember_serial');
      await secure.delete(key: 'remember_pass');

      await _authService.logout(context);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await Provider.of<CashierProvider>(context, listen: false)
        .loadCashierDataFromSharedPreferences();
    setState(() {});
  }

  Future<int> _getTodayTotalOmzet() async {
    List<TransactionData> transactions = await databaseService.getTransaction();

    final today = DateTime.now();

    final todayTransactions = transactions.where((transaction) {
      try {
        String dateStr = transaction.transactionDate.split(', ')[1];
        DateTime transactionDate =
            DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();
        return transactionDate.year == today.year &&
            transactionDate.month == today.month &&
            transactionDate.day == today.day &&
            transaction.transactionStatus == "Selesai";
      } catch (e) {
        print("Error parsing date: ${transaction.transactionDate}, Error: $e");
        return false;
      }
    }).toList();

    // Calculate total omzet
    Future<int> totalOmzet = _calculateTotalOmzet(todayTransactions);
    return totalOmzet;
  }

  Future<Map<String, dynamic>> _getWeeklyOmzetSpots() async {
    List<TransactionData> transactions = await databaseService.getTransaction();
    final now = DateTime.now();
    final start = now.subtract(Duration(days: 6));

    Map<String, int> omzetPerDay = {};
    for (int i = 0; i < 7; i++) {
      DateTime day = start.add(Duration(days: i));
      String key = DateFormat('yyyy-MM-dd').format(day);
      omzetPerDay[key] = 0;
    }

    for (var transaction in transactions) {
      try {
        String dateStr = transaction.transactionDate.split(', ')[1];
        DateTime transactionDate =
            DateFormat("dd/MM/yyyy HH:mm").parse(dateStr).toLocal();

        String key = DateFormat('yyyy-MM-dd').format(transactionDate);

        if (omzetPerDay.containsKey(key) &&
            transaction.transactionStatus == "Selesai") {
          final total = await transaction.transactionTotal;
          omzetPerDay[key] = omzetPerDay[key]! + total;
        }
      } catch (e) {
        print("Date parsing error: ${transaction.transactionDate}, $e");
      }
    }

    List<FlSpot> spots = [];
    List<String> labels = [];
    int index = 0;
    omzetPerDay.forEach((key, total) {
      spots.add(FlSpot(index.toDouble(), total.toDouble()));
      labels.add(key);
      index++;
    });

    return {
      'spots': spots,
      'labels': labels,
    };
  }

  final List<Map<String, dynamic>> data = [
    {
      'icon': Icons.people_rounded,
      'title': 'Ganti Kasir',
      'color': bgColor,
      'destination': LoginCashier()
    },
  ];

  Future<int> _calculateTotalOmzet(List<TransactionData> transactions) async {
    return await transactions.fold<Future<int>>(Future.value(0),
        (futureSum, transaction) async {
      final sum = await futureSum;
      final transactionTotal = await transaction.transactionTotal;
      return sum + transactionTotal;
    });
  }

  @override
  void startTokenCheck(BuildContext context) {
    final authService = AuthService();
    Timer.periodic(Duration(seconds: 1), (timer) async {
      final token = await authService.getToken();
      final isExpired = token == null
          ? true
          : await authService.isTokenExpired(context, token);
      if (isExpired) {
        timer.cancel();
        await authService.logout(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var cashierProvider = Provider.of<CashierProvider>(context);
    var securityProvider = Provider.of<SecurityProvider>(context);
    var settingProvider = Provider.of<SettingProvider>(context);
    var userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: bgColor,
        drawer: Drawer(
          child: Container(
            decoration: const BoxDecoration(color: primaryColor),
            child: SafeArea(
              child: CustomRefreshWidget(
                onRefresh: _handleRefresh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Drawer
                    GestureDetector(
                      onTap: () {
                        if (UserProvider().serialNumberData != null) {
                          connectionToast(context, "Koneksi Gagal!",
                              "Anda tidak terhubung ke jaringan. Login Ulang",
                              isConnected: false);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen()),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        child: Row(
                          children: [
                            userProvider.serialNumberData != null &&
                                    userProvider.serialNumberData!.profileImage
                                        .isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: userProvider.getProfileImageUrl(
                                        userProvider
                                            .serialNumberData!.profileImage),
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      radius: 20,
                                      backgroundImage: imageProvider,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.person,
                                      color: bgColor,
                                    ),
                                  ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (userProvider.serialNumberData?.name ==
                                              null ||
                                          userProvider.serialNumberData?.name
                                                  .isEmpty ==
                                              true)
                                      ? '-'
                                      : userProvider.serialNumberData!.name,
                                  style: GoogleFonts.poppins(
                                    color: bgColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  (userProvider.serialNumberData?.email ==
                                              null ||
                                          userProvider.serialNumberData?.email
                                                  .isEmpty ==
                                              true)
                                      ? '-'
                                      : userProvider.serialNumberData!.email,
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon:
                                  const Icon(Icons.arrow_forward_ios, size: 18),
                              color: bgColor,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final item = data[index];
                                if (item['title'] == "Ganti Kasir") {
                                  return Column(
                                    children: [
                                      SidebarListTile(
                                        icon: item['icon'],
                                        title: item['title'],
                                        iconColor: item['color'],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    item['destination']),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                }
                                return SidebarListTile(
                                  icon: item['icon'],
                                  title: item['title'],
                                  iconColor: item['color'],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              item['destination']),
                                    );
                                  },
                                );
                              },
                            ),

                            const Divider(
                                color: bgColor,
                                thickness: 1,
                                indent: 16,
                                endIndent: 16),
                            // Akun Section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Akun",
                                  style: GoogleFonts.poppins(
                                    color: bgColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            SidebarListTile(
                              icon: Icons.settings_outlined,
                              title: 'Pengaturan',
                              iconColor: bgColor,
                              onTap: () {
                                if (securityProvider.kunciPengaturanToko) {
                                  showPinModalWithAnimation(
                                    context,
                                    pinModal: PinModal(
                                      destination: SettingPage(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SettingPage()),
                                  );
                                }
                              },
                            ),

                            if (cashierProvider.cashierData?['cashierName'] ==
                                "Owner")
                              SidebarListTile(
                                icon: Icons.shield_outlined,
                                title: 'Keamanan',
                                iconColor: bgColor,
                                onTap: () {
                                  showPinModalWithAnimation(
                                    context,
                                    pinModal: PinModal(
                                      destination: SecuritySettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            if (cashierProvider.cashierData?['cashierName'] ==
                                "Owner")
                              SidebarListTile(
                                icon: Icons.password_outlined,
                                title: 'Ganti Password',
                                iconColor: bgColor,
                                onTap: () {
                                  if (securityProvider.kunciGantiPassword) {
                                    showPinModalWithAnimation(
                                      context,
                                      pinModal: PinModal(
                                        destination: ChangepasswordPage(),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChangepasswordPage()),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 20),
                      child: Column(
                        children: [
                          ListTile(
                            leading:
                                const Icon(Icons.info_outline, color: bgColor),
                            title: Text(
                              'About',
                              style: GoogleFonts.poppins(
                                color: bgColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdatePage()));
                            },
                          ),
                          if (!securityProvider.sembunyikanLogout)
                            ListTile(
                              leading: const Icon(Icons.logout_outlined,
                                  color: bgColor),
                              title: Text(
                                'Logout',
                                style: GoogleFonts.poppins(
                                  color: bgColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: _logout,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              CustomRefreshWidget(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            color: bgColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      IconButton(
                                        onPressed: () {
                                          _scaffoldKey.currentState
                                              ?.openDrawer();
                                        },
                                        icon: const Icon(Icons.menu,
                                            color: primaryColor, size: 32),
                                      ),
                                    ]),
                                    GestureDetector(
                                      onTap: () async {
                                        CashierData? cashier =
                                            await cashierProvider
                                                .getCashierById(int.parse(
                                                    cashierProvider
                                                            .cashierData?[
                                                        'cashierId']));

                                        // if (cashier != null) {
                                        //   Navigator.push(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //           builder: (_) =>
                                        //               UpdateCashierFromHome(
                                        //                   cashier: cashier)));
                                        // } else {
                                        //   print('Cashier data is null');
                                        // }
                                      },
                                      child: Row(
                                        children: [
                                          Text(cashierProvider.cashierData?[
                                                  'cashierName'] ??
                                              ''),
                                          Gap(10),
                                          ClipOval(
                                            child: Image.asset(
                                              "assets/newProfiles/owner.png",
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(10),
                                GestureDetector(onTap: () {
                                  if (securityProvider.kunciPengaturanToko) {
                                    showPinModalWithAnimation(context,
                                        pinModal: PinModal(
                                          destination: ProfilTokoPage(),
                                        ));
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ProfilTokoPage()));
                                  }
                                }, child: Consumer<SettingProvider>(
                                    builder: (context, settingProvider, child) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: settingProvider
                                                            .settingImage !=
                                                        null &&
                                                    settingProvider
                                                        .settingImage!
                                                        .isNotEmpty &&
                                                    File(settingProvider
                                                            .settingImage!)
                                                        .existsSync()
                                                ? Hero(
                                                    tag: "settingImage",
                                                    child: Image.file(
                                                      File(settingProvider
                                                          .settingImage!),
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                          "assets/products/no-image.png",
                                                          width: 50,
                                                          height: 50,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Hero(
                                                    tag: "settingNoImage",
                                                    child: Image.asset(
                                                      "assets/products/no-image.png",
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const Gap(15),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (settingProvider.getSettingName
                                                          ?.isEmpty ??
                                                      true)
                                                  ? 'Nama Bengkel'
                                                  : (settingProvider
                                                              .getSettingName!
                                                              .replaceAll(
                                                                  '\n', ' ')
                                                              .length >
                                                          15
                                                      ? '${settingProvider.getSettingName!.replaceAll('\n', ' ').substring(0, 20)}...'
                                                      : settingProvider
                                                          .getSettingName!
                                                          .replaceAll(
                                                              '\n', ' ')),
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            const Gap(5),
                                            // Text(
                                            //   (settingProvider.getSettingAddress
                                            //               ?.isEmpty ??
                                            //           true)
                                            //       ? 'Alamat Toko'
                                            //       : (settingProvider
                                            //                   .getSettingAddress!
                                            //                   .replaceAll(
                                            //                       '\n', ' ')
                                            //                   .length >
                                            //               30
                                            //           ? '${settingProvider.getSettingAddress!.replaceAll('\n', ' ').substring(0, 30)}...'
                                            //           : settingProvider
                                            //               .getSettingAddress!
                                            //               .replaceAll(
                                            //                   '\n', ' ')),
                                            //   style: GoogleFonts.poppins(
                                            //       fontSize: 16),
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                })),
                                Gap(20),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primaryColor,
                                              secondaryColor
                                            ],
                                            begin: Alignment(0, 2),
                                            end: Alignment(-0, -2),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Total Penjualan Hari Ini",
                                              style: GoogleFonts.poppins(
                                                  color: bgColor, fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            FutureBuilder<int>(
                                              future: _getTodayTotalOmzet(),
                                              builder: (context, snapshot) {
                                                final total =
                                                    snapshot.data ?? 0;
                                                return Text(
                                                  NumberFormat.currency(
                                                    locale: 'id_ID',
                                                    symbol: 'Rp. ',
                                                    decimalDigits: 0,
                                                  ).format(total),
                                                  style: GoogleFonts.poppins(
                                                    color: bgColor,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              height: 100,
                                              width: double.infinity,
                                              child: AspectRatio(
                                                aspectRatio: 2.0,
                                                child: FutureBuilder<
                                                    Map<String, dynamic>>(
                                                  future:
                                                      _getWeeklyOmzetSpots(),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    }

                                                    final spots =
                                                        snapshot.data!['spots']
                                                            as List<FlSpot>;
                                                    final labels =
                                                        snapshot.data!['labels']
                                                            as List<String>;

                                                    return LineChart(
                                                      LineChartData(
                                                        lineBarsData: [
                                                          LineChartBarData(
                                                            show: true,
                                                            spots: spots,
                                                            gradient:
                                                                const LinearGradient(
                                                              colors: [
                                                                secondaryColor,
                                                                Colors.white
                                                              ],
                                                              begin: Alignment
                                                                  .bottomCenter,
                                                              end: Alignment
                                                                  .topCenter,
                                                            ),
                                                            barWidth: 4,
                                                            isCurved: true,
                                                            isStrokeCapRound:
                                                                true,
                                                            belowBarData:
                                                                BarAreaData(
                                                                    show: true),
                                                            preventCurveOverShooting:
                                                                true,
                                                          )
                                                        ],
                                                        borderData:
                                                            FlBorderData(
                                                                show: false),
                                                        gridData: FlGridData(
                                                            show: false),
                                                        titlesData:
                                                            FlTitlesData(
                                                          leftTitles: AxisTitles(
                                                              sideTitles:
                                                                  SideTitles(
                                                                      showTitles:
                                                                          false)),
                                                          topTitles: AxisTitles(
                                                              sideTitles:
                                                                  SideTitles(
                                                                      showTitles:
                                                                          false)),
                                                          rightTitles: AxisTitles(
                                                              sideTitles:
                                                                  SideTitles(
                                                                      showTitles:
                                                                          false)),
                                                          bottomTitles:
                                                              AxisTitles(
                                                            sideTitles:
                                                                SideTitles(
                                                              showTitles: true,
                                                              interval: 1,
                                                              getTitlesWidget:
                                                                  (value,
                                                                      meta) {
                                                                int index = value
                                                                    .toInt();
                                                                if (index < 0 ||
                                                                    index >=
                                                                        labels
                                                                            .length) {
                                                                  return const SizedBox
                                                                      .shrink();
                                                                }

                                                                DateTime
                                                                    parsedDate =
                                                                    DateTime.parse(
                                                                        labels[
                                                                            index]);
                                                                String
                                                                    formatted =
                                                                    DateFormat(
                                                                            'dd/MM')
                                                                        .format(
                                                                            parsedDate);
                                                                return Text(
                                                                  formatted,
                                                                  style: GoogleFonts.poppins(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Gap(20),
                                Gap(10),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Gap(10),

                            // GRIDVIEW 3x3 UNTUK MENU UTAMA
                            GridView.count(
                              crossAxisCount: 3, // 3 kolom
                              crossAxisSpacing:
                                  10, // Jarak horizontal antar item
                              mainAxisSpacing: 10, // Jarak vertikal antar item
                              shrinkWrap:
                                  true, // Agar tidak mengambil ruang berlebih
                              physics:
                                  NeverScrollableScrollPhysics(), // Tidak bisa discroll
                              children: [
                                // Baris 1
                                MainCard(
                                  onTap: () {
                                    if (securityProvider.kunciProduk) {
                                      showPinModalWithAnimation(context,
                                          pinModal: PinModal(
                                              destination: ProductPage()));
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ProductPage()));
                                    }
                                  },
                                  title: "Spare Part &\n Layanan",
                                  color: Colors.black,
                                  imagePath: 'assets/images/produk.png',
                                ),
                                MainCard(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const AddStockProductPage()));
                                  },
                                  title: "Tambah\nStok Spare Part",
                                  color: Colors.black,
                                  imagePath: 'assets/images/add-produk.png',
                                ),

                                MainCard(
                                  onTap: () {
                                    if (securityProvider
                                        .kunciRiwayatTransaksi) {
                                      showPinModalWithAnimation(context,
                                          pinModal: PinModal(
                                              destination: RiwayatTransaksi()));
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  RiwayatTransaksi()));
                                    }
                                  },
                                  title: "Riwayat\nTransaksi",
                                  color: Colors.black,
                                  imagePath: 'assets/images/riwayat.png',
                                ),

                                // Baris 2
                                MainCard(
                                  onTap: () {
                                    if (securityProvider.kunciPelanggan) {
                                      showPinModalWithAnimation(context,
                                          pinModal: PinModal(
                                              destination: PelangganPage()));
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => PelangganPage()));
                                    }
                                  },
                                  title: "Pelanggan\n",
                                  color: Colors.black,
                                  imagePath: 'assets/images/expense.png',
                                ),

                                MainCard(
                                  onTap: () {
                                    if (securityProvider.kunciPegawai) {
                                      showPinModalWithAnimation(context,
                                          pinModal: PinModal(
                                              destination: mekanikPage()));
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => mekanikPage()));
                                    }
                                  },
                                  title: "Mekanik\n",
                                  color: Colors.black,
                                  imagePath: 'assets/images/income.png',
                                ),

                                MainCard(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => CashierPage()));
                                    },
                                    title: "Kasir\n",
                                    color: Colors.black,
                                    imagePath: 'assets/images/kasir.png'),

                                // Baris 3
                                MainCard(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const ExpensePage()));
                                  },
                                  title: "Pengeluaran\n",
                                  color: Colors.black,
                                  imagePath: 'assets/images/expense.png',
                                ),

                                MainCard(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const IncomePage()));
                                  },
                                  title: "Pemasukan\n",
                                  color: Colors.black,
                                  imagePath: 'assets/images/income.png',
                                ),

                                MainCard(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ProfitPercent()));
                                  },
                                  title: "Setting Profit\n",
                                  color: Colors.black,
                                  imagePath: 'assets/images/setprofit.png',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: bgColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BottomItem(
                            icon: Icons.bar_chart_rounded,
                            label: 'Laporan',
                            onTap: () {
                              if (securityProvider.kunciLaporan) {
                                showPinModalWithAnimation(context,
                                    pinModal: PinModal(
                                      destination: ReportPage(),
                                    ));
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ReportPage(),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 20),
                          _BottomItem(
                            icon: Icons.person_rounded,
                            label: 'Kasir',
                            onTap: () async {
                              CashierData? cashier = await cashierProvider
                                  .getCashierById(int.parse(cashierProvider
                                      .cashierData?['cashierId']));

                              if (cashier != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => UpdateCashierFromHome(
                                            cashier: cashier)));
                              } else {
                                print('Cashier data is null');
                              }
                            },
                          ),
                        ],
                      ),
                      Positioned(
                        top: -20,
                        left: MediaQuery.of(context).size.width / 2 - 35 - 40,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TransactionPage(
                                          selectedItems: [],
                                        )));
                          },
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: const BoxDecoration(
                              // color: primaryColor,
                              gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                  begin: Alignment(0, 5),
                                  end: Alignment(-0, -2)),
                              shape: BoxShape.circle,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.receipt_long_rounded,
                                  color: bgColor,
                                  size: 35,
                                ),
                                // Text(
                                //   "Transaksi",
                                //   style: GoogleFonts.poppins(
                                //     fontSize: 10,
                                //     color: bgColor,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap(20),
          Icon(icon, color: primaryColor, size: 18),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 18, color: primaryColor),
          ),
        ],
      ),
    );
  }
}

// Riwayat Transaksi Container
class RiwayatTransaksiSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.all(18),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Riwayat Transaksi",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 17.sp),
                      ),
                      Text(
                        "Hari ini",
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 15.sp),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryPage(),
                          ));
                    },
                    child: Row(
                      children: [
                        Text(
                          "Lihat semua",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ],
      ),
    );
  }
}
