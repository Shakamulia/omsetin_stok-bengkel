import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityProviderLayanan with ChangeNotifier {
  bool _kunciLayanan = false;
  bool _tambahLayanan = false;
  bool _editLayanan = false;
  bool _hapusLayanan = false;
  bool _lihatDetailLayanan = false;
  bool _kategoriLayanan = false;

  bool get kunciLayanan => _kunciLayanan;
  bool get tambahLayanan => _tambahLayanan;
  bool get editLayanan => _editLayanan;
  bool get hapusLayanan => _hapusLayanan;
  bool get lihatDetailLayanan => _lihatDetailLayanan;
  bool get kategoriLayanan => _kategoriLayanan;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _kunciLayanan = prefs.getBool('kunciLayanan') ?? false;
    _tambahLayanan = prefs.getBool('tambahLayanan') ?? false;
    _editLayanan = prefs.getBool('editLayanan') ?? false;
    _hapusLayanan = prefs.getBool('hapusLayanan') ?? false;
    _lihatDetailLayanan = prefs.getBool('lihatDetailLayanan') ?? false;
    _kategoriLayanan = prefs.getBool('kategoriLayanan') ?? false;
    notifyListeners();
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kunciLayanan', _kunciLayanan);
    await prefs.setBool('tambahLayanan', _tambahLayanan);
    await prefs.setBool('editLayanan', _editLayanan);
    await prefs.setBool('hapusLayanan', _hapusLayanan);
    await prefs.setBool('lihatDetailLayanan', _lihatDetailLayanan);
    await prefs.setBool('kategoriLayanan', _kategoriLayanan);
    notifyListeners();
  }

  void updateKunciLayanan(bool value) {
    _kunciLayanan = value;
    notifyListeners();
  }

  void updateTambahLayanan(bool value) {
    _tambahLayanan = value;
    notifyListeners();
  }

  void updateEditLayanan(bool value) {
    _editLayanan = value;
    notifyListeners();
  }

  void updateHapusLayanan(bool value) {
    _hapusLayanan = value;
    notifyListeners();
  }

  void updateLihatDetailLayanan(bool value) {
    _lihatDetailLayanan = value;
    notifyListeners();
  }

  void updateKategoriLayanan(bool value) {
    _kategoriLayanan = value;
    notifyListeners();
  }
}
