import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:omsetin_stok/constants/apiConstants.dart';
import 'package:omsetin_stok/model/serialNumberPayload.dart';
import 'package:omsetin_stok/model/tokenPayload.dart';
import 'package:omsetin_stok/services/authService.dart';
import 'package:omsetin_stok/services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  final UserService _userService = UserService();

  TokenPayload? _payload;
  TokenPayload? get payload => _payload;

  set payload(TokenPayload? value) {
    _payload = value;
    notifyListeners();
  }

  SerialNumberPayload? _serialNumberData;
  SerialNumberPayload? get serialNumberData => _serialNumberData;

  set serialNumberData(SerialNumberPayload? value) {
    _serialNumberData = value;
    notifyListeners();
  }

  static const String _baseImageUrl = ApiConstants.baseUrl;

  String getProfileImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Atau return URL gambar default
    }

    // Jika sudah URL lengkap
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Handle path yang mungkin sudah ada slash atau belum
    return '$_baseImageUrl${imagePath.startsWith('/') ? '' : '/'}$imagePath';
  }

  Future<void> fetchAndDecodeToken() async {
    final token = await AuthService().getToken();
    if (token == null) return;
    try {
  

      String? token = await _storage.read(key: "token");
      if (token != null && token.isNotEmpty) {
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        this.payload = TokenPayload.fromJson(payload);
      } else {
        debugPrint("Token is empty or not found");
      }
    } catch (e) {
      debugPrint("Error decoding token: $e");
      rethrow;
    }
  }

  Future<void> getSerialNumberAsUser(BuildContext context) async {
    try {
      // Ensure we have the latest token and payload
      await fetchAndDecodeToken();

      final prefs = await SharedPreferences.getInstance();
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      // Get token and serial number
      String? token = await _storage.read(key: 'token');
      int? serialNumber = _payload?.serialNumberId;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      if (serialNumber == null) {
        throw Exception('Serial number not available in token');
      }

      if (isOnline) {
        try {
          // Call service directly with required parameters
          final data =
              await _userService.getSerialNumberAsUserData(serialNumber, token);

          this.serialNumberData = SerialNumberPayload.fromJson(data);
          await prefs.setString('serialNumberData', jsonEncode(data));
          debugPrint("Successfully fetched from API: $serialNumberData");
        } catch (e) {
          debugPrint("Online fetch failed, trying cache: $e");
          final cachedData = prefs.getString('serialNumberData');
          if (cachedData != null) {
            this.serialNumberData =
                SerialNumberPayload.fromJson(jsonDecode(cachedData));
            debugPrint("Loaded from cache: $serialNumberData");
          }
          rethrow;
        }
      } else {
        debugPrint("Device is offline");
        final cachedData = prefs.getString('serialNumberData');
        if (cachedData != null) {
          this.serialNumberData =
              SerialNumberPayload.fromJson(jsonDecode(cachedData));
          debugPrint("Loaded from cache: $serialNumberData");
        } else {
          throw Exception(
              'No internet connection and no cached data available');
        }
      }
    } catch (e) {
      debugPrint("Error in getSerialNumberAsUser: $e");
      rethrow;
    }
  }
}
