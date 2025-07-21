import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/payment_method_data.dart';
import 'package:omzetin_bengkel/providers/securityProvider.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/page/cashier/cashier_page.dart';
import 'package:omzetin_bengkel/view/page/report/report_StokProduct.dart';
import 'package:omzetin_bengkel/view/page/report/report_category.dart';
import 'package:omzetin_bengkel/view/page/report/report_expense.dart';
import 'package:omzetin_bengkel/view/page/report/report_kasir.dart';
import 'package:omzetin_bengkel/view/page/report/report_mekanik.dart';
import 'package:omzetin_bengkel/view/page/report/report_payment_method.dart';
import 'package:omzetin_bengkel/view/page/report/report_pelanggan.dart';
import 'package:omzetin_bengkel/view/page/report/report_product.dart';
import 'package:omzetin_bengkel/view/page/report/report_profit.dart';
import 'package:omzetin_bengkel/view/page/report/report_services.dart';
import 'package:omzetin_bengkel/view/page/report/report_transaction.dart';
import 'package:omzetin_bengkel/view/widget/app_bar_stock.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/menu_card.dart';
import 'package:omzetin_bengkel/view/widget/modals.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    var securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
        backgroundColor: bgColor,
        // appBar: AppBar(
        //   leading: const CustomBackButton(),
        //   backgroundColor: gradientSec,
        //   elevation: 0,
        //   centerTitle: true,
        //   title: Text(
        //     'LAPORAN',
        //     style: GoogleFonts.poppins(
        //       fontWeight: FontWeight.bold,
        //       fontSize: SizeHelper.Fsize_normalTitle(context),
        //       color: primaryColor,
        //     ),
        //   ),
        // ),
        body: Stack(
          children: [
            Column(
              children: [
                AppBarStock(
                  appBarText: "LAPORAN",
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            "Laporan Transaksi",
                            [
                              _buildMainCard(
                                title: "Transaksi",
                                imagePath:
                                    'assets/images/laporan-transaksi.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReportTransaction(),
                                    ),
                                  );
                                },
                              ),
                              // const Gap(20),
                              _buildMainCard(
                                title: "Spare Part Terjual",
                                imagePath: 'assets/images/laporan-terjual.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReportProduct(),
                                    ),
                                  );
                                },
                              ),
                              _buildMainCard(
                                title: "Stok Spare Part",
                                imagePath: 'assets/images/laporan-stok.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReportStokproduct(),
                                    ),
                                  );
                                },
                              ),
                              _buildMainCard(
                                title: "Service Terjual",
                                imagePath: 'assets/images/laporan-terjual.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReportService(),
                                    ),
                                  );
                                },
                              ),
                              // _buildMainCard(
                              //   title: "Kategori",
                              //   imagePath: 'assets/images/laporan-kategori.png',
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (_) => const ReportCategory(),
                              //       ),
                              //     );
                              //   },
                              // ),

                              // _buildMainCard(
                              //   title: "Export Data Excel",
                              //   imagePath: 'assets/images/report_export.png',
                              //   onTap: () {
                              //     CustomModals.modalexportexeldropdown(context);
                              //   },
                              // ),
                              _buildMainCard(
                                title: "Kasir",
                                imagePath: 'assets/images/laporan-kasir.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReportKasir(),
                                    ),
                                  );
                                },
                              ),
                              _buildMainCard(
                                title: "Pelanggan",
                                imagePath: 'assets/images/laporan-kasir.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReportPelanggan(),
                                    ),
                                  );
                                },
                              ),
                              _buildMainCard(
                                title: "Mekanik",
                                imagePath: 'assets/images/laporan-kategori.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReportMekanik(),
                                    ),
                                  );
                                },
                              ),
                              _buildMainCard(
                                title: "Pengeluaran",
                                imagePath: 'assets/images/pengeluaran.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReportExpense(),
                                    ),
                                  );
                                },
                              ),
                              _buildMainCard(
                                title: "Metode Pembayaran",
                                imagePath: 'assets/images/laporan-bayar.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ReportPaymentMethod(),
                                    ),
                                  );
                                },
                              ),
                              _buildMainCard(
                                title: "Report Profit",
                                imagePath: 'assets/images/profit.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReportProfit(),
                                    ),
                                  );
                                },
                              ),
                              _buildMainCard(
                                title: "Export Data Excel",
                                imagePath: 'assets/images/excel.png',
                                onTap: () {
                                  CustomModals.modalexportexeldropdown(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildSection(
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: 0.h,
        bottom: 4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: GridView.count(
        physics:
            NeverScrollableScrollPhysics(), // Supaya tidak scroll di dalam scroll
        shrinkWrap: true,
        crossAxisCount: 3, // ✅ 3 kolom
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.9, // Atur sesuai tinggi/lebar card
        children: children,
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return MainCard(
      onTap: onTap,
      title: title,
      color: Colors.black,
      imagePath: imagePath,
    );
  }
}
