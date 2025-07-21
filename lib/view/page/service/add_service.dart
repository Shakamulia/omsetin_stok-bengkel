import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/services.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/services/service_db_helper.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/formatters.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/utils/failedAlert.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final ServiceDatabaseHelper _serviceHelper = ServiceDatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;

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
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              scrolledUnderElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              titleSpacing: 0,
              leading: const CustomBackButton(),
              title: Text(
                'TAMBAH LAYANAN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(25),
                                  const Text(
                                    "Nama Layanan",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const Gap(10),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        hintText: "Nama Layanan",
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.design_services),
                                      ),
                                    ),
                                  ),
                                  const Gap(15),
                                  const Text(
                                    "Harga Layanan",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const Gap(10),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextField(
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: "Harga Layanan",
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.attach_money),
                                      ),
                                    ),
                                  ),
                                  const Gap(20),
                                  // Add extra space if needed
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Fixed button at the bottom
                ],
              ),
              ExpensiveFloatingButton(
                left: 20,
                right: 20,
                text: "SIMPAN",
                onPressed: () async {
                  final name = _nameController.text;
                  final price = int.tryParse(_priceController.text) ?? 0;

                  if (name.isEmpty) {
                    showNullDataAlert(context,
                        message: "Nama layanan tidak boleh kosong");
                    return;
                  }

                  if (price <= 0) {
                    showNullDataAlert(context,
                        message: "Harga layanan tidak valid");
                    return;
                  }

                  try {
                    await _databaseService.addServices(
                        name, DateTime.now().toIso8601String(), price);

                    showSuccessAlert(
                        context, 'Layanan "$name" berhasil ditambahkan!');
                    Navigator.pop(context, true);
                  } catch (e) {
                    showFailedAlert(context,
                        message: "Gagal menambahkan layanan: $e");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
