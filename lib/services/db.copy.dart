import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'package:omsetin_bengkel/utils/alert.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:omsetin_bengkel/model/product.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  var status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    throw Exception('Izin akses penyimpanan ditolak');
  }
}

Future<void> copyDatabaseToStorage(
    BuildContext context, List<Product> products) async {
  try {
    await requestStoragePermission();

    String generateUniqueBackupPath(Directory dir, String baseName) {
      int counter = 1;
      String path = p.join(dir.path, '$baseName.zip');
      while (File(path).existsSync()) {
        path = p.join(dir.path, '$baseName ($counter).zip');
        counter++;
      }
      return path;
    }

    final dbPath = await getDatabasesPath();
    final dbFile = File('$dbPath/master_db.db');
    print(dbFile.path);
    final encoder = ZipEncoder();
    final archive = Archive();

    // Tambahkan database
    if (await dbFile.exists()) {
      archive.addFile(ArchiveFile(
        'master_db.db',
        await dbFile.length(),
        await dbFile.readAsBytes(),
      ));
    }
    final appDocDir = await getExternalStorageDirectory();
    final productDir = Directory('${appDocDir!.path}/product');
    if (await productDir.exists()) {
      for (var file in productDir.listSync()) {
        if (file is File) {
          final bytes = await file.readAsBytes();
          final filename = 'files/product/${file.uri.pathSegments.last}';
          archive.addFile(ArchiveFile(filename, bytes.length, bytes));
        }
      }
    } else {
      throw Exception('Folder product tidak ditemukan: ${productDir.path}');
    }

    final tokotDir = Directory('${appDocDir.path}/toko');
    if (await tokotDir.exists()) {
      for (var file in tokotDir.listSync()) {
        if (file is File) {
          final bytes = await file.readAsBytes();
          final filename = 'files/toko/${file.uri.pathSegments.last}';
          archive.addFile(ArchiveFile(filename, bytes.length, bytes));
        }
      }
    } else {
      throw Exception('Folder toko tidak ditemukan: ${tokotDir.path}');
    }

    // simpan ke zip
    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final backupPath = generateUniqueBackupPath(downloadDir, 'backup_mycash');
    final backupFile = File(backupPath);
    await backupFile.writeAsBytes(encoder.encode(archive)!);

    await backupFile.writeAsBytes(encoder.encode(archive)!);

    // await MediaScanner.loadMedia(backupFile.path);

    // Share
    showStatusDialog(context, 'Data berhasil dibackup!');

    await Share.shareXFiles([XFile(backupFile.path)],
        text: 'Backup data MyCash kamu!');
  } catch (e) {
    showErrorDialog(context, 'Ada kesalahan, silahkan hubungi Admin!');
  }
}
