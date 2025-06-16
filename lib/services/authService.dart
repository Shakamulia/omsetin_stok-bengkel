import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:omsetin_stok/constants/apiConstants.dart';
import 'package:omsetin_stok/providers/userProvider.dart';
import 'package:omsetin_stok/utils/null_data_alert.dart';
import 'package:omsetin_stok/utils/toast.dart';
import 'package:omsetin_stok/view/page/login.dart';
import 'package:omsetin_stok/view/page/splash_screen.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final storage = FlutterSecureStorage();
  final api = ApiConstants.baseUrl;
  final secure = FlutterSecureStorage();

  Future<bool> isTokenExpired(BuildContext context, String token,
      {bool autoLogout = true}) async {
    try {
      final tokenParts = token.split('.');
      if (tokenParts.length != 3) {
        return true;
      }

      final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(tokenParts[1]))));
      final exp = payload['exp'] as int?;

      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      return now.isAfter(expiryDate);
    } catch (e) {
      debugPrint('Error checking token expiration: $e');
      return true;
    }
  }

// Tambahkan di authService.dart
Future<String> getCurrentUsername() async {
  try {
    final token = await storage.read(key: 'token');
    if (token == null) return 'System';

    final tokenParts = token.split('.');
    if (tokenParts.length != 3) return 'System';

    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(tokenParts[1]))));
    
    // Cek beberapa kemungkinan field yang mungkin berisi username
    return payload['name'] ?? 
           payload['username'] ?? 
           payload['serialNumber'] ?? 
           'System';
  } catch (e) {
    debugPrint('Error getting username: $e');
    return 'System';
  }
}

  Future<void> logout(BuildContext context) async {
    try {
      final token = await storage.read(key: 'token');
      await storage.delete(key: 'token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('$api/api/serial-number/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(Duration(seconds: 5));

        if (response.statusCode != 200) {
          print('Logout failed with status ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SplashScreen()),
        (route) => false,
      );
    }
  }

  Future<void> loginWithSerialNumber(
      BuildContext context, String serialNumber, String password) async {
    try {
      // Validate inputs
      final response = await http.post(
        Uri.parse('$api/api/serial-number/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'serialNumber': serialNumber, 'password': password}),
      );

      if (response.statusCode == 200) {
        print("Fetched from $api");
        final data = jsonDecode(response.body);
         final token = data['token'];

        await storage.write(key: 'token', value: token);

            // Debug log
      final username = await getCurrentUsername();
      debugPrint('Login berhasil. Username: $username');

        await secure.write(key: 'remember_serial', value: serialNumber);
        await secure.write(key: 'remember_pass', value: password);

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchAndDecodeToken();
        await userProvider.getSerialNumberAsUser(context);



        final tokenParts = data['token'].split('.');
        if (tokenParts.length == 3) {
          final payload = jsonDecode(utf8
              .decode(base64Url.decode(base64Url.normalize(tokenParts[1]))));
          print('Token payload: $payload');
        } else {
          throw Exception('Invalid token format');
        }

        print('Login successful with token: ${data['token']}');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to login with serial number');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }
}
