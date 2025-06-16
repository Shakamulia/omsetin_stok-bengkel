import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityProviderPelanggan with ChangeNotifier {
  bool _kunciPelanggan = false;
  bool _tambahPelanggan = false;
  bool _editPelanggan = false;
  bool _hapusPelanggan = false;
  bool _lihatDetailPelanggan = false;
  bool _riwayatPelanggan = false;

  bool get kunciPelanggan => _kunciPelanggan;
  bool get tambahPelanggan => _tambahPelanggan;
  bool get editPelanggan => _editPelanggan;
  bool get hapusPelanggan => _hapusPelanggan;
  bool get lihatDetailPelanggan => _lihatDetailPelanggan;
  bool get riwayatPelanggan => _riwayatPelanggan;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _kunciPelanggan = prefs.getBool('kunciPelanggan') ?? false;
    _tambahPelanggan = prefs.getBool('tambahPelanggan') ?? false;
    _editPelanggan = prefs.getBool('editPelanggan') ?? false;
    _hapusPelanggan = prefs.getBool('hapusPelanggan') ?? false;
    _lihatDetailPelanggan = prefs.getBool('lihatDetailPelanggan') ?? false;
    _riwayatPelanggan = prefs.getBool('riwayatPelanggan') ?? false;
    notifyListeners();
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kunciPelanggan', _kunciPelanggan);
    await prefs.setBool('tambahPelanggan', _tambahPelanggan);
    await prefs.setBool('editPelanggan', _editPelanggan);
    await prefs.setBool('hapusPelanggan', _hapusPelanggan);
    await prefs.setBool('lihatDetailPelanggan', _lihatDetailPelanggan);
    await prefs.setBool('riwayatPelanggan', _riwayatPelanggan);
    notifyListeners();
  }

  void updateKunciPelanggan(bool value) {
    _kunciPelanggan = value;
    notifyListeners();
  }

  void updateTambahPelanggan(bool value) {
    _tambahPelanggan = value;
    notifyListeners();
  }

  void updateEditPelanggan(bool value) {
    _editPelanggan = value;
    notifyListeners();
  }

  void updateHapusPelanggan(bool value) {
    _hapusPelanggan = value;
    notifyListeners();
  }

  void updateLihatDetailPelanggan(bool value) {
    _lihatDetailPelanggan = value;
    notifyListeners();
  }

  void updateRiwayatPelanggan(bool value) {
    _riwayatPelanggan = value;
    notifyListeners();
  }
}