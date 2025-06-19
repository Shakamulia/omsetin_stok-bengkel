// lib/view/page/service/service_page.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/services.dart';
import 'package:omsetin_bengkel/providers/securityProvider.dart';
import 'package:omsetin_bengkel/services/service_db_helper.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/pinModalWithAnimation.dart';
import 'package:omsetin_bengkel/utils/successAlert.dart';
import 'package:omsetin_bengkel/view/page/service/add_service.dart';
import 'package:omsetin_bengkel/view/page/service/update_service.dart';
import 'package:omsetin_bengkel/view/widget/Notfound.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/confirm_delete_dialog.dart';
import 'package:omsetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_bengkel/view/widget/pinModal.dart';
import 'package:omsetin_bengkel/view/widget/refresWidget.dart';
import 'package:omsetin_bengkel/view/widget/search.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();

  static String formatCurrency(int amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
        .format(amount);
  }
}

class _ServicePageState extends State<ServicePage> {
  final ServiceDatabaseHelper _serviceHelper = ServiceDatabaseHelper();
  late TextEditingController _searchController;
  bool? _isDeleteServiceOn;

  Future<List<Service>>? _futureServices;
  List<Service> _filteredServices = [];

  // Metode untuk mengambil data dari database
  Future<List<Service>> fetchServices() async {
    final serviceData = await _serviceHelper.getServices();
    print("Fetched services: $serviceData");
    return serviceData;
  }

  // Metode untuk refresh data
  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _futureServices = fetchServices();
    });
  }

  // Metode untuk filter data
  void _filterSearch() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _futureServices = fetchServices();
      } else {
        _futureServices = fetchServices().then((services) {
          return services.where((service) {
            return service.serviceName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
          }).toList();
        });
      }
    });
  }

  // Metode untuk mengurutkan data
  Future<List<Service>> fetchServicesSorted(
      String column, String sortOrder) async {
    final serviceData = await fetchServices();
    serviceData.sort((a, b) {
      var aValue = a.toJson()[column];
      var bValue = b.toJson()[column];

      if (aValue is String && bValue is String) {
        return sortOrder == 'asc'
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else if (aValue is num && bValue is num) {
        return sortOrder == 'asc'
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }
      return 0;
    });
    return serviceData;
  }

  // Metode untuk mengurutkan data berdasarkan tanggal
  Future<List<Service>> fetchServicesSortedByDate(
      String column, String sortOrder) async {
    final serviceData = await fetchServices();
    serviceData.sort((a, b) {
      var aValue = DateTime.parse(a.toJson()[column]);
      var bValue = DateTime.parse(b.toJson()[column]);
      return sortOrder == 'asc'
          ? aValue.compareTo(bValue)
          : bValue.compareTo(aValue);
    });
    return serviceData;
  }

  // Metode untuk memuat preferensi keamanan
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDeleteServiceOn = prefs.getBool('hapusLayanan') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _searchController = TextEditingController();
    _searchController.addListener(_filterSearch);
    _futureServices = fetchServices(); // Inisialisasi data pertama kali
  }

  @override
  void dispose() {
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
                'KELOLA LAYANAN',
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
      // ✅ FIXED: Service page layout with correct Stack, z-order, and FloatingButton positioning
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              ServiceToolBar(context),
              const Gap(10),
              Expanded(
                child: Stack(
                  children: [
                    FutureBuilder<List<Service>>(
                      future: _futureServices,
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

                        final services = snapshot.data ?? [];

                        if (services.isEmpty) {
                          return CustomRefreshWidget(
                            onRefresh: _pullRefresh,
                            child: Center(
                              child: NotFoundPage(
                                title: _searchController.text.isEmpty
                                    ? "Tidak ada Layanan"
                                    : 'Tidak ada Layanan dengan nama "${_searchController.text}"',
                              ),
                            ),
                          );
                        }

                        _filteredServices = services;
                        return CustomRefreshWidget(
                          onRefresh: _pullRefresh,
                          child: ListView.builder(
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = _filteredServices[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: 5.0, bottom: 5.0),
                                child: ZoomTapAnimation(
                                  onTap: () async {
                                    if (securityProvider.editServices) {
                                      showPinModalWithAnimation(context,
                                          pinModal: PinModal(
                                            destination: UpdateServicePage(
                                                service: service),
                                          ));
                                    }else{

                                                                     final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UpdateServicePage(service: service),
                                      ),
                                    );

                                    if (result == true) {
                                      setState(() {
                                        _futureServices = fetchServices();
                                      });
                                    }
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
                                                  Icons.construction,
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
                                                  service.serviceName,
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
                                                  "${ServicePage.formatCurrency(service.servicePrice.toInt())}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          securityProvider.hapusServices
                                              ? const SizedBox.shrink()
                                              :
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return ConfirmDeleteDialog(
                                                      message:
                                                          "Hapus layanan ini?",
                                                      onConfirm: () async {
                                                        await _serviceHelper
                                                            .deleteService(
                                                                service
                                                                    .serviceId!);
                                                        Navigator.pop(context);
                                                        showSuccessAlert(
                                                            context,
                                                            "Berhasil Terhapus!");
                                                        setState(() {
                                                          _futureServices =
                                                              fetchServices();
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
                      child: securityProvider.tambahServices
                          ? const SizedBox.shrink()
                          : ExpensiveFloatingButton(
                              text: 'TAMBAH',
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddServicePage(),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    _futureServices = fetchServices();
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

  Widget ServiceToolBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchTextField(
            prefixIcon: const Icon(Icons.search, size: 24),
            obscureText: false,
            hintText: "Cari Layanan",
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
                          title: const Text("A-Z"),
                          onTap: () {
                            setState(() {
                              _futureServices =
                                  fetchServicesSorted('name', 'asc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.sort_by_alpha),
                          title: const Text("Z-A"),
                          onTap: () {
                            setState(() {
                              _futureServices =
                                  fetchServicesSorted('name', 'desc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text("Terbaru"),
                          onTap: () {
                            setState(() {
                              _futureServices = fetchServicesSortedByDate(
                                  "dateAdded", 'desc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text("Terlama"),
                          onTap: () {
                            setState(() {
                              _futureServices =
                                  fetchServicesSortedByDate("dateAdded", 'asc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: const Text("Termahal"),
                          onTap: () {
                            setState(() {
                              _futureServices =
                                  fetchServicesSorted("price", 'desc');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: const Text("Termurah"),
                          onTap: () {
                            setState(() {
                              _futureServices =
                                  fetchServicesSorted("price", 'asc');
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
