import 'package:flutter/material.dart';
import 'package:omsetin_bengkel/model/mekanik.dart';
import 'package:omsetin_bengkel/model/pelanggan.dart';
import 'package:omsetin_bengkel/services/database_service.dart';

class Pelangganprovider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<List<Pelanggan>> getPelangganList(
      {String query = '', String sortOrder = 'asc'}) async {
    List<Pelanggan> pelangganList = [];

    try {
      // Assuming _databaseService.getAllPelanggan() returns List<Pelanggan>
      pelangganList = await _databaseService.getAllPelanggan();

      // If it actually returns List<Map>, use this instead:
      // final data = await _databaseService.getAllPelanggan();
      // pelangganList = data.map((e) => Pelanggan.fromMap(e)).toList();

      // Filter berdasarkan query
      if (query.isNotEmpty) {
        pelangganList = pelangganList
            .where((pelanggan) => pelanggan.namaPelanggan
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }

      // Sorting
      if (sortOrder == 'asc') {
        pelangganList
            .sort((a, b) => a.namaPelanggan.compareTo(b.namaPelanggan));
      } else if (sortOrder == 'desc') {
        pelangganList
            .sort((a, b) => b.namaPelanggan.compareTo(a.namaPelanggan));
      } else if (sortOrder == 'newest') {
        pelangganList.sort((a, b) => b.id!.compareTo(a.id!));
      } else if (sortOrder == 'oldest') {
        pelangganList.sort((a, b) => a.id!.compareTo(b.id!));
      }

      // Tampilkan data pelanggan di debugPrint
      debugPrint('Data pelanggan: ${pelangganList.map((e) => e.toJson()).toList()}');

      return pelangganList;
    } catch (e) {
      print('Error getting pelanggan list: $e');
      return [];
    }
  }

  Future<List<String>> fetchPelanggan() async {
    try {
      final pelanggan = await getPelangganList();
      print('Fetched pelanggan: $pelanggan');
      notifyListeners();
      return pelanggan.map((e) => e.namaPelanggan).toList();
    } catch (e) {
      print('Error fetching pelanggan: $e');
      return [];
    }
  }

  String generateKodePelanggan() {
    final now = DateTime.now();
    final yearMonth = '${now.year}${now.month.toString().padLeft(2, '0')}';
    final random = DateTime.now()
        .millisecondsSinceEpoch
        .remainder(10000)
        .toString()
        .padLeft(4, '0');
    return 'PLG$yearMonth$random';
  }

  Future<void> addPelanggan(Map<String, dynamic> dataToInsert) async {
    try {
      debugPrint('Data sebelum insert: $dataToInsert');
      _isLoading = true;
      notifyListeners();

      // Ensure all required fields are present
      final pelanggan = {
        'kode': dataToInsert['kode'] ?? generateKodePelanggan(),
        'namaPelanggan': dataToInsert['namaPelanggan'],
        'profileImage': dataToInsert['profileImage'],
        'noHandphone': dataToInsert['noHandphone'],
        'email': dataToInsert['email'], // Make sure this is not null
        'gender': dataToInsert['gender'],
        'alamat': dataToInsert['alamat'],
      };

      // Validate required fields
      if (pelanggan['email'] == null) {
        throw Exception('Email tidak boleh kosong');
      }

      await _databaseService.addPelanggan(pelanggan);
    } catch (e) {
      debugPrint('Error adding pelanggan: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePelanggan(
      int id, Map<String, dynamic> dataToInsert) async {
    try {
      debugPrint('Data sebelum insert: $dataToInsert');

      _isLoading = true;
      
      notifyListeners();

      // Mapping data ke format kolom database
      final data = {
        'kode': dataToInsert['kode'] ?? generateKodePelanggan(),
        'namaPelanggan': dataToInsert['namaPelanggan'],
        'profileImage': dataToInsert['profileImage'],
        'noHandphone': dataToInsert['noHandphone'],
        'email': dataToInsert['email'], // Make sure this is not null
        'gender': dataToInsert['gender'],
        'alamat': dataToInsert['alamat'],
      };

      await _databaseService.updatePelanggan(id, data);
    } catch (e) {
      debugPrint('Error updating pelanggan: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePelanggan(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.deletePelanggan(id);
    } catch (e) {
      debugPrint('Error deleting pelanggan: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
