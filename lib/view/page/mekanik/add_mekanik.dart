import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omzetin_bengkel/model/mekanik.dart';
import 'package:omzetin_bengkel/providers/mekanikProvider.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:provider/provider.dart';
import 'package:omzetin_bengkel/model/cashierImageProfile.dart'; // Make sure this import is correct

class AddPegawaiPage extends StatefulWidget {
  final Mekanik? pegawai;

  const AddPegawaiPage({this.pegawai, Key? key}) : super(key: key);

  @override
  State<AddPegawaiPage> createState() => _AddPegawaiPageState();
}

class _AddPegawaiPageState extends State<AddPegawaiPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _spesialisController;
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
        TextEditingController(text: widget.pegawai?.namaMekanik ?? '');
    _spesialisController =
        TextEditingController(text: widget.pegawai?.spesialis ?? '');
    _noHpController =
        TextEditingController(text: widget.pegawai?.noHandphone ?? '');
    _alamatController =
        TextEditingController(text: widget.pegawai?.alamat ?? '');
    _gender = widget.pegawai?.gender ?? 'Laki-laki';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _spesialisController.dispose();
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
              // ListTile(
              //   leading: Icon(Icons.photo_library),
              //   title: Text('Pilih dari Gallery'),
              //   onTap: () async {
              //     Navigator.pop(context);
              //     try {
              //       final XFile? pickedFile = await _picker.pickImage(
              //         source: ImageSource.gallery,
              //         maxWidth: 800,
              //         maxHeight: 800,
              //         imageQuality: 85,
              //       );
              //       if (pickedFile != null) {
              //         setState(() {
              //           _imageFile = File(pickedFile.path);
              //           _selectedImagePath = pickedFile.path; // Store file path
              //         });
              //       }
              //     } catch (e) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(
              //           content: Text('Gagal memilih gambar: ${e.toString()}'),
              //           backgroundColor: Colors.red,
              //         ),
              //       );
              //     }
              //   },
              // ),
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

    if (_nameController.text.trim().isEmpty) {
      showNullDataAlert(context, message: 'Nama Tidak Boleh Kosong');
      return;
    }
    if (_spesialisController.text.trim().isEmpty) {
      showNullDataAlert(context, message: 'Spesialis Tidak Boleh Kosong');
      return;
    }
    if (_gender.trim().isEmpty) {
      showNullDataAlert(context, message: 'Gender Tidak Boleh Kosong');
      return;
    }
    // Validate email is not empty
    if (_noHpController.text.trim().isEmpty) {
      showNullDataAlert(context, message: 'Nomor Handphone Tidak Boleh Kosong');
      return;
    }
    if (_alamatController.text.trim().isEmpty) {
      showNullDataAlert(context, message: 'Alamat Tidak Boleh Kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pegawaiProvider =
          Provider.of<MekanikProvider>(context, listen: false);

      // Debug: Cetak nilai sebelum dikirim
      debugPrint('Data yang akan dikirim:');
      debugPrint('Nama: ${_nameController.text}');
      debugPrint('Spesialis: ${_spesialisController.text}');
      debugPrint('No HP: ${_noHpController.text}');
      debugPrint('Gender: $_gender');
      debugPrint('Alamat: ${_alamatController.text}');
      debugPrint('Image: ${_imageFile?.path ?? widget.pegawai?.profileImage}');

      final mekanikData = Mekanik(
          id: widget.pegawai?.id ?? 0,
          namaMekanik: _nameController.text.trim(),
          spesialis: _spesialisController.text.trim(),
          noHandphone: _noHpController.text.trim(),
          gender: _gender,
          alamat: _alamatController.text.trim(),
          profileImage: _imageFile?.path ??
              _selectedImagePath ??
              widget.pegawai?.profileImage ??
              '');

      // Debug: Cetak data yang akan dikirim dalam format map
      debugPrint('Data Map: ${mekanikData.toJson()}');

      if (widget.pegawai == null) {
        await pegawaiProvider.addMekanik(mekanikData.toJson());
        showSuccessAlert(context, 'Data pegawai berhasil ditambahkan');
      } else {
        await pegawaiProvider.updatePegawai(
            widget.pegawai!.id!, mekanikData.toJson());
        showSuccessAlert(context, 'Data pegawai berhasil diperbarui');
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
      onTap: () {
        _selectProfileImage();
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          image: DecorationImage(
            image: _getProfileImage() ??
                AssetImage('assets/products/no-image.png'),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              debugPrint('Error loading image: $exception');
            },
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
    final existingImage = widget.pegawai?.profileImage;
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
                widget.pegawai == null ? 'TAMBAH PEGAWAI' : 'EDIT PEGAWAI',
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
                                  "Nama Pegawai",
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
                                  hintText: "Masukkan Nama Pegawai",
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
                                  "Spesialis",
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
                                  hintText: "Masukkan Spesialis",
                                  prefixIcon: null,
                                  controller: _spesialisController,
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
                      text: widget.pegawai == null
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
