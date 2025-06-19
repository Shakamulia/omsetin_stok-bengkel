import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_bengkel/model/services.dart';
import 'package:omsetin_bengkel/services/service_db_helper.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/formatters.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omsetin_bengkel/utils/successAlert.dart';
import 'package:omsetin_bengkel/utils/failedAlert.dart';
import 'package:omsetin_bengkel/utils/null_data_alert.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final ServiceDatabaseHelper _serviceHelper = ServiceDatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _createNewService() async {
    final serviceName = _nameController.text;
    final servicePrice = _priceController.text;

    if (serviceName.isEmpty || servicePrice.isEmpty) {
      showNullDataAlert(context, message: "Semua field harus diisi!");
      return;
    }

    try {
      await _serviceHelper.createService(Service(
        serviceId: 0, // Dummy value, will be replaced by DB auto-increment
        serviceName: serviceName,
        servicePrice: int.parse(servicePrice.replaceAll('.', '')),
        dateAdded: DateTime.now().toIso8601String(),
      ));

      showSuccessAlert(context, "Layanan berhasil ditambahkan!");
      Navigator.pop(context, true);
    } catch (e) {
      showFailedAlert(context, message: "Gagal menambahkan layanan: $e");
    }
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga harus diisi';
    }
    if (double.tryParse(value.replaceAll('.', '')) == null) {
      return 'Harga tidak valid';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [secondaryColor, primaryColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: AppBar(
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              leading: const CustomBackButton(),
              title: Text(
                'TAMBAH LAYANAN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: bgColor,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nama Layanan",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _nameController,
              hintText: "Contoh: Service AC, Ganti Oli",
              obscureText: false,
              prefixIcon: const Icon(Icons.build),
              maxLines: 1,
              suffixIcon: null,
            ),
            const SizedBox(height: 15),
            const Text(
              "Harga Layanan",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            // CustomTextField(
            //   fillColor: cardColor,
            //   controller: _priceController,
            //   hintText: "Contoh: 50000",
            //   prefixText: "Rp ",
            //   obscureText: false,
            //   prefixIcon: const Icon(Icons.money),
            //   maxLines: 1,
            //   suffixIcon: null,
            //   keyboardType: TextInputType.number,
            //   inputFormatters: [
            //     FilteringTextInputFormatter.digitsOnly,
            //     currencyInputFormatter(),
            //   ],
            // ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                filled: true,
                fillColor: cardColor,
                labelText: "Harga Layanan",
                prefixText: "Rp ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                currencyInputFormatter(),
              ],
              validator: _validatePrice,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _createNewService,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'SIMPAN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
