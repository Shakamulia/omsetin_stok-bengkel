import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:omsetin_stok/utils/toast.dart';

class BluetoothProvider with ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? _connectingDevice;
  void setConnectingDevice(BluetoothDevice device) {
    _connectingDevice = device;
    notifyListeners();
  }

  bool _isConnected = false;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothDevice? get connectingDevice => _connectingDevice;
  bool get isConnected => _isConnected;

  /// Menghubungkan ke perangkat
  Future<void> connectToDevice(BluetoothDevice device, context) async {
    try {
      _connectingDevice = device;
      notifyListeners();

      await FlutterBluePlus.stopScan();
      await device.disconnect();
      await Future.delayed(Duration(milliseconds: 500));
      await device.connect(autoConnect: false, timeout: Duration(seconds: 5));
      await device.requestMtu(512);
      await device.discoverServices();

      _connectedDevice = device;
      _isConnected = true;
      bluetoothToast(
        context,
        "Koneksi Bluetooth Berhasil!",
        "Berhasil terhubung ke perangkat Bluetooth.",
        isConnected: true,
      );
      _connectingDevice = null;
      notifyListeners();
    } catch (e) {
      final name = device.name.toLowerCase();
      if (!name.contains("printer") &&
          !name.contains("pos") &&
          !name.contains("bt")) {
        bluetoothToast(
          context,
          "Perangkat Tidak Didukung",
          "Gagal terhubung. Perangkat ini bukan printer BLE yang valid.",
          isConnected: false,
        );
      } else {
        bluetoothToast(
          context,
          "Koneksi Bluetooth Gagal!",
          "Tidak dapat terhubung ke perangkat Bluetooth.",
          isConnected: false,
        );
      }

      print("Gagal terhubung: $e");

      _connectingDevice = null;
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Memutuskan koneksi
  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Menghubungkan ulang ke perangkat yang sebelumnya terhubung
  Future<void> reconnectToDevice(context) async {
    if (_connectedDevice != null) {
      try {
        notifyListeners();
        await _connectedDevice!.connect();
        _isConnected = true;

        bluetoothToast(
          context,
          "Koneksi Bluetooth Berhasil!",
          "Berhasil menghubungkan ulang.",
          isConnected: true,
        );
        notifyListeners();
      } catch (e) {
        print("Gagal menghubungkan ulang: $e");
        bluetoothToast(
          context,
          "Koneksi Bluetooth Gagal!",
          "Gagal menghubungkan ulang.",
          isConnected: false,
        );
        notifyListeners();
      }
    } else {
      _isConnected = false;
      bluetoothToast(
        context,
        "Koneksi Bluetooth Gagal!",
        "Tidak dapat terhubung ke perangkat Bluetooth.",
        isConnected: false,
      );
      print("Tidak ada perangkat yang sebelumnya terhubung.");
    }
  }
}
