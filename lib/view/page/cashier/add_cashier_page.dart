import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/cashierImageProfile.dart';
import 'package:omzetin_bengkel/providers/cashierProvider.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
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

class AddCashierPage extends StatefulWidget {
  AddCashierPage({super.key});

  @override
  _AddCashierPageState createState() => _AddCashierPageState();
}

class _AddCashierPageState extends State<AddCashierPage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> pinController = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String image = "assets/products/no-image.png";

  Future<void> _saveCashier() async {
    String name = nameController.text;
    String phone = phoneController.text;

    if (phone.length > 15) {
      showNullDataAlert(context,
          message: 'Nomor handphone tidak boleh lebih dari 18 digit');
      return;
    }

    String pin = pinController.map((controller) => controller.text).join();

    print("pin string: $pin");

    int pinInt = int.tryParse(pin) ?? 0;

    if (name.isEmpty || phone.isEmpty || image == null) {
      showNullDataAlert(context, message: 'Semua field harus diisi');
      return;
    }

    if (pinInt.toString().length != 6) {
      print(pinInt);
      showNullDataAlert(context, message: 'PIN harus terdiri dari 6 digit');
      return;
    }

    for (var controller in pinController) {
      if (controller.text.isEmpty) {
        showNullDataAlert(context, message: 'Semua field PIN harus diisi');
        return;
      }
    }

    Map<String, dynamic> cashierData = {
      'cashier_name': name,
      'cashier_phone_number': phone,
      'cashier_image': image,
      'cashier_total_transaction': 0,
      'cashier_total_transaction_money': 0,
      'cashier_pin': pinInt,
      'cashier_selesai': 0,
      'cashier_proses': 0,
      'cashier_pending': 0,
      'cashier_batal': 0,
    };

    try {
      final result = await _databaseService.insertCashier(cashierData);

      var cashierProvider =
          Provider.of<CashierProvider>(context, listen: false);

      // refresh
      cashierProvider.getCashiers();

      print(cashierData);
      showSuccessAlert(context, 'Kasir berhasil ditambahkan');
    } catch (e, stackTrace) {
      print('Error: ${e.toString().replaceFirst('Exception: ', '')}');
      print('StackTrace: $stackTrace');
      showNullDataAlert(context,
          message: '${e.toString().replaceFirst('Exception: ', '')}');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CashierPage()),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void _selectProfileImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Profil',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeHelper.Fsize_normalTitle(context),
                fontWeight: FontWeight.bold,
              )),
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
    var scaffold = Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
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
                'TAMBAH KASIR',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Atur ke transparan
              leading: CustomBackButton(),
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
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
                                    image: image != "assets/products/no-image"
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                  controller: nameController,
                                  hintStyle: TextStyle(
                                      fontSize: 17, color: Colors.grey[400]),
                                  maxLines: 1,
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
                                      fontSize: 17, color: Colors.grey[400]),
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
                                  autoFocus: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ExpensiveFloatingButton(
                  left: 12, right: 12, onPressed: _saveCashier)
            ],
          ),
        ),
      ),
    );
    return scaffold;
  }
}
