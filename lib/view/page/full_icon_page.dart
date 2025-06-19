import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_bengkel/providers/cashierProvider.dart';
import 'package:omsetin_bengkel/providers/securityProvider.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/pinModalWithAnimation.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/view/page/History_transaksi.dart';
import 'package:omsetin_bengkel/view/page/addStockProduct/add_stock_product.dart';
import 'package:omsetin_bengkel/view/page/cashier/cashier_page.dart';
import 'package:omsetin_bengkel/view/page/change_password/changePassword.dart';
import 'package:omsetin_bengkel/view/page/expense/expense_page.dart';
import 'package:omsetin_bengkel/view/page/income/income_page.dart';
import 'package:omsetin_bengkel/view/page/print_resi/input_resi.dart';
import 'package:omsetin_bengkel/view/page/product/product.dart';
import 'package:omsetin_bengkel/view/page/report/report_page.dart';
import 'package:omsetin_bengkel/view/page/settings/scanDevicePrinter.dart';
import 'package:omsetin_bengkel/view/page/settings/securityPage.dart';
import 'package:omsetin_bengkel/view/page/settings/setting.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/menu_card.dart';
import 'package:omsetin_bengkel/view/widget/pinModal.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AllIconPage extends StatefulWidget {
  const AllIconPage({super.key});

  @override
  State<AllIconPage> createState() => _AllIconPageState();
}

class _AllIconPageState extends State<AllIconPage> {
  @override
  Widget build(BuildContext context) {
    var securityProvider = Provider.of<SecurityProvider>(context);
    var cashierProvider = Provider.of<CashierProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              secondaryColor,
              primaryColor,
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: AppBar(
              title: Text(
                "SELENGKAPNYA",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              toolbarHeight: kToolbarHeight + 20,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(), // Custom back button
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(0.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection("Transaksi", [
                if (cashierProvider.cashierData?['cashierName'] == "Owner")
                  _buildMainCard("Kasir", 'assets/images/kasir.png', () {
                    if (securityProvider.kunciPengaturanToko) {
                      showPinModalWithAnimation(
                        context,
                        pinModal: PinModal(
                          destination: CashierPage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CashierPage()),
                      );
                    }
                  }),
                _buildMainCard("Cetak Resi", 'assets/images/print.png', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InputResi()));
                }),
                _buildMainCard("Pengeluaran", 'assets/images/expense.png', () {
                  if (securityProvider.kunciPengeluaran) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: ExpensePage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExpensePage()),
                    );
                  }
                }),
                _buildMainCard("Riwayat", 'assets/images/riwayat.png', () {
                  if (securityProvider.kunciRiwayatTransaksi) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: RiwayatTransaksi(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RiwayatTransaksi()),
                    );
                  }
                }),
                _buildMainCard("Laporan", 'assets/images/laporan.png', () {
                  if (securityProvider.kunciLaporan) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: ReportPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportPage()),
                    );
                  }
                }),
                _buildMainCard("Pemasukan", 'assets/images/income.png', () {
                  if (securityProvider.kunciPemasukan) {
                    showPinModalWithAnimation(
                      context,
                      pinModal: PinModal(
                        destination: IncomePage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IncomePage()),
                    );
                  }
                }),
              ]),
              Gap(2.h),
              _buildSection("Produk", [
                _buildMainCard("Produk", 'assets/images/produk.png', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductPage()),
                  );
                }),
                _buildMainCard("Tambah Stok", 'assets/images/add-produk.png',
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddStockProductPage()),
                  );
                }),
              ]),
              Gap(2.h),
              Consumer<CashierProvider>(
                builder: (context, cashierProvider, child) {
                  return _buildSection("Pengaturan", [
                    if (cashierProvider.cashierData?['cashierName'] == 'Owner')
                      _buildMainCard("Pengaturan", 'assets/images/setting.png',
                          () {
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
                      }),
                    _buildMainCard("Keamanan", 'assets/images/keamanan.png',
                        () {
                      if (securityProvider.kunciKeamanan) {
                        showPinModalWithAnimation(
                          context,
                          pinModal: PinModal(
                            destination: SecuritySettingsPage(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SecuritySettingsPage()),
                        );
                      }
                    }),
                    _buildMainCard(
                        "Ganti Password", 'assets/images/change-pass.png', () {
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
                              builder: (context) => ChangepasswordPage()),
                        );
                      }
                    }),
                    _buildMainCard(
                        "Koneksi Bluetooth", 'assets/images/Bluetooth.png', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ScanDevicePrinter()),
                      );
                    }),
                  ]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Gap(1.h),
          Wrap(
            spacing: 0.w,
            runSpacing: 2.h,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(String title, String imagePath, VoidCallback onTap) {
    return MainCard(
      onTap: onTap,
      title: title,
      color: Colors.black,
      imagePath: imagePath,
    );
  }
}
