import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:omzetin_bengkel/providers/bluetoothProvider.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/printer_helper.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/page/home/home.dart';
import 'package:omzetin_bengkel/view/page/print_resi/select_expedition.dart';
import 'package:omzetin_bengkel/view/page/qr_code_scanner.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:provider/provider.dart';

class InputResi extends StatefulWidget {
  const InputResi({super.key});

  @override
  State<InputResi> createState() => _InputResiState();
}

class _InputResiState extends State<InputResi> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController _expeditionController = TextEditingController();
  final TextEditingController _expeditionBarcodeController =
      TextEditingController();

  void _checkBarcodeInput() {
    setState(() {});
  }

  Future<void> scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrCodeScanner()),
    );

    if (result != null && mounted) {
      setState(() {
        _expeditionBarcodeController.text = result;
        _checkBarcodeInput();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor, // Warna akhir gradient
                  primaryColor, // Warna awal gradient
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              leading: const CustomBackButton(),
              backgroundColor: Colors.transparent,
              title: Text(
                'CETAK RESI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                children: [
                  const TextFieldLabel(label: 'Nama Pembeli'),
                  CustomTextField(
                    fillColor: cardColor,
                    obscureText: false,
                    hintText: "Nama Pembeli",
                    controller: nameController,
                    maxLines: null,
                    prefixIcon: null,
                    suffixIcon: null,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  const Gap(10),
                  const TextFieldLabel(label: 'Ekspedisi'),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedCategory =
                          await Navigator.of(context).push<String>(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SelectExpedition(),
                            );
                          },
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                        ),
                      );

                      if (selectedCategory != null) {
                        setState(() {
                          _expeditionController.text = selectedCategory;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: cardColor,
                      foregroundColor: Colors.grey[800],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      minimumSize: const Size(0, 55),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _expeditionController.text.isEmpty
                              ? "Pilih Ekspedisi"
                              : _expeditionController.text,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),
                  const TextFieldLabel(label: 'Nomor Resi'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            _checkBarcodeInput();
                          },
                          controller: _expeditionBarcodeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: cardColor,
                            hintText: "Barcode",
                            hintStyle: const TextStyle(fontSize: 17),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28.0),
                              borderSide: const BorderSide(color: primaryColor),
                            ),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: scanQRCode,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(14),
                            backgroundColor: primaryColor,
                            // minimumSize: const Size(30, 30),
                          ),
                          child: const Icon(
                            Icons.barcode_reader,
                            color: Colors.white,
                          )),
                    ],
                  ),
                  const Gap(10),
                  const TextFieldLabel(label: 'Keterangan'),
                  CustomTextField(
                    fillColor: cardColor,
                    obscureText: false,
                    hintText: "Keterangan",
                    controller: noteController,
                    maxLines: 5,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: null,
                    suffixIcon: null,
                  ),
                ],
              ),
            ),
            ExpensiveFloatingButton(
              text: "CETAK RESI",
              onPressed: () async {
                if (_expeditionController.text.isEmpty) {
                  showNullDataAlert(context,
                      message: "Pilih Ekspedisi terlebih dahulu");
                  return;
                }

                if (bluetoothProvider.connectedDevice != null) {
                  PrinterHelper.printResi(bluetoothProvider.connectedDevice!,
                      expedition: _expeditionController.text,
                      receipt: _expeditionBarcodeController.text,
                      buyerName: nameController.text,
                      explanation: noteController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No connected device found')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      // floatingActionButton: ExpensiveFloatingButton(
      //   text: "CETAK RESI",
      //   onPressed: () async {
      //     if (_expeditionController.text.isEmpty) {
      //       showNullDataAlert(context,
      //           message: "Pilih Ekspedisi terlebih dahulu");
      //       return;
      //     }

      //     if (bluetoothProvider.connectedDevice != null) {
      //       PrinterHelper.printResi(
      //           bluetoothProvider.connectedDevice!,
      //           expedition: _expeditionController.text,
      //           receipt: _expeditionBarcodeController.text,
      //           buyerName: nameController.text,
      //           explanation: noteController.text);
      //     } else {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //             content: Text('No connected device found')),
      //       );
      //     }
      //   },
      // ),
    );
  }
}

class TextFieldLabel extends StatelessWidget {
  final String label;

  const TextFieldLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
