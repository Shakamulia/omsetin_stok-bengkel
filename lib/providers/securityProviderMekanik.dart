import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityProviderMekanik with ChangeNotifier {
  bool _kunciMekanik = false;
  bool _tambahMekanik = false;
  bool _editMekanik = false;
  bool _hapusMekanik = false;
  bool _lihatDetailMekanik = false;
  bool _riwayatMekanik = false;
  bool _statusMekanik = false;

  bool get kunciMekanik => _kunciMekanik;
  bool get tambahMekanik => _tambahMekanik;
  bool get editMekanik => _editMekanik;
  bool get hapusMekanik => _hapusMekanik;
  bool get lihatDetailMekanik => _lihatDetailMekanik;
  bool get riwayatMekanik => _riwayatMekanik;
  bool get statusMekanik => _statusMekanik;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _kunciMekanik = prefs.getBool('kunciMekanik') ?? false;
    _tambahMekanik = prefs.getBool('tambahMekanik') ?? false;
    _editMekanik = prefs.getBool('editMekanik') ?? false;
    _hapusMekanik = prefs.getBool('hapusMekanik') ?? false;
    _lihatDetailMekanik = prefs.getBool('lihatDetailMekanik') ?? false;
    _riwayatMekanik = prefs.getBool('riwayatMekanik') ?? false;
    _statusMekanik = prefs.getBool('statusMekanik') ?? false;
    notifyListeners();
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kunciMekanik', _kunciMekanik);
    await prefs.setBool('tambahMekanik', _tambahMekanik);
    await prefs.setBool('editMekanik', _editMekanik);
    await prefs.setBool('hapusMekanik', _hapusMekanik);
    await prefs.setBool('lihatDetailMekanik', _lihatDetailMekanik);
    await prefs.setBool('riwayatMekanik', _riwayatMekanik);
    await prefs.setBool('statusMekanik', _statusMekanik);
    notifyListeners();
  }

  void updateKunciMekanik(bool value) {
    _kunciMekanik = value;
    notifyListeners();
  }

  void updateTambahMekanik(bool value) {
    _tambahMekanik = value;
    notifyListeners();
  }

  void updateEditMekanik(bool value) {
    _editMekanik = value;
    notifyListeners();
  }

  void updateHapusMekanik(bool value) {
    _hapusMekanik = value;
    notifyListeners();
  }

  void updateLihatDetailMekanik(bool value) {
    _lihatDetailMekanik = value;
    notifyListeners();
  }

  void updateRiwayatMekanik(bool value) {
    _riwayatMekanik = value;
    notifyListeners();
  }

  void updateStatusMekanik(bool value) {
    _statusMekanik = value;
    notifyListeners();
  }
}