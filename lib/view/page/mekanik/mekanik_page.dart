// lib/view/page/mekanik/mekanik_page.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/mekanik.dart';
import 'package:omsetin_stok/providers/securityProvider.dart';
import 'package:omsetin_stok/services/db_helper.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/successAlert.dart';
import 'package:omsetin_stok/view/page/mekanik/add_mekanik.dart';
import 'package:omsetin_stok/view/page/mekanik/update_mekanik.dart';
import 'package:omsetin_stok/view/widget/Notfound.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/confirm_delete_dialog.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_stok/view/widget/refresWidget.dart';
import 'package:omsetin_stok/view/widget/search.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class mekanikPage extends StatefulWidget {
  const mekanikPage({super.key});

  @override
  State<mekanikPage> createState() => _MekanikPageState();
}

class _MekanikPageState extends State<mekanikPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late TextEditingController _searchController;
  bool? _isDeletemekanikOn;

  Future<List<Mekanik>>? _futuremekaniks;
  List<Mekanik> _filteredmekaniks = [];

  Future<List<Mekanik>> fetchmekaniks() async {
    final mekanikData = await DatabaseHelper.instance.getAllMekanik();
    print("Fetched mekaniks: $mekanikData");
    return mekanikData;
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _futuremekaniks = fetchmekaniks();
    });
  }

  void _filterSearch() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _futuremekaniks = fetchmekaniks();
      } else {
        _futuremekaniks = fetchmekaniks().then((mekaniks) {
          return mekaniks.where((mekanik) {
            return mekanik.namaMekanik
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
          }).toList();
        });
      }
    });
  }

  Future<List<Mekanik>> fetchmekaniksSorted(
      String column, String sortOrder) async {
    final mekanikData = await fetchmekaniks();
    mekanikData.sort((a, b) {
      var aValue = a.toMap()[column];
      var bValue = b.toMap()[column];

      if (aValue is String && bValue is String) {
        return sortOrder == 'asc'
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }
      return 0;
    });
    return mekanikData;
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDeletemekanikOn = prefs.getBool('hapusMekanik') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _searchController = TextEditingController();
    _searchController.addListener(_filterSearch);
    _futuremekaniks = fetchmekaniks();
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
                'KELOLA MEKANIK',
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
              mekanikToolBar(context),
              const Gap(10),
              Expanded(
                child: Stack(
                  children: [
                    FutureBuilder<List<Mekanik>>(
                      future: _futuremekaniks,
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
                              child: SizedBox(
                                height: 200,
                                child: NotFoundPage(
                                  title: _searchController.text.isEmpty
                                      ? "Tidak ada Mekanik"
                                      : 'Tidak ada Mekanik dengan nama "${_searchController.text}"',
                                ),
                              ),
                            ),
                          );
                        }

                        _filteredmekaniks = snapshot.data!;
                        return CustomRefreshWidget(
                          onRefresh: _pullRefresh,
                          child: ListView.builder(
                            itemCount: _filteredmekaniks.length,
                            itemBuilder: (context, index) {
                              final mekanik = _filteredmekaniks[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: 5.0, bottom: 5.0),
                                child: ZoomTapAnimation(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UpdateMekanikPage(mekanik: mekanik),
                                      ),
                                    );

                                    if (result == true) {
                                      setState(() {
                                        _futuremekaniks = fetchmekaniks();
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 100,
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
                                                  mekanik.namaMekanik,
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
                                                  "Spesialis: ${mekanik.spesialis}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "No. HP: ${mekanik.noHandphone}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_isDeletemekanikOn != true)
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return ConfirmDeleteDialog(
                                                      message:
                                                          "Hapus mekanik ini?",
                                                      onConfirm: () async {
                                                        await DatabaseHelper
                                                            .instance
                                                            .deleteMekanik(
                                                                mekanik.id!);
                                                        Navigator.pop(context);
                                                        showSuccessAlert(
                                                            context,
                                                            "Berhasil Terhapus!");
                                                        setState(() {
                                                          _futuremekaniks =
                                                              fetchmekaniks();
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
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ExpensiveFloatingButton(
                        text: 'TAMBAH',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddMekanikPage(),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              _futuremekaniks = fetchmekaniks();
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

  Widget mekanikToolBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchTextField(
            prefixIcon: const Icon(Icons.search, size: 24),
            obscureText: false,
            hintText: "Cari Mekanik",
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
                              _futuremekaniks =
                                  fetchmekaniksSorted('namaMekanik', 'asc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.sort_by_alpha),
                          title: const Text("Nama Z-A"),
                          onTap: () {
                            setState(() {
                              _futuremekaniks =
                                  fetchmekaniksSorted('namaMekanik', 'desc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.engineering),
                          title: const Text("Spesialis A-Z"),
                          onTap: () {
                            setState(() {
                              _futuremekaniks =
                                  fetchmekaniksSorted('spesialis', 'asc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.engineering),
                          title: const Text("Spesialis Z-A"),
                          onTap: () {
                            setState(() {
                              _futuremekaniks =
                                  fetchmekaniksSorted('spesialis', 'desc');
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
