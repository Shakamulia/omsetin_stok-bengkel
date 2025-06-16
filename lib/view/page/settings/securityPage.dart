import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_stok/providers/securityProvider.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/utils/successAlert.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:omsetin_stok/view/widget/pinModal.dart';
import 'package:omsetin_stok/view/widget/pinModalChangePassword.dart';
import 'package:omsetin_stok/view/widget/primary_button.dart';

import 'package:omsetin_stok/services/sharedPrefences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omsetin_stok/providers/securityProviderMekanik.dart';
import 'package:omsetin_stok/providers/securityProviderLayanan.dart';
import 'package:omsetin_stok/providers/securityProviderPelanggan.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  _SecuritySettingsPageState createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  void initState() {
    super.initState();

    _loadSettings();
  }

  bool securityPelanggan = false;
  bool _kunciProduk = false;
  bool _tambahProduk = false;
  bool _tambahStokProduk = false;
  bool _hapusStokProduk = false;
  bool _editProduk = false;
  bool _hapusProduk = false;
  bool _kunciKategori = false;
  bool _kunciTambahKategori = false;
  bool _editKategori = false;
  bool _hapusKategori = false;
  bool _kunciPengeluaran = false;
  bool _tambahPengeluaran = false;
  bool _editPengeluaran = false;
  bool _hapusPengeluaran = false;
  bool _kunciPemasukan = false;
  bool _tambahPemasukan = false;
  bool _editPemasukan = false;
  bool _hapusPemasukan = false;
  bool _sembunyikanProfit = false;
  bool _kunciRiwayatTransaksi = false;
  bool _tanggalTransaksi = false;
  bool _batalkanTransaksi = false;
  bool _editTransaksi = false;
  bool _hapusTransaksi = false;
  bool _tambahMetode = false;
  bool _editMetode = false;
  bool _hapusMetode = false;
  bool _kunciCetakStruk = false;
  bool _kunciBagikanStruk = false;
  bool _kunciLaporan = false;
  bool _kunciPengaturanToko = false;
  bool _kunciGantiPassword = false;
  bool _kunciKeamanan = false;
  bool _kunciRestoreData = false;
  bool _sembunyikanHapusBackup = false;
  bool _sembunyikanLogout = false;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kunciRiwayatTransaksi = prefs.getBool('kunciRiwayatTransaksi') ?? false;
      _kunciProduk = prefs.getBool('kunciProduk') ?? false;
      _tambahProduk = prefs.getBool('tambahProduk') ?? false;
      _tambahStokProduk = prefs.getBool('tambahStokProduk') ?? false;
      _hapusStokProduk = prefs.getBool('hapusStokProduk') ?? false;
      _editProduk = prefs.getBool('editProduk') ?? false;
      _hapusProduk = prefs.getBool('hapusProduk') ?? false;
      _kunciTambahKategori = prefs.getBool('tambahKategori') ?? false;
      _kunciKategori = prefs.getBool('kunciKategori') ?? false;
      _editKategori = prefs.getBool('editKategori') ?? false;
      _hapusKategori = prefs.getBool('hapusKategori') ?? false;
      _kunciPengeluaran = prefs.getBool('kunciPengeluaran') ?? false;
      _tambahPengeluaran = prefs.getBool('tambahPengeluaran') ?? false;
      _editPengeluaran = prefs.getBool('editPengeluaran') ?? false;
      _hapusPengeluaran = prefs.getBool('hapusPengeluaran') ?? false;
      _kunciPemasukan = prefs.getBool('kunciPemasukan') ?? false;
      _tambahPemasukan = prefs.getBool('tambahPemasukan') ?? false;
      _editPemasukan = prefs.getBool('editPemasukan') ?? false;
      _hapusPemasukan = prefs.getBool('hapusPemasukan') ?? false;
      _sembunyikanProfit = prefs.getBool('sembunyikanProfit') ?? false;
      _tanggalTransaksi = prefs.getBool('tanggalTransaksi') ?? false;
      _batalkanTransaksi = prefs.getBool('batalkanTransaksi') ?? false;
      _editTransaksi = prefs.getBool('editTransaksi') ?? false;
      _hapusTransaksi = prefs.getBool('hapusTransaksi') ?? false;
      _tambahMetode = prefs.getBool('tambahMetode') ?? false;
      _editMetode = prefs.getBool('editMetode') ?? false;
      _hapusMetode = prefs.getBool('hapusMetode') ?? false;
      _kunciCetakStruk = prefs.getBool('kunciCetakStruk') ?? false;
      _kunciBagikanStruk = prefs.getBool('kunciBagikanStruk') ?? false;
      _kunciLaporan = prefs.getBool('kunciLaporan') ?? false;
      _kunciPengaturanToko = prefs.getBool('kunciPengaturanToko') ?? false;
      _kunciGantiPassword = prefs.getBool('kunciGantiPassword') ?? false;
      _kunciKeamanan = prefs.getBool('kunciKeamanan') ?? false;
      _kunciRestoreData = prefs.getBool('kunciRestoreData') ?? false;
      _sembunyikanHapusBackup =
          prefs.getBool('sembunyikanHapusBackup') ?? false;
      _sembunyikanLogout = prefs.getBool('sembunyikanLogout') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kunciProduk', _kunciProduk);
    await prefs.setBool('kunciRiwayatTransaksi', _kunciRiwayatTransaksi);
    await prefs.setBool('tambahProduk', _tambahProduk);
    await prefs.setBool('tambahStokProduk', _tambahStokProduk);
    await prefs.setBool('hapusStokProduk', _hapusStokProduk);
    await prefs.setBool('editProduk', _editProduk);
    await prefs.setBool('hapusProduk', _hapusProduk);
    await prefs.setBool('kunciKategori', _kunciKategori);
    await prefs.setBool('tambahKategori', _kunciTambahKategori);
    await prefs.setBool('editKategori', _editKategori);
    await prefs.setBool('hapusKategori', _hapusKategori);
    await prefs.setBool('kunciPengeluaran', _kunciPengeluaran);
    await prefs.setBool('tambahPengeluaran', _tambahPengeluaran);
    await prefs.setBool('editPengeluaran', _editPengeluaran);
    await prefs.setBool('hapusPengeluaran', _hapusPengeluaran);
    await prefs.setBool('kunciPemasukan', _kunciPemasukan);
    await prefs.setBool('tambahPemasukan', _tambahPemasukan);
    await prefs.setBool('editPemasukan', _editPemasukan);
    await prefs.setBool('hapusPemasukan', _hapusPemasukan);
    await prefs.setBool('sembunyikanProfit', _sembunyikanProfit);
    await prefs.setBool('tanggalTransaksi', _tanggalTransaksi);
    await prefs.setBool('batalkanTransaksi', _batalkanTransaksi);
    await prefs.setBool('editTransaksi', _editTransaksi);
    await prefs.setBool('hapusTransaksi', _hapusTransaksi);
    await prefs.setBool('tambahMetode', _tambahMetode);
    await prefs.setBool('editMetode', _editMetode);
    await prefs.setBool('hapusMetode', _hapusMetode);
    await prefs.setBool('kunciCetakStruk', _kunciCetakStruk);
    await prefs.setBool('kunciBagikanStruk', _kunciBagikanStruk);
    await prefs.setBool('kunciLaporan', _kunciLaporan);
    await prefs.setBool('kunciPengaturanToko', _kunciPengaturanToko);
    await prefs.setBool('kunciGantiPassword', _kunciGantiPassword);
    await prefs.setBool('kunciKeamanan', _kunciKeamanan);
    await prefs.setBool('kunciRestoreData', _kunciRestoreData);
    await prefs.setBool('sembunyikanHapusBackup', _sembunyikanHapusBackup);
    await prefs.setBool('sembunyikanLogout', _sembunyikanLogout);

    Provider.of<SecurityProvider>(context, listen: false).reloadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
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
                end: Alignment.bottomCenter
              )
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              leading: CustomBackButton(),
              title: Text(
                'KEAMANAN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              scrolledUnderElevation: 0,
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildSettingSection('Transaksi', [
                              Divider(
                                color: primaryColor,
                                thickness: 2,
                              ),
                              _buildSettingItem('Kunci Riwayat Transaksi',
                                  _kunciRiwayatTransaksi, (value) {
                                setState(() {
                                  _kunciRiwayatTransaksi = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Sembunyikan Profit', _sembunyikanProfit,
                                  (value) {
                                setState(() {
                                  _sembunyikanProfit = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Tanggal Transaksi', _tanggalTransaksi,
                                  (value) {
                                setState(() {
                                  _tanggalTransaksi = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Batalkan Transaksi', _batalkanTransaksi,
                                  (value) {
                                setState(() {
                                  _batalkanTransaksi = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Edit Transaksi', _editTransaksi, (value) {
                                setState(() {
                                  _editTransaksi = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Hapus Transaksi', _hapusTransaksi, (value) {
                                setState(() {
                                  _hapusTransaksi = value;
                                });
                              }),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    
                    // Produk
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildSettingSection('Spare Part', [
                              Divider(color: primaryColor, thickness: 2),
                              _buildSettingItem('Kunci Spare Part', _kunciProduk,
                                  (value) {
                                setState(() {
                                  _kunciProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Sembunyikan Tambah Spare Part', _tambahProduk,
                                  (value) {
                                setState(() {
                                  _tambahProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Tambah Stok Spare Part', _tambahStokProduk,
                                  (value) {
                                setState(() {
                                  _tambahStokProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Hapus Stok Spare Part', _hapusStokProduk,
                                  (value) {
                                setState(() {
                                  _hapusStokProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Nonaktifkan Edit Spare Part', _editProduk,
                                  (value) {
                                setState(() {
                                  _editProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Sembunyikan Hapus Spare Part', _hapusProduk,
                                  (value) {
                                setState(() {
                                  _hapusProduk = value;
                                });
                              }),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    // Contoh section Pelanggan
                    // Pelanggan Section
                    // Card(
                    //   color: Colors.white,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(12.0),
                    //     child: Column(
                    //       children: [
                    //         _buildSettingSection('Pelanggan', [
                    //           Divider(color: primaryColor, thickness: 2),
                    //           _buildSettingItem('Kunci Pelanggan', securityPelanggan.kunciPelanggan, (value) {
                    //             securityPelanggan.updateKunciPelanggan(value);
                    //           }),
                    //           _buildSettingItem('Tambah Pelanggan', securityPelanggan.tambahPelanggan, (value) {
                    //             securityPelanggan.updateTambahPelanggan(value);
                    //           }),
                    //           _buildSettingItem('Edit Pelanggan', securityPelanggan.editPelanggan, (value) {
                    //             securityPelanggan.updateEditPelanggan(value);
                    //           }),
                    //           _buildSettingItem('Hapus Pelanggan', securityPelanggan.hapusPelanggan, (value) {
                    //             securityPelanggan.updateHapusPelanggan(value);
                    //           }),
                    //           _buildSettingItem('Lihat Detail Pelanggan', securityPelanggan.lihatDetailPelanggan, (value) {
                    //             securityPelanggan.updateLihatDetailPelanggan(value);
                    //           }),
                    //           _buildSettingItem('Riwayat Pelanggan', securityPelanggan.riwayatPelanggan, (value) {
                    //             securityPelanggan.updateRiwayatPelanggan(value);
                    //           }),
                    //         ]),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // // Layanan Section
                    // Card(
                    //   color: Colors.white,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(12.0),
                    //     child: Column(
                    //       children: [
                    //         _buildSettingSection('Layanan', [
                    //           Divider(color: primaryColor, thickness: 2),
                    //           _buildSettingItem('Kunci Layanan', securityLayanan.kunciLayanan, (value) {
                    //             securityLayanan.updateKunciLayanan(value);
                    //           }),
                    //           _buildSettingItem('Tambah Layanan', securityLayanan.tambahLayanan, (value) {
                    //             securityLayanan.updateTambahLayanan(value);
                    //           }),
                    //           _buildSettingItem('Edit Layanan', securityLayanan.editLayanan, (value) {
                    //             securityLayanan.updateEditLayanan(value);
                    //           }),
                    //           _buildSettingItem('Hapus Layanan', securityLayanan.hapusLayanan, (value) {
                    //             securityLayanan.updateHapusLayanan(value);
                    //           }),
                    //           _buildSettingItem('Lihat Detail Layanan', securityLayanan.lihatDetailLayanan, (value) {
                    //             securityLayanan.updateLihatDetailLayanan(value);
                    //           }),
                    //           _buildSettingItem('Kategori Layanan', securityLayanan.kategoriLayanan, (value) {
                    //             securityLayanan.updateKategoriLayanan(value);
                    //           }),
                    //         ]),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // // Mekanik Section
                    // Card(
                    //   color: Colors.white,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(12.0),
                    //     child: Column(
                    //       children: [
                    //         _buildSettingSection('Mekanik', [
                    //           Divider(color: primaryColor, thickness: 2),
                    //           _buildSettingItem('Kunci Mekanik', securityMekanik.kunciMekanik, (value) {
                    //             securityMekanik.updateKunciMekanik(value);
                    //           }),
                    //           _buildSettingItem('Tambah Mekanik', securityMekanik.tambahMekanik, (value) {
                    //             securityMekanik.updateTambahMekanik(value);
                    //           }),
                    //           _buildSettingItem('Edit Mekanik', securityMekanik.editMekanik, (value) {
                    //             securityMekanik.updateEditMekanik(value);
                    //           }),
                    //           _buildSettingItem('Hapus Mekanik', securityMekanik.hapusMekanik, (value) {
                    //             securityMekanik.updateHapusMekanik(value);
                    //           }),
                    //           _buildSettingItem('Lihat Detail Mekanik', securityMekanik.lihatDetailMekanik, (value) {
                    //             securityMekanik.updateLihatDetailMekanik(value);
                    //           }),
                    //           _buildSettingItem('Riwayat Mekanik', securityMekanik.riwayatMekanik, (value) {
                    //             securityMekanik.updateRiwayatMekanik(value);
                    //           }),
                    //           _buildSettingItem('Status Mekanik', securityMekanik.statusMekanik, (value) {
                    //             securityMekanik.updateStatusMekanik(value);
                    //           }),
                    //         ]),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildSettingSection('Spare Part', [
                              Divider(color: primaryColor, thickness: 2),
                              _buildSettingItem('Kunci Spare Part', _kunciProduk,
                                  (value) {
                                setState(() {
                                  _kunciProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Sembunyikan Tambah Spare Part', _tambahProduk,
                                  (value) {
                                setState(() {
                                  _tambahProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Tambah Stok Spare Part', _tambahStokProduk,
                                  (value) {
                                setState(() {
                                  _tambahStokProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Hapus Stok Spare Part', _hapusStokProduk,
                                  (value) {
                                setState(() {
                                  _hapusStokProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Nonaktifkan Edit Spare Part', _editProduk,
                                  (value) {
                                setState(() {
                                  _editProduk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Sembunyikan Hapus Spare Part', _hapusProduk,
                                  (value) {
                                setState(() {
                                  _hapusProduk = value;
                                });
                              }),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    // Kategori
                    // Card(
                    //   color: Colors.white,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(12.0),
                    //     child: Column(
                    //       children: [
                    //         _buildSettingSection('Kategori', [
                    //           Divider(
                    //             color: primaryColor,
                    //             thickness: 2,
                    //           ),
                    //           _buildSettingItem(
                    //               'Kunci Kategori', _kunciKategori, (value) {
                    //             setState(() {
                    //               _kunciKategori = value;
                    //             });
                    //           }),
                    //           _buildSettingItem(
                    //               'Nonaktifkan Edit Kategori', _editKategori,
                    //               (value) {
                    //             setState(() {
                    //               _editKategori = value;
                    //             });
                    //           }),
                    //           _buildSettingItem(
                    //               'Kunci Tambah Kategori', _kunciTambahKategori,
                    //               (value) {
                    //             setState(() {
                    //               _kunciTambahKategori = value;
                    //             });
                    //           }),
                    //           _buildSettingItem(
                    //               'Sembunyikan Hapus Kategori', _hapusKategori,
                    //               (value) {
                    //             setState(() {
                    //               _hapusKategori = value;
                    //             });
                    //           }),
                    //         ]),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Pengeluaran
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildSettingSection('Pengeluaran', [
                              Divider(
                                color: primaryColor,
                                thickness: 2,
                              ),
                              _buildSettingItem(
                                  'Kunci Pengeluaran', _kunciPengeluaran,
                                  (value) {
                                setState(() {
                                  _kunciPengeluaran = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Sembunyikan Tambah Pengeluaran',
                                  _tambahPengeluaran, (value) {
                                setState(() {
                                  _tambahPengeluaran = value;
                                });
                              }),
                              // _buildSettingItem(
                              //     'Edit Pengeluaran', _editPengeluaran,
                              //     (value) {
                              //   setState(() {
                              //     _editPengeluaran = value;
                              //   });
                              // }),
                              // _buildSettingItem(
                              //     'Hapus Pengeluaran', _hapusPengeluaran,
                              //     (value) {
                              //   setState(() {
                              //     _hapusPengeluaran = value;
                              //   });
                              // }),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildSettingSection('Pemasukan', [
                              Divider(
                                color: primaryColor,
                                thickness: 2,
                              ),
                              _buildSettingItem(
                                  'Kunci Pemasukan', _kunciPemasukan, (value) {
                                setState(() {
                                  _kunciPemasukan = value;
                                });
                              }),
                              _buildSettingItem('Sembunyikan Tambah Pemasukan',
                                  _tambahPemasukan, (value) {
                                setState(() {
                                  _tambahPemasukan = value;
                                });
                              }),
                              // _buildSettingItem(
                              //     'Edit Pemasukan', _editPemasukan, (value) {
                              //   setState(() {
                              //     _editPemasukan = value;
                              //   });
                              // }),
                              // _buildSettingItem(
                              //     'Hapus Pemasukan', _hapusPemasukan, (value) {
                              //   setState(() {
                              //     _hapusPemasukan = value;
                              //   });
                              // }),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    // Transaksi
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildSettingSection('Laporan', [
                              Divider(color: primaryColor, thickness: 2),
                              _buildSettingItem('Kunci Laporan', _kunciLaporan,
                                  (value) {
                                setState(() {
                                  _kunciLaporan = value;
                                });
                              }),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    // Metode
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildSettingSection('Metode ', [
                              Divider(color: primaryColor, thickness: 2),
                              _buildSettingItem(
                                  'Sembunyikan Tambah Metode', _tambahMetode,
                                  (value) {
                                setState(() {
                                  _tambahMetode = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Sembunyikan Edit Metode', _editMetode,
                                  (value) {
                                setState(() {
                                  _editMetode = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Sembunyikan Hapus Metode', _hapusMetode,
                                  (value) {
                                setState(() {
                                  _hapusMetode = value;
                                });
                              }),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    // Cetak Struk
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildSettingSection('Cetak Struk', [
                              Divider(color: primaryColor, thickness: 2),
                              _buildSettingItem(
                                  'Kunci Cetak Struk', _kunciCetakStruk,
                                  (value) {
                                setState(() {
                                  _kunciCetakStruk = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Kunci Bagikan Struk', _kunciBagikanStruk,
                                  (value) {
                                setState(() {
                                  _kunciBagikanStruk = value;
                                });
                              }),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    // Laporan

                    // Pengaturan Toko
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildSettingSection('Pengaturan Toko', [
                              Divider(color: primaryColor, thickness: 2),
                              _buildSettingItem(
                                  'Kunci Pengaturan Toko', _kunciPengaturanToko,
                                  (value) {
                                setState(() {
                                  _kunciPengaturanToko = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Kunci Keamanan', _kunciKeamanan, (value) {
                                setState(() {
                                  _kunciKeamanan = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Kunci Ganti Password', _kunciGantiPassword,
                                  (value) {
                                setState(() {
                                  _kunciGantiPassword = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Kunci Restore Data', _kunciRestoreData,
                                  (value) {
                                setState(() {
                                  _kunciRestoreData = value;
                                });
                              }),
                              // _buildSettingItem('Sembunyikan Hapus Backup',
                              //     _sembunyikanHapusBackup, (value) {
                              //   setState(() {
                              //     _sembunyikanHapusBackup = value;
                              //   });
                              // }),
                              _buildSettingItem(
                                  'Sembunyikan Logout', _sembunyikanLogout,
                                  (value) {
                                setState(() {
                                  _sembunyikanLogout = value;
                                });
                              }),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    Gap(5),
                    Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment(0.8, 1),
                                colors: const <Color>[
                                  primaryColor,
                                  secondaryColor
                                ],
                                tileMode: TileMode.mirror,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      color: Colors.transparent,
                                      child: GestureDetector(
                                          onTap: () {},
                                          child: PinModalChangePassword()),
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                );
                              },
                              child: const Text(
                                "UBAH SANDI",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Gap(65),
                  ],
                ),
              ),
            ),
            ExpensiveFloatingButton(
              onPressed: () async {
                await _saveSettings();
                showSuccessAlert(context, "Pengaturan berhasil disimpan");
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSettingItem(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: primaryColor,
          inactiveTrackColor: greyColor,
          inactiveThumbColor: primaryColor,
        ),
      ],
    );
  }
}
