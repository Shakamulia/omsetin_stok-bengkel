import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:omzetin_bengkel/constants/apiConstants.dart';
import 'package:omzetin_bengkel/model/serialNumberPayload.dart';
import 'package:omzetin_bengkel/model/tokenPayload.dart';
import 'package:omzetin_bengkel/providers/userProvider.dart';
import 'package:omzetin_bengkel/utils/loadingAlert.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:provider/provider.dart';

class UserService {
  String _name = '';
  String _email = '';
  String _phoneNumber = '';

  // Getter untuk mendapatkan data user
  String get name => _name;
  String get email => _email;
  String get phoneNumber => _phoneNumber;

  // Method untuk mengubah nama
  void updateName(String newName) {
    _name = newName;
    debugPrint('Name updated to: $_name');
  }

  // Method untuk mengubah email
  void updateEmail(String newEmail) {
    _email = newEmail;
    debugPrint('Email updated to: $_email');
  }

  // Method untuk mengubah nomor telepon
  void updatePhoneNumber(String newPhoneNumber) {
    _phoneNumber = newPhoneNumber;
    debugPrint('Phone number updated to: $_phoneNumber');
  }

  final _storage = FlutterSecureStorage();
  Future<Map<String, dynamic>> getSerialNumberAsUserData(
      int serialNumber, String token) async {
    try {
      if (serialNumber == null) {
        throw Exception('Serial number is missing or invalid');
      }
      if (token.isEmpty) {
        throw Exception('Token not found');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/serial-number-bengkel/$serialNumber'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch serial number data');
      }
    } catch (err) {
      debugPrint('Error occurred: $err');
      throw Exception('Failed to fetch serial number data: $err');
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    final token = await _storage.read(key: 'token');
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await Dio().post(
      '${ApiConstants.baseUrl}/api/serial-number-bengkel',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final newImageUrl = response.data['data']['profileImage'];

    // simpan URL ke local storage / langsung pakai
  }

  Future<void> updateSerialNumberDetails(BuildContext context, String name,
      String email, String phoneNumber, File? image) async {
    try {
      showLoadingAlert(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // 1. Get token securely
      final token = await _storage.read(key: 'token');
      if (token == null) {
        Navigator.of(context, rootNavigator: true).pop();
        throw Exception('Token tidak ditemukan');
      }

      // 2. Decode token properly using jwt_decode
      final payload = Jwt.parseJwt(token);
      final serialNumberId = payload['sub']; // Sesuaikan dengan claim JWT Anda
      if (serialNumberId == null) {
        Navigator.of(context, rootNavigator: true).pop();
        throw Exception('ID Serial Number tidak valid');
      }

      debugPrint("Mengupdate serial number ID: $serialNumberId");

      // 3. Prepare form data
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: 'profile_$serialNumberId.${image.path.split('.').last}',
          ),
      });

      // 4. Validate image before upload
      if (image != null) {
        final imageSize = await image.length();
        const maxSize = 10 * 1024 * 1024; // 10MB
        if (imageSize > maxSize) {
          Navigator.of(context, rootNavigator: true).pop();
          showNullDataAlert(context,
              message: "Ukuran foto tidak boleh lebih dari 10MB");
          return;
        }
        debugPrint("Mengupload gambar: ${image.path}");
      }

      // 5. Send request
      final response = await Dio().post(
        '${ApiConstants.baseUrl}/api/serial-number-bengkel/$serialNumberId/update',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint("Response update: ${response.data}");

      // 6. Handle response
      if (response.statusCode == 200) {
        await userProvider.getSerialNumberAsUser(context);
        Navigator.of(context, rootNavigator: true).pop();
        showSuccessAlert(context, "Profil berhasil diupdate!");
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        showNullDataAlert(context,
            message: 'Gagal update: ${response.data['message']}');
      }
    } on DioException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      debugPrint('Dio Error: ${e.response?.data}');
      showNullDataAlert(context, message: 'Error jaringan: ${e.message}');
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      debugPrint('Unexpected Error: $e');
      showNullDataAlert(context, message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }
  // Future<void> updateSerialNumberDetails(
  //     context, String name, String email, String phoneNumber) async {
  //   try {
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);

  //     String? token = await _storage.read(key: 'token');
  //     if (token == null) {
  //       throw Exception('Token not found');
  //     }

  //     // Decode the token to extract the serial number
  //     final parts = token.split('.');
  //     if (parts.length != 3) {
  //       throw Exception('Invalid token format');
  //     }
  //     final payload = json
  //         .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  //     final serialNumberId = payload['serialNumberId'];
  //     if (serialNumberId == null || serialNumberId.isEmpty) {
  //       throw Exception('Serial number is missing or invalid');
  //     }

  //     print("serialnumber id: $serialNumberId");

  //     // Update the serial number details via the API
  //     final response = await http.put(
  //       Uri.parse(
  //           '${ApiConstants.baseUrl}/api/serial-number-bengkel/$serialNumberId/update'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'name': name,
  //         'email': email,
  //         'phoneNumber': phoneNumber,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       debugPrint('Serial number details updated successfully');
  //       await userProvider.getSerialNumberAsUser(context);
  //       showSuccessAlert(context, "Berhasil mengubah!");
  //     } else {
  //       debugPrint(
  //           'Failed to update serial number details: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     debugPrint('Error updating serial number details: $e');
  //   }
  // }

  // Di userService.dart tambahkan:
  static Future<String> getCurrentCashierName() async {
    final storage = FlutterSecureStorage();
    try {
      // Cek dari token atau storage
      final token = await storage.read(key: 'token');
      if (token != null) {
        final payload = Jwt.parseJwt(token);
        return payload['name'] ?? 'System'; // Ambil nama dari JWT
      }
      return 'System';
    } catch (e) {
      debugPrint('Error getting cashier name: $e');
      return 'System';
    }
  }

  Future<void> postSerialNumber(
      String name, String email, String phoneNumber) async {
    try {
      String? token = await _storage.read(key: 'token');
      print("JWT TOKEN:  ${token.toString()}");
      if (token == null) {
        throw Exception('Token not found');
      }

      // decode
      final parts = token.split('.');
      print("JWT TOKEN AFTER DECODE:  ${parts.toString()}");
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }
      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final extractedSerialNumber = payload['serialNumber'];
      print("Serial Number: ${extractedSerialNumber}");
      if (!extractedSerialNumber) {
        throw Exception('Serial number mismatch');
      }

      // Post the serial number to the API
      final response = await http.post(
          Uri.parse(
              'http://localhost:3000/api/serial-number-bengkel/$extractedSerialNumber'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: {
            name: name,
            email: email,
            phoneNumber: phoneNumber
          });

      if (response.statusCode == 200) {
        debugPrint('Serial number posted successfully');
      } else {
        debugPrint('Failed to post serial number: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error posting serial number: $e');
    }
  }
}
