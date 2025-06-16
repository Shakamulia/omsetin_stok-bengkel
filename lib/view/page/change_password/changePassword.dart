import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Tambahkan ini
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:omsetin_stok/constants/apiConstants.dart';
import 'package:omsetin_stok/providers/userProvider.dart';
import 'package:omsetin_stok/utils/checkConnection.dart';
import 'dart:convert'; // Untuk JSON encoding/decoding
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/null_data_alert.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/utils/successAlert.dart';
import 'package:omsetin_stok/utils/toast.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/custom_textfield.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ChangepasswordPage extends StatefulWidget {
  const ChangepasswordPage({super.key});

  @override
  State<ChangepasswordPage> createState() => _ChangepasswordPageState();
}

class _ChangepasswordPageState extends State<ChangepasswordPage> {
  final storage = FlutterSecureStorage();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  void clearForm() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _changePassword(String serialNumberId) async {
    setState(() {
      _isLoading = true;
    });

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validasi password baru
    if (newPassword != confirmPassword) {
      showNullDataAlert(context,
          message: "Password baru dan konfirmasi password tidak cocok.");
      setState(() {
        _isLoading = false;
      });

      return;
    }
    if (newPassword.length < 8) {
      showNullDataAlert(context,
          message: "Password baru harus memiliki minimal 8 karakter.");
      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/serial-number/$serialNumberId/change-password'),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: "token") ?? ""}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      final userProvider = UserProvider();

      userProvider.getSerialNumberAsUser(context);

      if (response.statusCode == 200) {
        showSuccessAlert(context, "Password berhasil diubah.");
        clearForm();
        setState(() {
          _isLoading = false;
        });
      } else {
        final responseBody = jsonDecode(response.body);
        showNullDataAlert(context,
            message: responseBody['message'] ?? "Terjadi kesalahan.");
        setState(() {
          _isLoading = false;
        });
      }
    } on SocketException {
      connectionToast(
          context, "Koneksi Gagal!", "Anda tidak terhubung ke jaringan.",
          isConnected: false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
       appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20), // Tambah tinggi AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
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
                    title: Text(
            'GANTI PASSWORD',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: SizeHelper.Fsize_normalTitle(context), // Perbesar font
              color: bgColor,
            ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    leading: CustomBackButton(),
                    elevation: 0,
                    toolbarHeight: kToolbarHeight + 20, // Tambah tinggi toolbar
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom:
                            100, // Tambahkan padding bawah agar tidak ketutup tombol
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(20),
                              Center(
                                child: ClipRRect(
                                  child: Image.asset(
                                    'assets/images/logo-key2.png',
                                    width: 152,
                                    height: 152,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Gap(20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Password Lama",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              CustomTextField(
                                fillColor: Colors.grey[200],
                                hintText: "Masukan Password Lama",
                                suffixIcon: null,
                                obscureText: true,
                                prefixIcon: const Icon(Icons.lock_person),
                                controller: _oldPasswordController,
                                maxLines: 1,
                              ),
                              Gap(20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Password Baru",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              CustomTextField(
                                fillColor: Colors.grey[200],
                                hintText: "Masukan Password Baru",
                                suffixIcon: IconButton(
                                  icon: _isNewPasswordObscured
                                      ? const Iconify(Ic.twotone_visibility)
                                      : Iconify(Ic.twotone_visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _isNewPasswordObscured =
                                          !_isNewPasswordObscured;
                                    });
                                  },
                                ),
                                obscureText: _isNewPasswordObscured,
                                prefixIcon: const Icon(Icons.lock_person),
                                controller: _newPasswordController,
                                maxLines: 1,
                              ),
                              Gap(20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Konfirmasi Password Baru",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              CustomTextField(
                                fillColor: Colors.grey[200],
                                hintText: "Konfirmasi Password Baru",
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordObscured =
                                            !_isConfirmPasswordObscured;
                                      });
                                    },
                                    icon: _isConfirmPasswordObscured
                                        ? const Iconify(Ic.twotone_visibility)
                                        : Iconify(Ic.twotone_visibility_off)),
                                obscureText: _isConfirmPasswordObscured,
                                prefixIcon: const Icon(Icons.lock_person),
                                controller: _confirmPasswordController,
                                maxLines: 1,
                              ),
                              Gap(20),
                              Expanded(
                                  child:
                                      Container()), // Biar tombol tetap di bawah
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ExpensiveFloatingButton(
                    left: 12,
                    right: 12,
                    child: _isLoading == true
                        ? Lottie.asset(
                            'assets/lottie/loading-2.json',
                            width: 100,
                            height: 100,
                          )
                        : Text(
                            "SIMPAN",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                fontSize:
                                    SizeHelper.Fsize_expensiveFloatingButton(
                                        context)),
                          ),
                    onPressed: () async {
                      _changePassword(userProvider.serialNumberData?.id ?? '');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
