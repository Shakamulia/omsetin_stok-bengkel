import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/mdi_light.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omzetin_bengkel/providers/userProvider.dart';
import 'package:omzetin_bengkel/services/userService.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/image.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? image;
  String noImage = "assets/products/no-image.png";
  bool _isSerialNumObscured = true;
  bool isNoImage = false;
  bool _isLoading = true;
  String? _errorMessage;
  final userService = UserService();

  late TextEditingController serialNumberController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;

  @override
  void initState() {
    super.initState();
    serialNumberController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.getSerialNumberAsUser(context);

      if (userProvider.serialNumberData != null) {
        final data = userProvider.serialNumberData!;
        serialNumberController.text = data.serialNumber;
        nameController.text = data.name;
        emailController.text = data.email;
        phoneNumberController.text = data.phoneNumber;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data pengguna';
      });
    }
  }

  @override
  void dispose() {
    serialNumberController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void _selectCameraOrGalery() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.camera);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(MdiLight.camera, size: 40),
                  Gap(10),
                  Text("Kamera", style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const Gap(15),
            const Divider(color: Colors.black),
            const Gap(15),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.gallery);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(Ion.ios_albums_outline, size: 40),
                  Gap(15),
                  Text("Galeri", style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;

      final imageTemporary = File(pickedImage.path);
      final croppedImage = await cropImage(imageTemporary);

      setState(() {
        image = croppedImage ?? imageTemporary;
        isNoImage = false;
      });
    } on PlatformException catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<File> getAssetAsFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile;
  }

  Future<void> _saveUserProfile() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      File? imageFile;

      if (isNoImage) {
        imageFile = await getAssetAsFile(noImage);
      } else if (image != null) {
        imageFile = image;
      }

      await userService.updateSerialNumberDetails(
        context,
        nameController.text,
        emailController.text,
        phoneNumberController.text,
        imageFile,
      );

      // Refresh data after update
      await _loadUserData();
    } catch (e) {
      debugPrint("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              end: Alignment.bottomCenter,
            )),
            child: AppBar(
              leading: const CustomBackButton(),
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0,
              title: Text(
                'PROFIL PENGGUNA',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
            ),
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_errorMessage != null) {
            return Center(child: Text(_errorMessage!));
          }

          final profileImage = isNoImage
              ? null
              : (image != null
                  ? null
                  : userProvider.serialNumberData?.profileImage);

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
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
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: image != null
                                            ? Image.file(
                                                image!,
                                                width: 180,
                                                height: 180,
                                                fit: BoxFit.cover,
                                              )
                                            : (profileImage != null &&
                                                    !isNoImage
                                                ? CachedNetworkImage(
                                                    imageUrl: userProvider
                                                        .getProfileImageUrl(
                                                            profileImage),
                                                    width: 180,
                                                    height: 180,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        const CircularProgressIndicator(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      noImage,
                                                      width: 180,
                                                      height: 180,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    noImage,
                                                    width: 180,
                                                    height: 180,
                                                    fit: BoxFit.cover,
                                                  )),
                                      ),
                                    ),
                                    if ((userProvider.serialNumberData
                                                    ?.profileImage !=
                                                null &&
                                            !isNoImage) ||
                                        image != null)
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
                                              setState(() {
                                                isNoImage = true;
                                                image = null;
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
                                        child: IconButton(
                                          icon: const Iconify(
                                            Bi.camera_fill,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          onPressed: _selectCameraOrGalery,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Gap(10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Serial Number",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ),
                            CustomTextField(
                              fillColor: Colors.grey[200],
                              hintText: "Serial Number",
                              suffixIcon: IconButton(
                                icon: _isSerialNumObscured
                                    ? const Iconify(Ic.twotone_visibility)
                                    : const Iconify(Ic.twotone_visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isSerialNumObscured =
                                        !_isSerialNumObscured;
                                  });
                                },
                              ),
                              prefixIcon: null,
                              obscureText: _isSerialNumObscured,
                              maxLines: 1,
                              controller: serialNumberController,
                              readOnly: true,
                            ),
                            const Gap(10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Nama",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ),
                            CustomTextField(
                              fillColor: Colors.grey[200],
                              hintText: "Nama",
                              prefixIcon: const Icon(FontAwesomeIcons.user),
                              suffixIcon: null,
                              obscureText: false,
                              maxLines: 1,
                              controller: nameController,
                            ),
                            const Gap(10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Email",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ),
                            CustomTextField(
                              fillColor: Colors.grey[200],
                              hintText: "Email",
                              prefixIcon: const Icon(FontAwesomeIcons.envelope),
                              suffixIcon: null,
                              obscureText: false,
                              maxLines: 1,
                              controller: emailController,
                            ),
                            const Gap(10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("No. Telepon",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ),
                            CustomTextField(
                              fillColor: Colors.grey[200],
                              hintText: "No. Telepon",
                              prefixIcon: const Icon(FontAwesomeIcons.phone),
                              suffixIcon: null,
                              obscureText: false,
                              maxLines: 1,
                              controller: phoneNumberController,
                            ),
                            const Gap(10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ExpensiveFloatingButton(
                left: 12,
                right: 12,
                onPressed: _saveUserProfile,
              ),
            ],
          );
        },
      ),
    );
  }
}
