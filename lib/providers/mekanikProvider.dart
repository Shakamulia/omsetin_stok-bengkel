import 'package:flutter/material.dart';
import 'package:omzetin_bengkel/model/mekanik.dart';
import 'package:omzetin_bengkel/services/database_service.dart';

class MekanikProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<List<Mekanik>> getMekanikList(
      {String query = '', String sortOrder = 'asc'}) async {
    List<Mekanik> mekanikList = [];

    try {
      final data = await _databaseService.getAllMekanik();

      mekanikList = data.map((e) => Mekanik.fromJson(e)).toList();

      // Filter berdasarkan query
      if (query.isNotEmpty) {
        mekanikList = mekanikList
            .where((mekanik) =>
                mekanik.namaMekanik.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      // Sorting
      if (sortOrder == 'asc') {
        mekanikList.sort((a, b) => a.namaMekanik.compareTo(b.namaMekanik));
      } else if (sortOrder == 'desc') {
        mekanikList.sort((a, b) => b.namaMekanik.compareTo(a.namaMekanik));
      } else if (sortOrder == 'newest') {
        mekanikList.sort((a, b) => b.id!.compareTo(a.id!));
      } else if (sortOrder == 'oldest') {
        mekanikList.sort((a, b) => a.id!.compareTo(b.id!));
      }

      return mekanikList;
    } catch (e) {
      print('Error getting mekanik list: $e');
      return [];
    }
  }

  Future<void> addMekanik(Map<String, dynamic> mekanikData) async {
    try {
      debugPrint('Data sebelum insert: $mekanikData');
      mekanikData.remove('id');
      _isLoading = true;
      notifyListeners();

      // Mapping data ke format kolom database
      final mekanik = {
        'namaMekanik': mekanikData['namaMekanik'] ?? mekanikData['namaMekanik'],
        'profileImage':
            mekanikData['profileImage'] ?? mekanikData['profileImage'],
        'spesialis': mekanikData['spesialis'] ?? mekanikData['spesialis'],
        'noHandphone': mekanikData['noHandphone'] ?? mekanikData['noHandphone'],
        'gender': mekanikData['gender'] ?? mekanikData['gender'],
        'alamat': mekanikData['alamat'] ?? mekanikData['alamat'],
      };

      await _databaseService.addMekanik(mekanik);
    } catch (e) {
      debugPrint('Error adding pegawai: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> fetchMekanik() async {
    try {
      final pegawai = await getMekanikList();
      print('Fetched mekanik: $pegawai');
      notifyListeners();
      return pegawai.map((e) => e.namaMekanik).toList();
    } catch (e) {
      print('Error fetching pegawai: $e');
      return [];
    }
  }

  Future<void> updatePegawai(int id, Map<String, dynamic> mekanikData) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Mapping data ke format kolom database
      final mekanik = {
        'namaMekanik': mekanikData['namaMekanik'] ?? mekanikData['namaMekanik'],
        'profileImage':
            mekanikData['profileImage'] ?? mekanikData['profileImage'],
        'spesialis': mekanikData['spesialis'] ?? mekanikData['spesialis'],
        'noHandphone': mekanikData['noHandphone'] ?? mekanikData['noHandphone'],
        'gender': mekanikData['gender'] ?? mekanikData['gender'],
        'alamat': mekanikData['alamat'] ?? mekanikData['alamat'],
      };

      await _databaseService.updateMekanik(id, mekanik);
    } catch (e) {
      debugPrint('Error updating pegawai: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePegawai(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.deleteMekanik(id);
    } catch (e) {
      debugPrint('Error deleting pegawai: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
