import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/services.dart';
import 'package:omzetin_bengkel/providers/securityProvider.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/failedAlert.dart';
import 'package:omzetin_bengkel/utils/formatters.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class UpdateServicesPage extends StatefulWidget {
  final Service services;

  const UpdateServicesPage({super.key, required this.services});

  @override
  State<UpdateServicesPage> createState() => _UpdateServicesPageState();
}

class _UpdateServicesPageState extends State<UpdateServicesPage> {
  late TextEditingController _servicesNameController;
  late TextEditingController _servicesPriceController;
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _servicesNameController =
        TextEditingController(text: widget.services.serviceName);
    _servicesPriceController =
        TextEditingController(text: widget.services.servicePrice.toString());
  }

  @override
  Widget build(BuildContext context) {
    var securityProvider = Provider.of<SecurityProvider>(context);

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
                  'UBAH LAYANAN',
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
                                        controller: _servicesNameController,
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
                                        controller: _servicesPriceController,
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
                if (securityProvider.editServices)
                ExpensiveFloatingButton(
                  left: 20,
                  right: 20,
                  text: "SIMPAN",
                  onPressed: () async {
                    final name = _servicesNameController.text;
                    final price =
                        int.tryParse(_servicesPriceController.text) ?? 0;

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
                      final updatedService = Service(
                        serviceId: widget.services.serviceId,
                        serviceName: name,
                        servicePrice: price,
                        dateAdded: widget.services.dateAdded,
                      );

                      await _databaseService.updateService(updatedService);

                      showSuccessAlert(
                          context, 'Layanan "$name" berhasil diperbarui!');
                      Navigator.pop(context, true);
                    } catch (e) {
                      showFailedAlert(context,
                          message: "Gagal memperbarui layanan: $e");
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _servicesNameController.dispose();
    _servicesPriceController.dispose();
    super.dispose();
  }
}
