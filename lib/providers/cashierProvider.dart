
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omsetin_stok/model/cashier.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashierProvider with ChangeNotifier {
  final DatabaseService _databaseService =
      DatabaseService.instance; // Initialize your database service

  Future<List<CashierData>> getCashiers(
      {String query = '', String sortOrder = 'asc'}) async {
    final db = await _databaseService.database;
    final data = await db.query(
      'cashier',
      where: query.isNotEmpty ? 'cashier_name LIKE ?' : null,
      whereArgs: query.isNotEmpty ? ['%$query%'] : null,
    );
    List<CashierData> cashiers = data
        .map((e) => CashierData(
              cashierId: e['cashier_id'] as int,
              cashierName: e['cashier_name'] as String,
              cashierPhoneNumber: e['cashier_phone_number'] as int,
              cashierImage: e['cashier_image'] as String,
              cashierTotalTransaction: e['cashier_total_transaction'] as int,
              cashierTotalTransactionMoney:
                  e['cashier_total_transaction_money'] as int,
              cashierPin: e['cashier_pin'] as int,
              selesai: e['selesai'] as int,
              proses: e['proses'] as int,
              pending: e['pending'] as int,
              batal: e['batal'] as int,
            ))
        .toList();

    // Apply sorting based on sortOrder
    if (sortOrder == 'asc') {
      cashiers.sort((a, b) => a.cashierName.compareTo(b.cashierName));
    } else if (sortOrder == 'desc') {
      cashiers.sort((a, b) => b.cashierName.compareTo(a.cashierName));
    } else if (sortOrder == 'newest') {
      cashiers.sort((a, b) => b.cashierId.compareTo(a.cashierId));
    } else if (sortOrder == 'oldest') {
      cashiers.sort((a, b) => a.cashierId.compareTo(b.cashierId));
    }

    // Move cashier with name "Owner" to the top
    cashiers.sort((a, b) {
      if (a.cashierName == 'Owner') return -1;
      if (b.cashierName == 'Owner') return 1;
      return 0;
    });

    print("Successfully retrieved cashiers: $cashiers");

    return cashiers;
  }

  Future<List<String>> fetchCashiers() async {
    try {
      final cashiers = await getCashiers();
      print('Fetched cashiers: $cashiers');
      notifyListeners();
      return cashiers.map((e) => e.cashierName).toList();
    } catch (e) {
      print('Error fetching cashiers: $e');
      return [];
    }
  }

  Future<int> getCashierIdByName(String cashierName) async {
    try {
      final cashiers = await getCashiers();
      debugPrint('Fetched cashiers: $cashiers');
      notifyListeners();
      final matchingCashier = cashiers.firstWhere(
        (cashier) => cashier.cashierName == cashierName,
        orElse: () => CashierData(
            cashierId: 0,
            cashierName: '',
            cashierPhoneNumber: 0,
            cashierImage: '',
            cashierTotalTransaction: 0,
            cashierTotalTransactionMoney: 0,
            cashierPin: 0,
            selesai: 0,
            proses: 0,
            pending: 0,
            batal: 0),
      );
      return matchingCashier.cashierId;
    } catch (e) {
      debugPrint('Error fetching cashiers: $e');
      return 0;
    }
  }

  Future<Map<String, int>> getAllCashierNameIdMap() async {
    final allCashiers = await fetchAllCashiers(); // ambil dari database
    return {for (var c in allCashiers) c.cashierName: c.cashierId};
  }

  Future<void> deleteCashier(int cashierId) async {
    final db = await _databaseService.database;
    await db.delete('cashier', where: 'cashier_id = ?', whereArgs: [cashierId]);
    notifyListeners();
  }

  Future<void> updateCashier(CashierData cashier) async {
    final db = await _databaseService.database;
    await db.update(
      'cashier',
      {
        'cashier_name': cashier.cashierName,
        'cashier_phone_number': cashier.cashierPhoneNumber,
        'cashier_image': cashier.cashierImage,
        'cashier_pin': cashier.cashierPin,
      },
      where: 'cashier_id = ?',
      whereArgs: [cashier.cashierId],
    );
    notifyListeners();
  }

  Future<CashierData?> getCashierById(int cashierId) async {
    final db = await _databaseService.database;
    final data = await db.query(
      'cashier',
      where: 'cashier_id = ?',
      whereArgs: [cashierId],
    );

    if (data.isNotEmpty) {
      final e = data.first;
      return CashierData(
        cashierId: e['cashier_id'] as int,
        cashierName: e['cashier_name'] as String,
        cashierPhoneNumber: e['cashier_phone_number'] as int,
        cashierImage: e['cashier_image'] as String,
        cashierTotalTransaction: e['cashier_total_transaction'] as int,
        cashierTotalTransactionMoney:
            e['cashier_total_transaction_money'] as int,
        cashierPin: e['cashier_pin'] as int,
        selesai: e['selesai'] as int,
        proses: e['proses'] as int,
        pending: e['pending'] as int,
        batal: e['batal'] as int,
      );
    }
    return null;
  }

  Future<CashierData?> getCashierByName(String cashierName) async {
    final db = await _databaseService.database;
    final data = await db.query(
      'cashier',
      where: 'cashier_name = ?',
      whereArgs: [cashierName],
    );

    if (data.isNotEmpty) {
      final e = data.first;
      return CashierData(
        cashierId: e['cashier_id'] as int,
        cashierName: e['cashier_name'] as String,
        cashierPhoneNumber: e['cashier_phone_number'] as int,
        cashierImage: e['cashier_image'] as String,
        cashierTotalTransaction: e['cashier_total_transaction'] as int,
        cashierTotalTransactionMoney:
            e['cashier_total_transaction_money'] as int,
        cashierPin: e['cashier_pin'] as int,
        selesai: e['selesai'] as int,
        proses: e['proses'] as int,
        pending: e['pending'] as int,
        batal: e['batal'] as int,
      );
    }
    return null;
  }

  Map<String, dynamic>? _cashierData;

  Map<String, dynamic>? get cashierData => _cashierData;

  Future<void> loadCashierDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cashierDataString = prefs.getString('cashierData');
    if (cashierDataString != null) {
      Map<String, dynamic> cashierDataMap = jsonDecode(cashierDataString);
      _cashierData = Map<String, dynamic>.from(cashierDataMap);
      print('Loaded cashierData: $_cashierData');
    } else {
      print('No cashierData found in SharedPreferences');
    }
    notifyListeners();
  }

  fetchAllCashiers() {}
}
