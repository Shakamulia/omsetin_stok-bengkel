import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omzetin_bengkel/providers/bluetoothProvider.dart';
import 'package:omzetin_bengkel/services/authService.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/utils/toast.dart';
import 'package:omzetin_bengkel/view/page/home/home.dart';
import 'package:omzetin_bengkel/view/page/login.dart';
import 'package:omzetin_bengkel/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart'; // Import main.dart to access scaffoldMessengerKey

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  bool _isCheckingToken = false;
  bool _hasAttemptedReconnect =
      false; // Pelacak apakah sudah mencoba koneksi ulang
  bool _hasAttemptedCheck = false;
  bool _hasNavigated = false; // Pelacak apakah navigasi sudah dilakukan

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _requestPermissions();
        _checkTokenAndNavigate();
        // if (!_hasAttemptedReconnect) {
        //   _autoReconnectBluetooth();
        // }
      }
    });

    // _autoReconnectBluetooth();
    // _checkInternetConnection();
  }

  Future<void> _checkTokenAndNavigate() async {
    if (_isCheckingToken) return;
    _isCheckingToken = true;

    try {
      // Cek koneksi internet terlebih dahulu
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        // Tampilkan dialog error dan tidak lanjutkan
        _showNoInternetDialog();
        return;
      }

      final token = await _authService.getToken();

      if (token != null) {
        final isExpired = await _authService.isTokenExpired(context, token,
            autoLogout: false);
        if (!isExpired) {
          _navigateToHome();
          return;
        }
      }
      // Kalau token null atau expired, coba auto-login ulang pakai stored credential
      final serial = await _authService.storage.read(key: 'remember_serial');
      final pass = await _authService.storage.read(key: 'remember_pass');

      if (serial != null && pass != null) {
        try {
          await _authService.loginWithSerialNumber(context, serial, pass);
          _navigateToHome();
          return;
        } catch (e) {
          print('Auto-login gagal: $e');
          _navigateToLogin();
        }
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      print("Error checking token: $e");
      _navigateToLogin();
    } finally {
      _isCheckingToken = false;
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Tidak Ada Koneksi"),
        content: Text("Silahkan periksa koneksi internet Anda"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkTokenAndNavigate(); // Coba lagi
            },
            child: Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  // maintenance (belum beres)
  void _autoReconnectBluetooth() async {
    try {
      // Coba koneksi ulang ke Bluetooth
      final bluetoothProvider =
          Provider.of<BluetoothProvider>(context, listen: false);

      await bluetoothProvider.reconnectToDevice(context);

      if (bluetoothProvider.isConnected) {
        _hasAttemptedReconnect = true;
      } 
    } catch (e) {
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.storage,
    ].request();

    statuses.forEach((permission, status) {
      print('$permission: $status');
    });

    if (statuses.values.every((status) => status.isGranted)) {
      print("All permissions granted.");
    } else {
      print("Some permissions were denied.");
    }
  }

  void _navigateToLogin() {
    Future.delayed(Duration(seconds: 2), () {
      // Pastikan widget masih terpasang
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  void _navigateToHome() {
    Future.delayed(Duration(seconds: 2), () {
      // Pastikan widget masih terpasang
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No Internet Connection');
        connectionToast(
          context,
          "Koneksi Gagal!",
          "Anda tidak terhubung ke jaringan.",
          isConnected: false,
        );
        return false;
      }

      // Periksa koneksi internet aktual
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 3));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        // connectionToast(
        //   context,
        //   "Koneksi Gagal!",
        //   "Tidak ada koneksi internet",
        //   isConnected: false,
        // );
        // return false;
      }

      // print('Internet Connected');
      // connectionToast(
      //   context,
      //   "Koneksi Berhasil!",
      //   "Anda telah berhasil terhubung ke jaringan.",
      //   isConnected: true,
      // );
      return true;
    } catch (e) {
      // print('Error checking connection: $e');
      connectionToast(
        context,
        "Koneksi Gagal!",
        "Tidak ada koneksi internet",
        isConnected: false,
      );
      return false;
    }
  }
  // void startTokenCheck(BuildContext context) {
  //   final authService = AuthService();
  //   Timer.periodic(Duration(seconds: 1), (timer) async {
  //     final token = await authService.getToken();
  //     if (token == null || authService.isTokenExpired(token)) {
  //       timer.cancel(); // Stop the timer if the token is expired
  //       await authService.logout(context);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
            opacity: 0.20,
          ),
          gradient: LinearGradient(
            colors: [
const Color(0xFF0747AE), // navy gelap (atas)
const Color(0xFF91CEFF), // navy terang (tengah)
const Color(0xFF0747AE), // navy gelap (bawah)


            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Center(
          child: Stack(
            children: [
              // Positioned.fill(
              //   child: Image.asset(
              //     'assets/images/bg_splash.png',
              //     fit: BoxFit.cover,
              //     opacity: const AlwaysStoppedAnimation(0.2),
              //   ),
              // ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/oms.gif',
                      width: 210,
                      height: 210,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
