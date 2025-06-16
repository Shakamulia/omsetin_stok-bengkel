// lib/view/page/pelanggan/pelanggan_page.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:omsetin_stok/model/pelanggan.dart';
import 'package:omsetin_stok/services/db_helper.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/successAlert.dart';
import 'package:omsetin_stok/view/page/pelanggan/add_pelanggan.dart';
import 'package:omsetin_stok/view/page/pelanggan/update_pelanggan.dart';
import 'package:omsetin_stok/view/widget/Notfound.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/confirm_delete_dialog.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_stok/view/widget/refresWidget.dart';
import 'package:omsetin_stok/view/widget/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late TextEditingController _searchController;
  bool? _isDeletePelangganOn;

  Future<List<Pelanggan>>? _futurePelanggans;
  List<Pelanggan> _filteredPelanggans = [];

  // Fetch pelanggans from database
  Future<List<Pelanggan>> fetchPelanggans() async {
    final pelangganData = await DatabaseHelper.instance.getAllPelanggan();
    print("Fetched pelanggans: $pelangganData");
    return pelangganData;
  }

  // Refresh data
  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _futurePelanggans = fetchPelanggans();
    });
  }

  // Filter search
  void _filterSearch() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _futurePelanggans = fetchPelanggans();
      } else {
        _futurePelanggans = fetchPelanggans().then((pelanggans) {
          return pelanggans.where((pelanggan) {
            return pelanggan.namaPelanggan
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
          }).toList();
        });
      }
    });
  }

  // Sort pelanggans
  Future<List<Pelanggan>> fetchPelanggansSorted(
      String column, String sortOrder) async {
    final pelangganData = await fetchPelanggans();
    pelangganData.sort((a, b) {
      var aValue = a.toMap()[column];
      var bValue = b.toMap()[column];

      if (aValue is String && bValue is String) {
        return sortOrder == 'asc'
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }
      return 0;
    });
    return pelangganData;
  }

  // Load security preferences
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDeletePelangganOn = prefs.getBool('hapusPelanggan') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _searchController = TextEditingController();
    _searchController.addListener(_filterSearch);
    _futurePelanggans = fetchPelanggans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [secondaryColor, primaryColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: AppBar(
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              leading: const CustomBackButton(),
              title: Text(
                'KELOLA PELANGGAN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: bgColor,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              pelangganToolBar(context),
              const Gap(10),
              Expanded(
                child: Stack(
                  children: [
                    FutureBuilder<List<Pelanggan>>(
                      future: _futurePelanggans,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return CustomRefreshWidget(
                            onRefresh: _pullRefresh,
                            child:
                                Center(child: Text("Error: ${snapshot.error}")),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return CustomRefreshWidget(
                            onRefresh: _pullRefresh,
                            child: Center(
                              child: NotFoundPage(
                                title: _searchController.text.isEmpty
                                    ? "Tidak ada Pelanggan"
                                    : 'Tidak ada Pelanggan dengan nama "${_searchController.text}"',
                              ),
                            ),
                          );
                        }

                        _filteredPelanggans = snapshot.data!;
                        return CustomRefreshWidget(
                          onRefresh: _pullRefresh,
                          child: ListView.builder(
                            itemCount: _filteredPelanggans.length,
                            itemBuilder: (context, index) {
                              final pelanggan = _filteredPelanggans[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: 5.0, bottom: 5.0),
                                child: ZoomTapAnimation(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UpdatePelangganPage(
                                            pelanggan: pelanggan),
                                      ),
                                    );

                                    if (result == true) {
                                      setState(() {
                                        _futurePelanggans = fetchPelanggans();
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: cardColor,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 12.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 53,
                                                height: 53,
                                                decoration: BoxDecoration(
                                                  color: primaryColor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Gap(10),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pelanggan.namaPelanggan,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Kode: ${pelanggan.kode}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "No. HP: ${pelanggan.noHandphone}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Email: ${pelanggan.email}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_isDeletePelangganOn != true)
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return ConfirmDeleteDialog(
                                                      message:
                                                          "Hapus pelanggan ini?",
                                                      onConfirm: () async {
                                                        await DatabaseHelper
                                                            .instance
                                                            .deletePelanggan(
                                                                pelanggan.id!);
                                                        Navigator.pop(context);
                                                        showSuccessAlert(
                                                            context,
                                                            "Berhasil Terhapus!");
                                                        setState(() {
                                                          _futurePelanggans =
                                                              fetchPelanggans();
                                                        });
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Iconify(
                                                Bi.x_circle,
                                                size: 24,
                                                color: Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    // CHANGED THIS PART - SIMPLIFIED FLOATING BUTTON POSITIONING
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ExpensiveFloatingButton(
                        text: 'TAMBAH',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddPelangganPage(),
                            ),
                          );

                          if (result == true) {
                            setState(() {
                              _futurePelanggans = fetchPelanggans();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pelangganToolBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchTextField(
            prefixIcon: const Icon(Icons.search, size: 24),
            obscureText: false,
            hintText: "Cari Pelanggan",
            controller: _searchController,
            maxLines: 1,
            suffixIcon: null,
            color: cardColor,
          ),
        ),
        const Gap(10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: cardColor,
          ),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.sort_by_alpha),
                          title: const Text("Nama A-Z"),
                          onTap: () {
                            setState(() {
                              _futurePelanggans =
                                  fetchPelanggansSorted('namaPelanggan', 'asc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.sort_by_alpha),
                          title: const Text("Nama Z-A"),
                          onTap: () {
                            setState(() {
                              _futurePelanggans = fetchPelanggansSorted(
                                  'namaPelanggan', 'desc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: const Text("Kode A-Z"),
                          onTap: () {
                            setState(() {
                              _futurePelanggans =
                                  fetchPelanggansSorted('kode', 'asc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: const Text("Kode Z-A"),
                          onTap: () {
                            setState(() {
                              _futurePelanggans =
                                  fetchPelanggansSorted('kode', 'desc');
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
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.sort, size: 24),
            ),
          ),
        ),
      ],
    );
  }
}
