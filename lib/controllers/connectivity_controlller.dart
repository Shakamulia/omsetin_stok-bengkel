import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:omzetin_bengkel/utils/colors.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  late final StreamSubscription _streamSubscription;

  var _isConnected = true.obs;

  bool _isDialogOpen = false;

  bool _isOnline = false;

  @override
  void onInit() {
    super.onInit();
    _checkInternetConnectivity();

    _streamSubscription =
        _connectivity.onConnectivityChanged.listen((connections) async {
      if (connections.contains(ConnectivityResult.none)) {
        _handleConnectionChange([ConnectivityResult.none]);
      } else {
        final isOnline = await _hasInternetAccess();
        if (!isOnline) {
          _handleConnectionChange([ConnectivityResult.none]);
        } else {
          _handleConnectionChange(connections);
        }
      }
    });
  }

  //cek status internet
  Future<void> _checkInternetConnectivity() async {
    List<ConnectivityResult> connections =
        await _connectivity.checkConnectivity();

    if (connections.contains(ConnectivityResult.none)) {
      _handleConnectionChange(connections);
    } else {
      // Cek apakah benar-benar bisa akses internet
      final isOnline = await _hasInternetAccess();
      if (!isOnline) {
        _handleConnectionChange([ConnectivityResult.none]); // Anggap offline
      } else {
        _handleConnectionChange(connections);
      }
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _handleConnectionChange(List<ConnectivityResult> connections) {
    if (connections.contains(ConnectivityResult.none)) {
      _isConnected.value = false;
      _isOnline = false;
      //no internet dialog
      _showNoInternetDialog();
    } else {
      _isConnected.value = true;
      _closeDialog();

      if (_isOnline) {
        Get.snackbar('Online', 'Kamu Terhubung ke Internet',
            colorText: Colors.green[300],
            backgroundColor: Colors.green[50],
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void _showNoInternetDialog() {
    if (_isDialogOpen) return; // Prevent multiple dialogs
    _isDialogOpen = true;
    _isOnline = false;
    Get.dialog(
      AlertDialog(
        title: Text("Offline"),
        content: Text(
            "Kamu Tidak Terhubung ke Internet. Silakan periksa koneksi internet kamu."),
        actions: [
          SizedBox(
            height: 40,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => {
                _retryConnection(),
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text("Coba Lagi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          )
        ],
      ),
      barrierDismissible: false,
    ).then((_) {
      _isDialogOpen = false;
    });
  }

  Future<void> _retryConnection() async {
    List<ConnectivityResult> connections =
        await _connectivity.checkConnectivity();

    if (!connections.contains(ConnectivityResult.none)) {
      _isConnected.value = true;
      Get.back();
    } else {
      Get.snackbar('Offline', 'Periksa Koneksi dan Coba Lagi',
          colorText: Colors.red[300],
          backgroundColor: Colors.red[50],
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _closeDialog() {
    if (_isDialogOpen) {
      Get.back();
      _isDialogOpen = false;
    }
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    _closeDialog();
    super.onClose();
  }
}
