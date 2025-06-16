import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:omsetin_stok/model/cashier.dart';
import 'package:omsetin_stok/providers/cashierProvider.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/view/page/cashier/add_cashier_page.dart';
import 'package:omsetin_stok/view/widget/Notfound.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/card_cashier.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_stok/view/widget/search.dart';
import 'package:provider/provider.dart';

/// Halaman Manajemen Kasir
/// Menampilkan daftar kasir dan memungkinkan penambahan kasir baru
class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  TextEditingController _searchController = TextEditingController();
  String _sortOrder = 'asc';

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20), // Tambah tinggi AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
          ),
          
          child: Container(
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
                    title: Text(
            'KELOLA KASIR',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: SizeHelper.Fsize_normalTitle(context), // Perbesar font
              color: bgColor,
            ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    leading: CustomBackButton(),
                    elevation: 0,
                    toolbarHeight: kToolbarHeight + 20, // Tambah tinggi toolbar
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    _buildSearchAndSortSection(),
                    Expanded(
                      child: Stack(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildCashierGridView(),
                          ),
                          ExpensiveFloatingButton(
                            onPressed: () {
                              _navigateToAddCashierPage();
                            },
                            text: "TAMBAH KASIR",
                          ),
                        ],
                      ),
                    )
                    // Tombol Tambah Kasir
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk section pencarian dan sorting
  Widget _buildSearchAndSortSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: SearchTextField(
                prefixIcon: const Icon(Icons.search, size: 24),
                obscureText: false,
                hintText: "Cari Kasir",
                controller: _searchController,
                maxLines: 1,
                suffixIcon: null,
                color: cardColor,
              ),
            ),
            const Gap(10),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.sort_by_alpha),
                              title: const Text("A-Z"),
                              onTap: () {
                                setState(() {
                                  _sortOrder = 'asc';
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.sort),
                              title: const Text("Z-A"),
                              onTap: () {
                                setState(() {
                                  _sortOrder = 'desc';
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.sort_by_alpha),
                              title: const Text("Terbaru"),
                              onTap: () {
                                setState(() {
                                  _sortOrder = 'newest';
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.sort_by_alpha),
                              title: const Text("Terlama"),
                              onTap: () {
                                setState(() {
                                  _sortOrder = 'oldest';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: const Column(
                    children: [
                      Iconify(Uil.sort, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCashierGridView() {
    return Consumer<CashierProvider>(
      builder: (context, cashierProvider, child) {
        return FutureBuilder<List<CashierData>>(
          future: cashierProvider.getCashiers(
              query: _searchController.text, sortOrder: _sortOrder),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: NotFoundPage(
                title: _searchController.text == ""
                    ? "Tidak ada Kasir yang ditemukan"
                    : 'Tidak ada Kasir dengan nama "${_searchController.text}"',
              ));
            } else {
              final cashiers = snapshot.data!;
              return GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: cashiers.length,
                itemBuilder: (context, index) {
                  final result = cashiers[index];
                  return CardCashier(
                    cashier: result,
                    onDeleted: () {
                      setState(() {});
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  /// Metode untuk navigasi dengan animasi slide
  void _navigateToAddCashierPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddCashierPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween<Offset>(begin: begin, end: end)
              .chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300), // Durasi transisi
      ),
    );
  }
}
