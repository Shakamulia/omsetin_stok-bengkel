import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:esc_pos_utils_plus/src/barcode.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/transaction.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterHelper {
  static const int chunkSize = 245;

  static Future<void> printReceiptAndOpenDrawer(
    BuildContext context,
    BluetoothDevice device, {
    required List<Map<String, dynamic>> products,
    required List<Map<String, dynamic>> services, // Added services parameter
    int? transactionId,
    String? transactionDate,
    int? totalPrice,
    int? amountPaid,
    int? discountAmount,
    int? queueNumber,
    String? customerName,
  }) async {
    try {
      // Connect to the device
      await device.connect(timeout: const Duration(seconds: 5));

      // Discover services
      List<BluetoothService> bluetoothServices =
          await device.discoverServices();
      final DatabaseService _databaseService = DatabaseService.instance;

      // Find printer characteristic
      BluetoothCharacteristic? printerCharacteristic;
      for (var service in bluetoothServices) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            printerCharacteristic = characteristic;
            break;
          }
        }
      }

      if (printerCharacteristic == null) {
        throw Exception("Printer characteristic not found");
      }

      // Load transaction data
      List<TransactionData> allTransactions =
          await _databaseService.getTransaction();

      if (allTransactions.isEmpty) {
        throw Exception("No transactions found");
      }

      TransactionData lastTransaction = allTransactions.last;

      // Load receipt settings
      final loadReceipt = await DatabaseService.instance.getSettingReceipt();
      final currentReceipt = loadReceipt['settingReceipt'];
      final currentReceiptSize = loadReceipt['settingReceiptSize'];
      final currentImage = loadReceipt['settingImage'];

      // Load profile settings
      final loadProfile = await DatabaseService.instance.getSettingProfile();
      final settingFooter = loadProfile['settingFooter'];
      final settingAddress = loadProfile['settingAddress'];
      final settingName = loadProfile['settingName'];

      // Initialize printer generator
      final profile = await CapabilityProfile.load();
      final Generator generator = currentReceiptSize == '58'
          ? Generator(PaperSize.mm58, profile)
          : Generator(PaperSize.mm80, profile);

      List<int> bytes = [];

      // Open cash drawer if enabled
      final prefs = await SharedPreferences.getInstance();
      final isCashdrawerOn = prefs.getBool('isCashdrawerOn') ?? false;
      if (isCashdrawerOn) {
        bytes += generator.drawer();
      }

      // Add store logo/image if available
      if (currentImage != null && currentImage.isNotEmpty) {
        try {
          final Uint8List imgBytes =
              currentImage == "assets/products/no-image.png"
                  ? (await rootBundle.load(currentImage)).buffer.asUint8List()
                  : await File(currentImage).readAsBytes();

          final img.Image? image = img.decodeImage(imgBytes);
          if (image != null) {
            final img.Image resizedImage = img.copyResize(image, width: 200);
            bytes += generator.image(resizedImage);
          }
        } catch (e) {
          debugPrint("Error loading image: $e");
        }
      }

      // Store header information
      bytes += generator.text(
        settingName ?? '-',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );

      bytes += generator.text(
        settingAddress ?? '-',
        styles: PosStyles(align: PosAlign.center),
      );

      bytes += generator.hr();

      // Transaction information
      bytes += generator.row([
        PosColumn(text: 'ID Transaksi', width: 6),
        PosColumn(
            text:
                '#${lastTransaction.transactionId.toString().padLeft(3, '0')}',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);

      bytes += generator.row([
        PosColumn(text: lastTransaction.transactionDate, width: 12),
      ]);

      bytes += generator.row([
        PosColumn(text: 'Kasir', width: 6),
        PosColumn(
            text: lastTransaction.transactionCashier,
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);

      if (queueNumber != null && queueNumber > 0) {
        bytes += generator.row([
          PosColumn(text: 'Antrian', width: 6),
          PosColumn(
              text: queueNumber.toString(),
              width: 6,
              styles: PosStyles(align: PosAlign.right)),
        ]);
      }

      bytes += generator.hr();

      // Product items section
      if (products.isNotEmpty) {
        bytes += generator.text(
          'PRODUK',
          styles: PosStyles(align: PosAlign.center, bold: true),
        );

        for (var product in products) {
          final productName = product['product_name'] as String;
          final productQuantity = product['quantity'] as int;
          final productPrice = product['product_sell_price'] as int;
          final productTotal = productQuantity * productPrice;

          bytes += generator.text(productName, styles: PosStyles(bold: true));
          bytes += generator.row([
            PosColumn(
                text:
                    '${_formatCurrency(productQuantity)} x ${_formatCurrency(productPrice)}',
                width: 6,
                styles: PosStyles(align: PosAlign.left)),
            PosColumn(
                text: _formatCurrency(productTotal),
                width: 6,
                styles: PosStyles(align: PosAlign.right)),
          ]);
        }
        bytes += generator.hr();
      }

      // Services items section
      if (services.isNotEmpty) {
        bytes += generator.text(
          'LAYANAN',
          styles: PosStyles(align: PosAlign.center, bold: true),
        );

        for (var service in services) {
          final serviceName = service['services_name'] as String;
          final serviceQuantity = service['quantity'] as int;
          final servicePrice = service['services_price'] as int;
          final serviceTotal = serviceQuantity * servicePrice;

          bytes += generator.text(serviceName, styles: PosStyles(bold: true));
          bytes += generator.row([
            PosColumn(
                text:
                    '${_formatCurrency(serviceQuantity)} x ${_formatCurrency(servicePrice)}',
                width: 6,
                styles: PosStyles(align: PosAlign.left)),
            PosColumn(
                text: _formatCurrency(serviceTotal),
                width: 6,
                styles: PosStyles(align: PosAlign.right)),
          ]);
        }
        bytes += generator.hr();
      }

      // Transaction summary
      bytes += generator.row([
        PosColumn(text: 'Status', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: lastTransaction.transactionStatus,
            width: 6,
            styles: PosStyles(align: PosAlign.right, bold: true)),
      ]);

      if (lastTransaction.transactionDiscount != 0) {
        bytes += generator.row([
          PosColumn(text: "Diskon", width: 4),
          PosColumn(
              text: _formatCurrency(lastTransaction.transactionDiscount),
              width: 8,
              styles: PosStyles(align: PosAlign.right))
        ]);
      }

      // Calculate totals
      final productTotal = products.fold<int>(
        0,
        (sum, product) =>
            sum +
            (product['quantity'] as int) *
                (product['product_sell_price'] as int),
      );

      final serviceTotal = services.fold<int>(
        0,
        (sum, service) =>
            sum +
            (service['quantity'] as int) * (service['services_price'] as int),
      );

      final subtotal = productTotal + serviceTotal;

      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 6),
        PosColumn(
            text: _formatCurrency(subtotal),
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);

      bytes += generator.row([
        PosColumn(text: 'Total', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: _formatCurrency(lastTransaction.transactionTotal),
            width: 6,
            styles: PosStyles(align: PosAlign.right, bold: true)),
      ]);

      if (amountPaid != null) {
        bytes += generator.row([
          PosColumn(text: 'Dibayar', width: 6),
          PosColumn(
              text: _formatCurrency(amountPaid),
              width: 6,
              styles: PosStyles(align: PosAlign.right)),
        ]);

        bytes += generator.row([
          PosColumn(text: 'Kembali', width: 6, styles: PosStyles(bold: true)),
          PosColumn(
              text: _formatCurrency(
                  amountPaid - lastTransaction.transactionTotal),
              width: 6,
              styles: PosStyles(align: PosAlign.right, bold: true)),
        ]);
      }

      bytes += generator.hr();

      // Customer information
      if (customerName != null && customerName.isNotEmpty) {
        bytes += generator.text(
          "Customer: $customerName",
          styles: PosStyles(align: PosAlign.left),
        );
      }

      bytes += generator.feed(2);

      // Footer
      if (settingFooter != null && settingFooter.isNotEmpty) {
        bytes += generator.text(
          settingFooter,
          styles: PosStyles(align: PosAlign.center),
        );
      }

      // Add final feeds and cut
      bytes += generator.feed(3);
      bytes += generator.cut();

      // Send data to printer in chunks
      for (var i = 0; i < bytes.length; i += chunkSize) {
        var end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await printerCharacteristic.write(bytes.sublist(i, end));
      }

      debugPrint("Receipt printed successfully");
    } catch (e) {
      debugPrint("Error printing receipt: $e");
      rethrow;
    } finally {
      await device.disconnect();
    }
  }

  static Future<void> printBarcode(
    BluetoothDevice device, {
    required String barcodeText,
    String? productName,
    String? productPrice,
    bool includeName = false,
    bool includePrice = false,
  }) async {
    try {
      await device.connect(timeout: const Duration(seconds: 5));

      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? printerCharacteristic;

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            printerCharacteristic = characteristic;
            break;
          }
        }
      }

      if (printerCharacteristic == null) {
        throw Exception("Printer characteristic not found");
      }

      // Load receipt settings
      final loadReceipt = await DatabaseService.instance.getSettingReceipt();
      final currentReceiptSize = loadReceipt['settingReceiptSize'];

      // Initialize printer generator
      final profile = await CapabilityProfile.load();
      final Generator generator = currentReceiptSize == '58'
          ? Generator(PaperSize.mm58, profile)
          : Generator(PaperSize.mm80, profile);

      List<int> bytes = [];
      final List<dynamic> barcodeData = barcodeText.split("");

      // Format price if included
      final formattedPrice = productPrice != null
          ? "Rp. ${_formatCurrency(int.parse(productPrice))}"
          : null;

      // Add barcode and optional text
      bytes += generator.feed(6);
      bytes += generator.barcode(
        Barcode.code128(barcodeData),
        textPos: BarcodeText.none,
        height: barcodeText.length > 20 ? 130 : 110,
        align: PosAlign.center,
        width: 2,
      );

      bytes += generator.text(
        barcodeText,
        styles: PosStyles(align: PosAlign.center),
      );

      if (includeName && productName != null) {
        bytes += generator.text(
          productName,
          styles: PosStyles(align: PosAlign.center),
        );
      }

      if (includePrice && formattedPrice != null) {
        bytes += generator.text(
          formattedPrice,
          styles: PosStyles(align: PosAlign.center),
        );
      }

      bytes += generator.feed(6);

      // Send data to printer
      for (var i = 0; i < bytes.length; i += chunkSize) {
        var end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await printerCharacteristic.write(bytes.sublist(i, end));
      }

      debugPrint("Barcode printed successfully");
    } catch (e) {
      debugPrint("Error printing barcode: $e");
      rethrow;
    } finally {
      await device.disconnect();
    }
  }

  static Future<void> printQRCode(
    BluetoothDevice device, {
    required String qrText,
    String? additionalText,
  }) async {
    try {
      await device.connect(timeout: const Duration(seconds: 5));

      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? printerCharacteristic;

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            printerCharacteristic = characteristic;
            break;
          }
        }
      }

      if (printerCharacteristic == null) {
        throw Exception("Printer characteristic not found");
      }

      // Load receipt settings
      final loadReceipt = await DatabaseService.instance.getSettingReceipt();
      final currentReceiptSize = loadReceipt['settingReceiptSize'];

      // Initialize printer generator
      final profile = await CapabilityProfile.load();
      final Generator generator = currentReceiptSize == '58'
          ? Generator(PaperSize.mm58, profile)
          : Generator(PaperSize.mm80, profile);

      List<int> bytes = [];

      // Add QR code and optional text
      bytes += generator.feed(6);
      bytes += generator.qrcode(qrText, size: QRSize.size6);

      if (additionalText != null) {
        bytes += generator.feed(2);
        bytes += generator.text(
          additionalText,
          styles: PosStyles(align: PosAlign.center),
        );
      }

      bytes += generator.feed(6);

      // Send data to printer
      for (var i = 0; i < bytes.length; i += chunkSize) {
        var end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await printerCharacteristic.write(bytes.sublist(i, end));
      }

      debugPrint("QR code printed successfully");
    } catch (e) {
      debugPrint("Error printing QR code: $e");
      rethrow;
    } finally {
      await device.disconnect();
    }
  }

  static String _formatCurrency(int amount) {
    final format = NumberFormat("#,###", "id_ID");
    return format.format(amount);
  }

  static Future<void> printCode(BluetoothDevice device,
      {String? codeType,
      required String codeText,
      String? productPrice,
      String? productName}) async {
    try {
      await device.connect();

      List<BluetoothService> services = await device.discoverServices();

      BluetoothCharacteristic? printerCharacteristic;

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            printerCharacteristic = characteristic;
            break;
          }
        }
      }

      if (printerCharacteristic == null) {
        print("Tidak menemukan karakteristik printer.");
        return;
      }

      //* //* //* //* //* //* //* //* //* //* //* //*

      final loadReceipt = await DatabaseService.instance.getSettingReceipt();

      final currentReceipt = loadReceipt['settingReceipt'];
      final currentReceiptSize = loadReceipt['settingReceiptSize'];

      print("hasil: ${currentReceipt}");
      print("hasil: ${currentReceiptSize}");

      //* //* //* //* //* //* //* //* //* //* //* //*

      final profile = await CapabilityProfile.load();
      final Generator generator;
      if (currentReceiptSize == '58') {
        generator = Generator(PaperSize.mm58, profile);
        // Use a logging framework instead of print
        print("Papersize: 58");
      } else if (currentReceiptSize == '80') {
        generator = Generator(PaperSize.mm80, profile);
        // Use a logging framework instead of print
        print("Papersize: 80");
      } else {
        throw Exception("Unsupported paper size");
      }
      List<int> bytes = [];

      // the Barcode.code128() need List<dynamic> so re-initialized and then splited the codeText (rupiah)
      // {A is for allow Special Characters, No Case Sensitive on alphabet, and allow add a number
      //  {B is allow same like A but not allow Special Characters
      // {C is just allow number only
      final List<dynamic> barcdA = codeText.split("");

      // formatting the currency (rupiah)

      final formattedPrice = "Rp. $productPrice";

      print(productPrice);

      if (codeType == 'barcode') {
        bytes += generator.feed(6);
        bytes += generator.barcode(Barcode.code128(barcdA),
            textPos: BarcodeText.none,
            height: codeText.length > 20 ? 130 : 110,
            align: PosAlign.center,
            width: 2);
        bytes +=
            generator.text(codeText, styles: PosStyles(align: PosAlign.center));
        bytes += generator.feed(6);
      } else if (codeType == 'barcodeNama') {
        bytes += generator.feed(6);
        bytes += generator.barcode(Barcode.code128(barcdA),
            textPos: BarcodeText.none,
            height: codeText.length > 20 ? 130 : 110,
            align: PosAlign.center,
            width: 2);

        bytes +=
            generator.text(codeText, styles: PosStyles(align: PosAlign.center));
        bytes += generator.text(productName ?? '',
            styles: PosStyles(align: PosAlign.center));
        bytes += generator.feed(6);
      } else if (codeType == 'barcodeHarga') {
        bytes += generator.feed(6);
        bytes += generator.barcode(Barcode.code128(barcdA),
            textPos: BarcodeText.none,
            align: PosAlign.center,
            height: codeText.length > 20 ? 130 : 110,
            width: 2);
        bytes +=
            generator.text(codeText, styles: PosStyles(align: PosAlign.center));
        bytes += generator.text(formattedPrice ?? '',
            styles: PosStyles(align: PosAlign.center));
        bytes += generator.feed(6);
      } else if (codeType == 'BarcodeNamaHarga') {
        bytes += generator.feed(6);
        bytes += generator.barcode(Barcode.code128(barcdA),
            textPos: BarcodeText.none,
            align: PosAlign.center,
            height: codeText.length > 20 ? 130 : 110,
            width: 2);
        bytes +=
            generator.text(codeText, styles: PosStyles(align: PosAlign.center));
        bytes += generator.text(productName ?? '',
            styles: PosStyles(align: PosAlign.center));
        bytes += generator.text(formattedPrice ?? '',
            styles: PosStyles(align: PosAlign.center));
        bytes += generator.feed(6);
        //* //* //* //* //* //* //*
        //* //* //* //* //* //* //*
        //* //* //* //* //* //* //*
        //* //*
        //*   QRCODE
        //* //*
        //* //* //* //* //* //* //*
        //* //* //* //* //* //* //*
        //* //* //* //* //* //* //*
      } else if (codeType == 'qrcode') {
        bytes += generator.feed(6);
        bytes += generator.qrcode(codeText ?? '', size: QRSize.size6);
        // bytes += generator.text("$codeText",
        // styles: PosStyles(align: PosAlign.center));
        bytes += generator.feed(6);
      } else if (codeType == 'qrcodeNama') {
        bytes += generator.feed(6);
        bytes += generator.qrcode(codeText ?? '', size: QRSize.size6);
        bytes += generator.feed(2);
        bytes += generator.text(productName ?? '',
            styles: PosStyles(align: PosAlign.center));
        bytes += generator.feed(6);
      } else if (codeType == 'qrcodeHarga') {
        bytes += generator.feed(6);
        bytes += generator.qrcode(codeText ?? '', size: QRSize.size6);
        bytes += generator.feed(2);
        bytes += generator.text(formattedPrice ?? '',
            styles: PosStyles(align: PosAlign.center));
        bytes += generator.feed(6);
      } else if (codeType == 'qrcodnnmj,k mmokkkjhgrrrr44444eNamaHarga') {
        bytes += generator.feed(6);
        bytes += generator.qrcode(codeText ?? '', size: QRSize.size6);
        bytes += generator.feed(2);
        bytes += generator.text(productName ?? '',
            styles: PosStyles(align: PosAlign.center));
        bytes += generator.text(formattedPrice ?? '',
            styles: PosStyles(align: PosAlign.center));
        bytes += generator.feed(6);
      } else {
        print("Invalid code type");
        return;
      }

      for (var i = 0; i < bytes.length; i += chunkSize) {
        var end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await printerCharacteristic.write(bytes.sublist(i, end));
      }
      print("Berhasil mencetak Code");
    } catch (e) {
      print("Error saat mencetak: $e");
    } finally {
      await device.disconnect();
    }
  }

  static Future<void> printResi(BluetoothDevice device,
      {required String expedition,
      required String receipt,
      required String buyerName,
      required String explanation}) async {
    try {
      await device.connect();

      List<BluetoothService> services = await device.discoverServices();

      BluetoothCharacteristic? printerCharacteristic;

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            printerCharacteristic = characteristic;
            break;
          }
        }
      }

      if (printerCharacteristic == null) {
        print("Tidak menemukan karakteristik printer.");
        return;
      }

      //* //* //* //* //* //* //* //* //* //* //* //*

      final loadReceipt = await DatabaseService.instance.getSettingReceipt();

      final currentReceipt = loadReceipt['settingReceipt'];
      final currentReceiptSize = loadReceipt['settingReceiptSize'];

      print("hasil: ${currentReceipt}");
      print("hasil: ${currentReceiptSize}");

      //* //* //* //* //* //* //* //* //* //* //* //*

      final profile = await CapabilityProfile.load();
      final Generator generator;
      if (currentReceiptSize == '58') {
        generator = Generator(PaperSize.mm58, profile);
        // Use a logging framework instead of print
        print("Papersize: 58");
      } else if (currentReceiptSize == '80') {
        generator = Generator(PaperSize.mm80, profile);
        // Use a logging framework instead of print
        print("Papersize: 80");
      } else {
        throw Exception("Unsupported paper size");
      }
      List<int> bytes = [];

      final List<dynamic> barcdA = receipt.split("");

      bytes += generator.feed(6);
      bytes += generator.barcode(Barcode.code128(barcdA),
          textPos: BarcodeText.none,
          height: receipt.length > 20 ? 130 : 110,
          align: PosAlign.center,
          width: 2);

      bytes +=
          generator.text(receipt, styles: PosStyles(align: PosAlign.center));

      bytes += generator.feed(1);

      bytes += generator.text(buyerName,
          styles: PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(explanation,
          styles: PosStyles(align: PosAlign.center));

      bytes += generator.feed(3);
      bytes += generator.feed(3);
      bytes += generator.feed(3);
      bytes += generator.feed(3);
      bytes += generator.feed(1);

      for (var i = 0; i < bytes.length; i += chunkSize) {
        var end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await printerCharacteristic.write(bytes.sublist(i, end));
      }
    } catch (e) {
      print("Ada kesalahan ketika mencetak: $e");
    } finally {
      await device.disconnect();
    }
  }
}
