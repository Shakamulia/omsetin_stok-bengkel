import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:omzetin_bengkel/model/pelanggan.dart';
import 'package:omzetin_bengkel/providers/pelangganProvider.dart';
import 'package:omzetin_bengkel/providers/securityProvider.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/page/pelanggan/add_pelanggan.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/card_pelanggan.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/search.dart';
import 'package:provider/provider.dart';

/// Halaman Manajemen pelanggan
/// Menampilkan daftar pelanggan dan memungkinkan penambahan pelanggan baru
class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
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
    var securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor,
                  primaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              title: Text(
                'KELOLA PELANGGAN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              leading: CustomBackButton(),
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
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
                            child: _buildPelangganGridView(),
                          ),
                          securityProvider.kunciAddPelanggan
                              ? 
                               ExpensiveFloatingButton(
                                  onPressed: () {
                                    _navigateToAddPelangganPage();
                                  },
                                  text: "TAMBAH pelanggan",
                                )
                              : SizedBox.shrink()
                        ],
                      ),
                    )
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
                hintText: "Cari pelanggan",
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

  Widget _buildPelangganGridView() {
    return Consumer<Pelangganprovider>(
      builder: (context, pelangganProvider, child) {
        return FutureBuilder<List<Pelanggan>>(
          future: pelangganProvider.getPelangganList(
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
                    ? "Tidak ada pelanggan yang ditemukan"
                    : 'Tidak ada pelanggan dengan nama "${_searchController.text}"',
              ));
            } else {
              final pelangganList = snapshot.data!;
              return GridView.builder(
                padding: EdgeInsets.only(
                  top: 8,
                  left: 8,
                  right: 8,
                  bottom: 80,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: pelangganList.length,
                itemBuilder: (context, index) {
                  final pelanggan = pelangganList[index];
                  return CardPelanggan(
                    pelanggan: pelanggan,
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
  void _navigateToAddPelangganPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddPelangganPage(),
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
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }
}
