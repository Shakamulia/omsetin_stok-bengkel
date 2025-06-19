import 'package:flutter/material.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/null_data_alert.dart';
import 'package:omsetin_bengkel/view/widget/pin_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinModal extends StatefulWidget {
  final Widget? destination;
  final Function? onTap;

  const PinModal({
    super.key,
    this.destination,
    this.onTap,
  });

  @override
  State<PinModal> createState() => _PinModalState();
}

class _PinModalState extends State<PinModal> {
  List<TextEditingController> pinControllers =
      List.generate(6, (index) => TextEditingController());

  int? securityPassword;

  @override
  void initState() {
    super.initState();
    _loadSecurityPassword();
  }

  void _loadSecurityPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    securityPassword = prefs.getInt('securityPassword') ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        'Masukkan PIN',
        style: TextStyle(color: Colors.black),
      ),
      content: SizedBox(
        width: double.maxFinite, // penting agar content bisa melar
        child: PinInputWidget(controllers: pinControllers),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            elevation: 0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            elevation: 0,
          ),
          onPressed: () {
            String pin =
                pinControllers.map((controller) => controller.text).join();

            if (pin == securityPassword.toString()) {
              if (widget.onTap != null) {
                print("PIN benar, memanggil onTap");
                widget.onTap!();
              } else if (widget.destination != null) {
                print("Navigasi ke halaman tujuan");
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => widget.destination!,
                  ),
                );
              } else {
                print("PIN benar, menutup modal");
                Navigator.pop(context);
              }
            } else {
              print("PIN salah");
              showNullDataAlert(context,
                  message: "Pin Salah, Silahkan coba kembali.");
            }
          },
          // onPressed: () {
          //   String pin =
          //       pinControllers.map((controller) => controller.text).join();

          //   if (widget.onTap == null) {
          //     if (pin == securityPassword.toString()) {
          //       if (widget.destination == null) {
          //         if (widget.onTap == null) {
          //           Navigator.pop(context);
          //         }
          //       } else {
          //         Navigator.pop(context);
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (_) => widget.destination ?? Text('')));
          //       }
          //     } else {
          //       showNullDataAlert(context,
          //           message: "Pin Salah, Silahkan coba kembali.");
          //     }
          //   } else {
          //     if (pin == securityPassword.toString() &&
          //         widget.destination == null) {
          //       print("berhasil masuk");
          //       widget.onTap;
          //     } else {
          //       showNullDataAlert(context,
          //           message: "Pin Salah, Silahkan coba kembali.");
          //     }
          //   }
          // },
          child: Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
