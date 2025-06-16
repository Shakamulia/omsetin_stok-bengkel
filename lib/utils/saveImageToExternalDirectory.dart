import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<File> saveImageToExternalDirectory(File imageFile) async {
  // Dapatkan direktori eksternal
  final directory = await getExternalStorageDirectory();
  if (directory == null) {
    throw Exception("Tidak dapat mengakses direktori eksternal");
  }

  // Buat nama file unik
  final fileName = path.basename(imageFile.path);
  final newPath = path.join(directory.path, fileName);

  // Salin file ke direktori eksternal
  final savedImage = await imageFile.copy(newPath);
  print("Gambar disimpan di: $newPath");

  return savedImage;
}