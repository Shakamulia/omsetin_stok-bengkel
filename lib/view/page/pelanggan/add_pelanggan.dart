import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omsetin_bengkel/model/pelanggan.dart';
import 'package:omsetin_bengkel/providers/pelangganProvider.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/utils/successAlert.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omsetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:provider/provider.dart';
import 'package:omsetin_bengkel/model/cashierImageProfile.dart'; // Make sure this import is correct

class AddPelangganPage extends StatefulWidget {
  final Pelanggan? pelanggan;

  const AddPelangganPage({this.pelanggan, Key? key}) : super(key: key);

  @override
  State<AddPelangganPage> createState() => _AddPelangganPageState();
}

class _AddPelangganPageState extends State<AddPelangganPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _noHpController;
  late TextEditingController _alamatController;
  String? _selectedImagePath;

  String _gender = 'Laki-laki';
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _selectProfileImage() {
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
                      // Simpan sebagai asset path dan set _imageFile ke null
                      _imageFile = null;
                      _selectedImagePath = profile.imageUrl; // Store asset path
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

  void _initializeControllers() {
    _nameController =
        TextEditingController(text: widget.pelanggan?.namaPelanggan ?? '');
    _emailController =
        TextEditingController(text: widget.pelanggan?.email ?? '');
    _noHpController = TextEditingController(
        text: widget.pelanggan?.noHandphone?.toString() ?? '');
    _alamatController =
        TextEditingController(text: widget.pelanggan?.alamat ?? '');
    _gender = widget.pelanggan?.gender ?? 'Laki-laki';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pilih dari Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final XFile? pickedFile = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _imageFile = File(pickedFile.path);
                        _selectedImagePath = pickedFile.path; // Store file path
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memilih gambar: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.face),
                title: Text('Pilih Profil Bawaan'),
                onTap: () {
                  Navigator.pop(context);
                  _selectProfileImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate email is not empty
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pelangganProvider =
          Provider.of<Pelangganprovider>(context, listen: false);

      final pelangganData = {
        'kode': widget.pelanggan?.kode ??
            pelangganProvider.generateKodePelanggan(),
        'namaPelanggan': _nameController.text.trim(),
        'noHandphone': _noHpController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _gender,
        'alamat': _alamatController.text.trim(),
        'profileImage': _imageFile?.path ??
            _selectedImagePath ??
            widget.pelanggan?.profileImage ??
            '',
      };

      debugPrint('Data Map: $pelangganData');

if (widget.pelanggan == null) {
  await pelangganProvider.addPelanggan(pelangganData);
  if (mounted) {
    showSuccessAlert(
      context,
      'Pelanggan baru telah ditambahkan.',
    );
  }
} else {
  await pelangganProvider.updatePelanggan(
    widget.pelanggan!.id!, 
    pelangganData,
  );
  if (mounted) {
    showSuccessAlert(
      context,
      'Perubahan telah disimpan.',
    );
  }
}

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      debugPrint('Error saat mengirim data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          image: _getProfileImage() != null
              ? DecorationImage(
                  image: _getProfileImage()!,
                  fit: BoxFit.cover,
                )
              : DecorationImage(
                  image: AssetImage('assets/products/no-image.png'),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    // Priority 1: Newly selected file image
    if (_imageFile != null) return FileImage(_imageFile!);

    // Priority 2: Selected asset image path
    if (_selectedImagePath != null &&
        _selectedImagePath!.startsWith('assets/')) {
      return AssetImage(_selectedImagePath!);
    }

    // Priority 3: Existing pegawai image
    final existingImage = widget.pelanggan?.profileImage;
    if (existingImage != null && existingImage.isNotEmpty) {
      if (existingImage.startsWith('http')) {
        return NetworkImage(existingImage);
      } else if (existingImage.startsWith('assets/')) {
        return AssetImage(existingImage);
      } else {
        return FileImage(File(existingImage));
      }
    }

    // Default image
    return AssetImage('assets/products/no-image.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
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
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              title: Text(
                widget.pelanggan == null
                    ? 'TAMBAH PELANGGAN'
                    : 'EDIT PELANGGAN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              leading: CustomBackButton(),
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 100, // Extra space for floating button
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: _buildProfileImage()),
                          const Gap(15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Nama Pelanggan",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const Gap(5),
                                CustomTextField(
                                  obscureText: false,
                                  fillColor: Colors.grey[200],
                                  hintText: "Masukkan Nama Pelanggan",
                                  prefixIcon: null,
                                  controller: _nameController,
                                  hintStyle: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[400],
                                  ),
                                  maxLines: 1,
                                  suffixIcon: null,
                                ),
                                const Gap(15),
                                const Text(
                                  "Email",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const Gap(5),
                                CustomTextField(
                                  obscureText: false,
                                  fillColor: Colors.grey[200],
                                  hintText: "Masukkan Email",
                                  prefixIcon: null,
                                  controller: _emailController,
                                  hintStyle: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[400],
                                  ),
                                  maxLines: 1,
                                  suffixIcon: null,
                                ),
                                const Gap(15),
                                const Text(
                                  "Jenis Kelamin",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const Gap(5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Laki-laki'),
                                        value: 'Laki-laki',
                                        groupValue: _gender,
                                        activeColor: primaryColor,
                                        onChanged: (value) {
                                          setState(() {
                                            _gender = value!;
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Perempuan'),
                                        value: 'Perempuan',
                                        groupValue: _gender,
                                        activeColor: primaryColor,
                                        onChanged: (value) {
                                          setState(() {
                                            _gender = value!;
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(15),
                                const Text(
                                  "Nomor Handphone",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const Gap(5),
                                CustomTextField(
                                  obscureText: false,
                                  fillColor: Colors.grey[200],
                                  hintText: "Masukkan Nomor Handphone",
                                  prefixIcon: null,
                                  controller: _noHpController,
                                  hintStyle: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[400],
                                  ),
                                  maxLines: 1,
                                  keyboardType: TextInputType.phone,
                                  suffixIcon: null,
                                ),
                                const Gap(15),
                                const Text(
                                  "Alamat",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const Gap(5),
                                CustomTextField(
                                  obscureText: false,
                                  fillColor: Colors.grey[200],
                                  hintText: "Masukkan Alamat",
                                  prefixIcon: null,
                                  controller: _alamatController,
                                  hintStyle: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey[400],
                                  ),
                                  maxLines: 3,
                                  suffixIcon: null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ExpensiveFloatingButton(
                      onPressed: _submitForm,
                      text: widget.pelanggan == null
                          ? 'SIMPAN DATA'
                          : 'UPDATE DATA',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
