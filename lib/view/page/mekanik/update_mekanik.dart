import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omsetin_bengkel/model/mekanik.dart';
import 'package:omsetin_bengkel/services/db_helper.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/image.dart';
import 'package:omsetin_bengkel/utils/successAlert.dart';
import 'package:omsetin_bengkel/utils/failedAlert.dart';
import 'package:omsetin_bengkel/utils/null_data_alert.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/custom_textfield.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class UpdateMekanikPage extends StatefulWidget {
  final Mekanik mekanik;

  const UpdateMekanikPage({super.key, required this.mekanik});

  @override
  State<UpdateMekanikPage> createState() => _UpdateMekanikPageState();
}

class _UpdateMekanikPageState extends State<UpdateMekanikPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late TextEditingController _namaController;
  late TextEditingController _spesialisController;
  late TextEditingController _noHpController;
  late TextEditingController _alamatController;
  late String _gender;
  File? image;
  String noImage = "assets/customers/add-image.png";
  String? currentProfileImage;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.mekanik.namaMekanik);
    _spesialisController =
        TextEditingController(text: widget.mekanik.spesialis);
    _noHpController = TextEditingController(text: widget.mekanik.noHandphone);
    _alamatController = TextEditingController(text: widget.mekanik.alamat);
    _gender = widget.mekanik.gender;
    currentProfileImage = widget.mekanik.profileImage;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _spesialisController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future pickImage(ImageSource source, context) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      Navigator.pop(context);
      if (pickedImage == null) return;

      final imageTemporary = File(pickedImage.path);
      setState(() => this.image = imageTemporary);

      final croppedImage = await cropImage(imageTemporary);
      if (croppedImage != null) {
        setState(() => image = croppedImage);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _selectCameraOrGalery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kamera"),
              onTap: () => pickImage(ImageSource.camera, context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeri"),
              onTap: () => pickImage(ImageSource.gallery, context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    String profileImage;

    if (image != null) {
      final directory = await getExternalStorageDirectory();
      final mekanikDir = Directory('${directory!.path}/mekanik');
      if (!await mekanikDir.exists()) {
        await mekanikDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await image!.copy('${mekanikDir.path}/$fileName');
      profileImage = savedImage.path;
    } else {
      profileImage = currentProfileImage ?? "assets/customers/no-image.png";
    }

    if (_namaController.text.isEmpty ||
        _spesialisController.text.isEmpty ||
        _noHpController.text.isEmpty ||
        _alamatController.text.isEmpty) {
      showNullDataAlert(context, message: "Harap isi semua kolom yang wajib!");
      return;
    }

    try {
      final updatedMekanik = Mekanik(
        id: widget.mekanik.id,
        profileImage: profileImage,
        namaMekanik: _namaController.text,
        spesialis: _spesialisController.text,
        noHandphone: _noHpController.text,
        gender: _gender,
        alamat: _alamatController.text,
      );

      await _dbHelper.updateMekanik(updatedMekanik);
      showSuccessAlert(context, "Berhasil Memperbarui Mekanik!");
      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint("🛑 Error saat update mekanik: $e");
      debugPrint("📍 Stack trace:\n$stackTrace");
      showFailedAlert(context, message: "Gagal memperbarui mekanik: $e");
    }
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
                'EDIT DATA MEKANIK',
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
            Center(
              child: GestureDetector(
                onTap: _selectCameraOrGalery,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: image != null
                            ? Image.file(
                                image!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              )
                            : (currentProfileImage != null &&
                                    currentProfileImage!.startsWith('/'))
                                ? Image.file(
                                    File(currentProfileImage!),
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    noImage,
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    ),
                    if (image != null ||
                        (currentProfileImage != null &&
                            currentProfileImage !=
                                "assets/customers/no-image.png"))
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
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                image = null;
                                currentProfileImage =
                                    "assets/customers/no-image.png";
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
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              "Nama Mekanik",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _namaController,
              hintText: "Nama Mekanik",
              obscureText: false,
              prefixIcon: const Icon(Icons.person),
              maxLines: 1,
              suffixIcon: null,
            ),
            const SizedBox(height: 15),
            const Text(
              "Spesialis",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _spesialisController,
              hintText: "Spesialis (Contoh: Mesin, Elektrik, dll)",
              obscureText: false,
              prefixIcon: const Icon(Icons.engineering),
              maxLines: 1,
              suffixIcon: null,
            ),
            const SizedBox(height: 15),
            const Text(
              "No. Handphone",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _noHpController,
              hintText: "No. Handphone",
              obscureText: false,
              prefixIcon: const Icon(Icons.phone),
              maxLines: 1,
              suffixIcon: null,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            const Text(
              "Jenis Kelamin",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ['Laki-laki', 'Perempuan']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _gender = value!);
              },
            ),
            const SizedBox(height: 15),
            const Text(
              "Alamat",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _alamatController,
              hintText: "Alamat",
              obscureText: false,
              prefixIcon: const Icon(Icons.home),
              maxLines: 3,
              suffixIcon: null,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'UPDATE',
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
