// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/providers/bluetoothProvider.dart';
import 'package:omzetin_bengkel/utils/modal_animation.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/page/settings/scanDevicePrinter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// void playBluetoothAlertSound() async {
//   final player = AudioPlayer();
//   await player.play(AssetSource('sounds/alert.mp3'));
// }

void showBluetoothAlert(BuildContext context) {
  // playBluetoothAlertSound();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, child) {
          if (bluetoothProvider.isConnected) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSuccessAlert(context, "Bluetooth Berhasil Terhubung");
            });
          }
          return Center(
            child: ModalAnimation(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                width: MediaQuery.of(context).size.width <= 400 ? 280 : 300,
                padding: const EdgeInsets.all(16.0),
                height: null,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/lottie/bluetooth-alert.json',
                          width: 150,
                          height: 150,
                        ),
                        Text(
                          'Bluetooth Tidak Terhubung',
                          style: GoogleFonts.poppins(
                            fontSize: MediaQuery.of(context).size.width <= 400
                                ? 14
                                : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text:
                                'Hubungkan ke perangkat Bluetooth atau atur di ',
                            style: GoogleFonts.poppins(
                              fontSize: MediaQuery.of(context).size.width <= 400
                                  ? 13
                                  : 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Halaman Scan Bluetooth',
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      MediaQuery.of(context).size.width <= 400
                                          ? 13
                                          : 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ScanDevicePrinter()),
                                    );
                                  },
                              ),
                              TextSpan(
                                text: '.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          "assets/images/close.png",
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void showBluetoothAlert2(BuildContext context) {
  // playBluetoothAlertSound();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, child) {
          if (bluetoothProvider.isConnected) {
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSuccessAlert(context, "Bluetooth Berhasil Terhubung");
            });
          }
          return Center(
            child: ModalAnimation(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                width: MediaQuery.of(context).size.width <= 400 ? 280 : 300,
                padding: const EdgeInsets.all(16.0),
                height: null,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/lottie/bluetooth-alert.json',
                          width: 150,
                          height: 150,
                        ),
                        Text(
                          'Bluetooth Tidak Terhubung',
                          style: GoogleFonts.poppins(
                            fontSize: MediaQuery.of(context).size.width <= 400
                                ? 14
                                : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text:
                                'Hubungkan ke perangkat Bluetooth atau atur di ',
                            style: GoogleFonts.poppins(
                              fontSize: MediaQuery.of(context).size.width <= 400
                                  ? 13
                                  : 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Halaman Scan Bluetooth',
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      MediaQuery.of(context).size.width <= 400
                                          ? 13
                                          : 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ScanDevicePrinter()),
                                    );
                                  },
                              ),
                              TextSpan(
                                text: '.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          "assets/images/close.png",
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
