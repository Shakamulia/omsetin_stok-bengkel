import 'package:flutter/material.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/null_data_alert.dart';
import 'package:omsetin_stok/view/widget/pin_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinModalChangePassword extends StatefulWidget {
  final Widget? destination;
  final Function? onTap;

  const PinModalChangePassword({
    super.key,
    this.destination,
    this.onTap,
  });

  @override
  State<PinModalChangePassword> createState() => _PinModalChangePasswordState();
}

class _PinModalChangePasswordState extends State<PinModalChangePassword> {
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
      title: Text(
        'Masukkan PIN Baru',
        style: TextStyle(color: Colors.black),
      ),
      content: PinInputWidget(controllers: pinControllers),
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

            if (pin != securityPassword.toString()) {
            } else {
              showNullDataAlert(context,
                  message: "Pin masih sama dengan yang sebelumnya!.");
            }
          },
          child: Text(
            'Ganti',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
