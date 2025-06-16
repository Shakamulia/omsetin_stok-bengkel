import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi_light.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omsetin_stok/providers/settingProvider.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/failedAlert.dart';
import 'package:omsetin_stok/utils/image.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/utils/successAlert.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/custom_textfield.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ProfilTokoPage extends StatefulWidget {
  const ProfilTokoPage({super.key});

  @override
  _ProfilTokoPageState createState() => _ProfilTokoPageState();
}

class _ProfilTokoPageState extends State<ProfilTokoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService.instance;

  File? image;
  String noImage = "assets/products/no-image.png";
  String? currentImage;
  bool isSelectingImage = false;

  @override
  void initState() {
    super.initState();
    loadSettingProfile();
    loadAllSettingData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> loadAllSettingData() async {
    final settingData = await _databaseService.getAllSettings();

    setState(() {});
  }

  Future pickImage(ImageSource source, context) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      Navigator.pop(context);

      if (pickedImage == null) return;

      final imageTemporary = File(pickedImage.path);
      print(pickedImage);
      setState(() => this.image = imageTemporary);

      final croppedImage = await cropImage(imageTemporary);

      if (croppedImage != null) {
        setState(() {
          image = croppedImage;
        });
      }

      isSelectingImage = true;
    } on PlatformException catch (e) {
      print("Error: $e");
    }
  }

  void _selectCameraOrGalery(BuildContext buildContext) {
    showDialog(
      context: buildContext,
      builder: (context) => AlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => pickImage(ImageSource.camera, context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(
                    MdiLight.camera,
                    size: 40,
                  ),
                  Gap(10),
                  Text(
                    "Kamera",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Gap(15),
            const Divider(
              color: Colors.black,
              indent: 1.0,
            ),
            const Gap(15),
            GestureDetector(
              onTap: () => pickImage(ImageSource.gallery, context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(
                    Ion.ios_albums_outline,
                    size: 40,
                  ),
                  Gap(15),
                  Text(
                    "Galeri",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadSettingProfile() async {
    final settingProfile = await _databaseService.getSettingProfile();

    setState(() {
      _nameController.text = settingProfile['settingName'] ?? '';
      _addressController.text = settingProfile['settingAddress'] ?? '';
      _footerController.text = settingProfile['settingFooter'] ?? '';
      currentImage = settingProfile['settingImage'];
      if (currentImage != null &&
          currentImage!.isNotEmpty &&
          File(currentImage!).existsSync()) {
        image = File(currentImage!);
      }
      print('Name: ${_nameController.text}');
      print('Address: ${_addressController.text}');
      print('Footer: ${_footerController.text}');
      print('Current Image: $currentImage');
    });
  }

  Future<void> _updateSettingProfile() async {
    if (image == null || image!.path.isEmpty) {
      _imageController.text = "";
    } else {
      final directory = await getExternalStorageDirectory();
      final tokoDir = Directory('${directory!.path}/toko');
      if (!await tokoDir.exists()) {
        await tokoDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await image!.copy('${tokoDir.path}/$fileName');
      _imageController.text = savedImage.path;
    }

    try {
      await _databaseService.updateSettingProfile(
          _nameController.text,
          _addressController.text,
          _footerController.text,
          _imageController.text);
      print("berhasil update, gambar: ${_imageController.text}");
      isSelectingImage = false;

      showSuccessAlert(context, "Berhasil Memperbarui Pengaturan Bengkel");
    } catch (e) {
      showFailedAlert(context,
          message: "Ada kesalahan, silahkan hubungi Admin!.");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    var settingProvider = Provider.of<SettingProvider>(
      context,
    );

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
                  secondaryColor,
                  primaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              )
            ),
            child: AppBar(
              leading: const CustomBackButton(),
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              title: Text(
                'Profil Bengkel',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _selectCameraOrGalery(context);
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: image != null && image!.existsSync()
                                    ? Hero(
                                        tag: "settingImage",
                                        child: Image.file(
                                          image!,
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              "assets/products/no-image.png",
                                              width: 180,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      )
                                    : Hero(
                                        tag: "settingNoImage",
                                        child: Image.asset(
                                          "assets/products/no-image.png",
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                            if (image != null)
                              Positioned(
                                top: 10,
                                right: 15,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Iconify(
                                      Bi.x,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      image = null;
                                      isSelectingImage = true;
                                      setState(() {
                                        image = null;
                                        _imageController.text = '';
                                      });
                                    },
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const IconButton(
                                  icon: Iconify(
                                    Bi.camera_fill,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // if (isSelectingImage != false)
                    //   ElevatedButton(
                    //     onPressed: () {
                    //       setState(() {
                    //         isSelectingImage = false;
                    //         image = File(currentImage!);
                    //       });
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12.0),
                    //       ),
                    //       backgroundColor: Colors.red,
                    //       foregroundColor: Colors.white,
                    //     ),
                    //     child: const Center(
                    //       child: Text(
                    //         "Cancel",
                    //         style: TextStyle(fontSize: 16),
                    //       ),
                    //     ),
                    //   ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Nama Bengkel',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const Gap(10),
                    CustomTextField(
                      maxLines: null,
                      fillColor: cardColor,
                      suffixIcon: null,
                      obscureText: false,
                      hintText: 'Nama Bengkel',
                      prefixIcon: null,
                      controller: _nameController,
                    ),
                    const Gap(10),
                    const _Label(
                      text: 'Alamat Lengkap Bengkel',
                    ),
                    const Gap(10),
                    CustomTextField(
                      suffixIcon: null,
                      fillColor: cardColor,
                      obscureText: false,
                      hintText: 'Alamat Bengkel',
                      prefixIcon: null,
                      controller: _addressController,
                      maxLines: 4,
                    ),
                    const Gap(10),
                    const _Label(text: 'Footer Message Bengkel'),
                    const Gap(10),
                    CustomTextField(
                      suffixIcon: null,
                      fillColor: cardColor,
                      obscureText: false,
                      hintText: 'Footer Message',
                      prefixIcon: null,
                      controller: _footerController,
                      maxLines: 4,
                    ),
                    const Gap(10),
                    const Gap(100),
                  ],
                ),
              ),
              ExpensiveFloatingButton(onPressed: () async {
                try {
                  await _updateSettingProfile();
                  await settingProvider.getSettingProfile();
                } catch (e) {
                  print("Error saat update profile: $e");
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class ArrowRight extends StatelessWidget {
  const ArrowRight({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Iconify(
      MaterialSymbols.arrow_forward_ios_rounded,
      size: 18,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
              fontSize: SizeHelper.Fsize_settingLabel(context),
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
