import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omzetin_bengkel/model/pelanggan.dart';
import 'package:omzetin_bengkel/services/db_helper.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/image.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/utils/failedAlert.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class UpdatePelangganPage extends StatefulWidget {
  final Pelanggan pelanggan;

  const UpdatePelangganPage({super.key, required this.pelanggan});

  @override
  State<UpdatePelangganPage> createState() => _UpdatePelangganPageState();
}

class _UpdatePelangganPageState extends State<UpdatePelangganPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late TextEditingController _kodeController;
  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _emailController;
  late TextEditingController _alamatController;
  late String _gender;
  File? image;
  String? currentImagePath;

  @override
  void initState() {
    super.initState();
    _kodeController = TextEditingController(text: widget.pelanggan.kode);
    _namaController =
        TextEditingController(text: widget.pelanggan.namaPelanggan);
    _noHpController = TextEditingController(text: widget.pelanggan.noHandphone);
    _emailController = TextEditingController(text: widget.pelanggan.email);
    _alamatController = TextEditingController(text: widget.pelanggan.alamat);
    _gender = widget.pelanggan.gender;
    currentImagePath = widget.pelanggan.profileImage;
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
      final customerDir = Directory('${directory!.path}/customers');
      if (!await customerDir.exists()) {
        await customerDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await image!.copy('${customerDir.path}/$fileName');
      profileImage = savedImage.path;
    } else {
      profileImage = currentImagePath ?? "assets/products/add-image.png";
    }

    if (_kodeController.text.isEmpty ||
        _namaController.text.isEmpty ||
        _noHpController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _alamatController.text.isEmpty) {
      showNullDataAlert(context, message: "Harap isi semua kolom yang wajib!");
      return;
    }

    try {
      final updatedPelanggan = Pelanggan(
        id: widget.pelanggan.id,
        profileImage: profileImage,
        kode: _kodeController.text,
        namaPelanggan: _namaController.text,
        noHandphone: _noHpController.text,
        email: _emailController.text,
        gender: _gender,
        alamat: _alamatController.text,
      );

      await _dbHelper.updatePelanggan(updatedPelanggan);
      showSuccessAlert(context, "Berhasil Memperbarui Pelanggan!");
      Navigator.pop(context, true);
    } catch (e) {
      showFailedAlert(context, message: "Gagal memperbarui pelanggan: $e");
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
                'UPDATE PELANGGAN',
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
                            : currentImagePath != null &&
                                    currentImagePath!.isNotEmpty &&
                                    currentImagePath !=
                                        "assets/customers/no-image.png"
                                ? Image.file(
                                    File(currentImagePath!),
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "assets/products/add-image.png",
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    ),
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
                              currentImagePath =
                                  "assets/products/add-image.png";
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
              "Kode Pelanggan",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _kodeController,
              hintText: "Kode Pelanggan",
              obscureText: false,
              prefixIcon: const Icon(Icons.code),
              maxLines: 1,
              suffixIcon: null,
            ),
            const SizedBox(height: 15),
            const Text(
              "Nama Pelanggan",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _namaController,
              hintText: "Nama Pelanggan",
              obscureText: false,
              prefixIcon: const Icon(Icons.person),
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
              "Email",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _emailController,
              hintText: "Email",
              obscureText: false,
              prefixIcon: const Icon(Icons.email),
              maxLines: 1,
              suffixIcon: null,
              keyboardType: TextInputType.emailAddress,
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
