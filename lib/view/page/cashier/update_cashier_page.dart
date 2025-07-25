import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/cashier.dart';
import 'package:omzetin_bengkel/model/cashierImageProfile.dart';
import 'package:omzetin_bengkel/providers/cashierProvider.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/page/cashier/cashier_page.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/pin_input.dart';
import 'package:provider/provider.dart';

class UpdateCashierPage extends StatefulWidget {
  final CashierData cashier;

  UpdateCashierPage({super.key, required this.cashier});

  @override
  _UpdateCashierPageState createState() => _UpdateCashierPageState();
}

class _UpdateCashierPageState extends State<UpdateCashierPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late String onlyShow;
  late List<TextEditingController> pinController;

  String image = "assets/products/no-image.png";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: widget.cashier.cashierName != "Owner"
            ? widget.cashier.cashierName
            : "${widget.cashier.cashierName} (Tidak dapat diubah)");
    phoneController = TextEditingController(
        text: widget.cashier.cashierPhoneNumber.toString());
    pinController = widget.cashier.cashierPin
        .toString()
        .split('')
        .map((e) => TextEditingController(text: e))
        .toList();
    image = widget.cashier.cashierImage;
  }

  Future<void> _updateCashier() async {
    String name = nameController.text;
    String phone = phoneController.text;
    int phoneInt = int.tryParse(phone) ?? 0;

    if (phone.length > 15) {
      showNullDataAlert(context,
          message: 'Nomor handphone tidak boleh lebih dari 18 digit');
      return;
    }

    String pin = pinController.map((controller) => controller.text).join();

    int pinInt = int.tryParse(pin) ?? 0;

    if (name.isEmpty || phone.isEmpty || image == null) {
      showNullDataAlert(context, message: 'Semua field harus diisi');
      return;
    }

    if (pinInt.toString().length != 6) {
      showNullDataAlert(context, message: 'PIN harus terdiri dari 6 digit');
      return;
    }

    for (var controller in pinController) {
      if (controller.text.isEmpty) {
        showNullDataAlert(context, message: 'Semua field PIN harus diisi');
        return;
      }
    }

    CashierData updatedCashier = CashierData(
      cashierId: widget.cashier.cashierId,
      cashierName: name,
      cashierPhoneNumber: phoneInt,
      cashierImage: image,
      cashierPin: pinInt,
    );

    try {
      var cashierProvider =
          Provider.of<CashierProvider>(context, listen: false);
      await cashierProvider.updateCashier(updatedCashier);

      showSuccessAlert(context, 'Kasir berhasil diperbarui');
    } catch (e) {
      showNullDataAlert(context, message: 'Gagal memperbarui kasir: $e');
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CashierPage()),
    );
  }

  void _selectProfileImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Gambar Profil',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white)),
          backgroundColor: primaryColor,
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              alignment: WrapAlignment.center,
              runSpacing: 8.0,
              children: cashierImage.map((profile) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      image = profile.imageUrl;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(profile.imageUrl),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + 20), // Tambah tinggi AppBar
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
                'PERBARUI KASIR',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      SizeHelper.Fsize_normalTitle(context), // Perbesar font
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              leading: CustomBackButton(),
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20, // Tambah tinggi toolbar
            ),
          ),
        ),
      ),
    body: SafeArea(
  child: Stack(
    children: [
      Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _selectProfileImage(context),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              image: image !=
                                      "assets/products/no-image"
                                  ? DecorationImage(
                                      image: AssetImage(image),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: AssetImage(
                                          'assets/products/no-image.png'),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(15),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Text(
                                "Nama Kasir",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          CustomTextField(
                            obscureText: false,
                            fillColor: Colors.grey[200],
                            hintText: "Masukkan Nama Kasir",
                            prefixIcon: null,
                            hintStyle: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[400]),
                            controller: nameController,
                            maxLines: 1,
                            enabled: widget.cashier.cashierName !=
                                'Owner',
                            suffixIcon: null,
                          ),
                          Gap(15),
                          Row(
                            children: const [
                              Text(
                                "Nomor Handphone",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          CustomTextField(
                            obscureText: false,
                            fillColor: Colors.grey[200],
                            hintText: "Masukkan Nomor Handphone",
                            prefixIcon: null,
                            controller: phoneController,
                            hintStyle: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[400]),
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            suffixIcon: null,
                          ),
                          Gap(15),
                          Row(
                            children: const [
                              Text(
                                "PIN",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          PinInputWidget(
                            controllers: pinController,
                          ),
                          SizedBox(height: 100), // Memberikan ruang untuk floating button
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ExpensiveFloatingButton(
          left: 12, right: 12, onPressed: _updateCashier)
    ],
  ),
),
    );
  }
}
