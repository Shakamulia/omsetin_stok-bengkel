import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/mdi_light.dart';
import 'package:image_picker/image_picker.dart';

Future<void> pickImage(BuildContext context, ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: source);
  if (image != null) {
    // Handle the selected image
    // For example, you can display the selected image in an Image widget
    Navigator.pop(context,image.path); // Close the dialog
    // You can also pass the image path to another function or store it in a state variable
    print('Selected image path: ${image.path}');
  }
}

void selectCameraOrGalery(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => pickImage(context, ImageSource.camera),
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
              onTap: () => pickImage(context, ImageSource.gallery),
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