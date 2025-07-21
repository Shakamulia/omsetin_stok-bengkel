import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:omzetin_bengkel/utils/colors.dart';

Future<File?> cropImage(File? image) async {
  if (image == null) return null;

  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: image.path,
    uiSettings: [
      AndroidUiSettings(
        showCropGrid: true,
        hideBottomControls: false,
        cropFrameStrokeWidth: 2,
        cropGridStrokeWidth: 1,
        cropGridColor: Colors.white,
        cropFrameColor: Colors.white,
        statusBarColor: Colors.transparent,
        activeControlsWidgetColor: purpleColor,
        toolbarColor: primaryColor,
        toolbarTitle: "Potong Gambar",
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: true,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
      ),
    ],
  );

  if (croppedFile != null) {
    return File(croppedFile.path);
  }
  return null;
}
