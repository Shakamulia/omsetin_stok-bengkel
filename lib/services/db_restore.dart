import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:omsetin_bengkel/services/database_service.dart';
import 'package:omsetin_bengkel/utils/alert.dart';
import 'package:omsetin_bengkel/view/page/home/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

Future<void> requestStoragePermission() async {
  var status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    throw Exception('Izin akses penyimpanan ditolak');
  }
}

Future<void> restoreDB(BuildContext context) async {
  await requestStoragePermission();
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null) throw Exception('Tidak ada file yang dipilih');

    File zipFile = File(result.files.single.path!);

    if (!zipFile.path.endsWith('.zip')) {
      showErrorDialog(context, 'File harus berupa ZIP!');
    }
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final appDir = await getExternalStorageDirectory();

    final productDir = Directory('${appDir!.path}/product');
    final tokoDir = Directory('${appDir.path}/toko');
    await productDir.create(recursive: true);
    await tokoDir.create(recursive: true);

    bool dbRestored = false;
    bool productRestored = false;
    bool tokoRestored = false;

    for (var file in archive) {
      if (file.isFile) {
        final filename = file.name;

        // Restore database
        if (filename == 'master_db.db') {
          final dbPath = await getDatabasesPath();
          final dbFile = File('$dbPath/master_db.db');
          await dbFile.writeAsBytes(file.content as List<int>);
          print('Database berhasil dipulihkan! $dbPath');
          dbRestored = true;
          continue;
        }

        // Restore product images
        if (filename.startsWith('files/product/')) {
          final targetPath =
              '${productDir.path}/${filename.replaceFirst('files/product/', '')}';
          final outputFile = File(targetPath);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
          print('Gambar produk dipulihkan: $targetPath');
          productRestored = true;
          continue;
        }

        // Restore toko images
        if (filename.startsWith('files/toko/')) {
          final targetPath =
              '${tokoDir.path}/${filename.replaceFirst('files/toko/', '')}';
          final outputFile = File(targetPath);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
          print('Gambar toko dipulihkan: $targetPath');
          tokoRestored = true;
          continue;
        }

        // Jika file tidak dikenal
        print('File tidak dikenal dan dilewati: $filename');
      }
    }

    if (!dbRestored) {
      throw Exception(
          "File backup tidak valid: file database tidak ditemukan.");
    }

    Navigator.pop(context);
    showStatusDialog(context, 'Data berhasil dipulihkan!');
    await DatabaseService.instance.reopen();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Home()),
      (route) => false,
    );
  } catch (e) {
    Navigator.pop(context);
    showErrorDialog(context, 'Restore gagal, silakan hubungi admin!\n$e');
  }
}
