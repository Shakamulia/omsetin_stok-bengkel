import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isScanned = false;
  bool isFlashOn = false;
  bool isPauseOn = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isScanned) {
        setState(() {
          result = scanData;
          isScanned = true;
        });
        if (mounted) {
          Navigator.pop(context, scanData.code);
        }
      }
    });
  }

  void _toggleFlash() {
    if (controller != null) {
      controller!.toggleFlash();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    }
  }

  void _togglePause() {
    if (controller != null) {
      if (isPauseOn) {
        controller!.resumeCamera();
      } else {
        controller!.pauseCamera();
      }
      setState(() {
        isPauseOn = !isPauseOn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;

    return Scaffold(
      backgroundColor: bgColor,
          appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20)
          ),
          child: Container(
                      decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor,
                  primaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              )
            ),
            child: AppBar(
              title: Text(
                "SCAN QR CODE",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              toolbarHeight: kToolbarHeight + 20,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(), // Custom back button
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: primaryColor,
              borderRadius: 16,
              borderLength: 30,
              borderWidth: 6,
              cutOutSize: scanAreaSize,
              overlayColor: Colors.black.withOpacity(0.5),
            ),
          ),
          // FLASH & PAUSE BUTTONS
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${result!.format.toString().split('.').last}   Data: ${result!.code}')
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          icon: Iconify(
                            isFlashOn ? Mdi.flashlight : Mdi.flashlight_off,
                            size: 20,
                          ),
                          onPressed: _toggleFlash,
                          color: const Color.fromARGB(255, 14, 94, 134),
                          iconSize: 50,
                        ),
                        IconButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          icon: Iconify(
                            isPauseOn ? Mdi.play : Mdi.pause,
                            size: 20,
                          ),
                          onPressed: _togglePause,
                          color: const Color.fromARGB(255, 14, 94, 134),
                          iconSize: 50,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
