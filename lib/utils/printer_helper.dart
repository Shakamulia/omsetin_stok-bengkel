import 'dart:io';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:esc_pos_utils_plus/src/barcode.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'package:omsetin_stok/model/transaction.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterHelper {
  static Future<void> printReceiptAndOpenDrawer(
      BuildContext context, BluetoothDevice device,
      {int? transactionId,
      required List<Map<String, dynamic>> products}) async {
    try {
      await device.connect();

      List<BluetoothService> services = await device.discoverServices();
      final DatabaseService _databaseService = DatabaseService.instance;
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

      // Fetch all transactions
      List<TransactionData> allTransactions =
          await _databaseService.getTransaction();

      // Get the last transaction

      TransactionData lastTransaction = allTransactions.last;
      print("Last Transaction Data:");
      print("ID: ${lastTransaction.transactionId}");
      print("Date: ${lastTransaction.transactionDate}");
      print("Total: ${lastTransaction.transactionTotal}");
      print("Method: ${lastTransaction.transactionPaymentMethod}");
      print("Cashier: ${lastTransaction.transactionCashier}");
      print("Customer: ${lastTransaction.transactionCustomerName}");
      print("Discount: ${lastTransaction.transactionDiscount}");
      print("Note: ${lastTransaction.transactionNote}");
      print("Tax: ${lastTransaction.transactionTax}");
      print("Status: ${lastTransaction.transactionStatus}");
      print("Quantity: ${lastTransaction.transactionQuantity}");
      print("Products: ${lastTransaction.transactionProduct}");
      print("Queue Number: ${lastTransaction.transactionQueueNumber}");

      final loadReceipt = await DatabaseService.instance.getSettingReceipt();

      final currentReceipt = loadReceipt['settingReceipt'];
      final currentReceiptSize = loadReceipt['settingReceiptSize'];
      final currentImage = loadReceipt['settingImage'];

      print("hasil: ${currentReceipt}");
      print("hasil: ${currentReceiptSize}");

      //* //* //* //* //* //* //* //* //* //* //* //*

      final loadProfile = await DatabaseService.instance.getSettingProfile();
      final settingFooter = loadProfile['settingFooter'];
      final settingAddress = loadProfile['settingAddress'];
      final settingName = loadProfile['settingName'];

      final profile = await CapabilityProfile.load();
      final Generator generator;
      if (currentReceiptSize == '58') {
        generator = Generator(PaperSize.mm58, profile);
        print("Papersize: 58");
      } else if (currentReceiptSize == '80') {
        generator = Generator(PaperSize.mm80, profile);
        print("Papersize: 80");
      } else {
        throw Exception("Unsupported paper size");
      }

      List<int> bytes = [];

      // ! image

      // Open the cash drawer
      final prefs = await SharedPreferences.getInstance();
      final isCashdrawerOn = prefs.getBool('isCashdrawerOn') ?? false;

      if (isCashdrawerOn) {
        bytes += generator.drawer();
      }

      if (currentImage == "assets/products/no-image.png") {
        final ByteData data = await rootBundle.load(currentImage!);
        final Uint8List imgBytes = data.buffer.asUint8List();
        final img.Image? image = img.decodeImage(imgBytes);
        if (image != null) {
          final img.Image resizedImage = img.copyResize(image, width: 200);
          bytes += generator.image(resizedImage);
        }
      } else if (currentImage != null && currentImage.isNotEmpty) {
        try {
          final File imageFile = File(currentImage);
          final Uint8List imgBytes =
              await imageFile.readAsBytes(); // Read image file as bytes
          final img.Image? image = img.decodeImage(imgBytes); // Decode image
          if (image != null) {
            final img.Image resizedImage =
                img.copyResize(image, width: 200); // Resize image
            bytes +=
                generator.image(resizedImage); // Add resized image to receipt
          }
        } catch (e) {
          print("Error loading image: $e");
        }
      } else {
        print("Image path is null or empty");
      }

      // ! NAME & ADDRESS

      if (settingName == '' || settingName!.isEmpty) {
        bytes += generator.text('-',
            styles: PosStyles(align: PosAlign.center, bold: true));
      } else {
        bytes += generator.text(settingName,
            styles: PosStyles(align: PosAlign.center, bold: true));
      }

      if (settingAddress == '' || settingAddress!.isEmpty) {
        bytes += generator.text('-', styles: PosStyles(align: PosAlign.center));
      } else {
        bytes += generator.text(settingAddress,
            styles: PosStyles(align: PosAlign.center));
      }

      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(text: 'Id Transaksi', width: 6),
        PosColumn(
            text:
                '#${lastTransaction.transactionId.toString().padLeft(3, '0')}',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);

      //! DATE
      bytes += generator.row([
        PosColumn(text: lastTransaction.transactionDate, width: 12),
      ]);

      //! CASHIER
      bytes += generator.row([
        PosColumn(text: 'Kasir', width: 6),
        PosColumn(
            text: lastTransaction.transactionCashier,
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);

      //! QUEUE
      bytes += generator.row([
        PosColumn(text: 'Antrian', width: 6),
        PosColumn(
            text: lastTransaction.transactionQueueNumber.toString(),
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);

      // bytes += generator.row([
      //   PosColumn(text: 'Queue Number', width: 6),
      //   PosColumn(
      //   text: updatedQueueNumber.toString(),
      //   width: 6,
      //   styles: PosStyles(align: PosAlign.right)),
      // ]);

      bytes += generator.hr();

      //! Print product details
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

      // final items = [
      //   {'name': 'Item 1', 'quantity': 2, 'price': 5000},
      //   {'name': 'Item 2', 'quantity': 1, 'price': 10000},
      //   {'name': 'Item 3', 'quantity': 3, 'price': 3000},
      // ];

      // // Loop through each item and add to receipt
      // for (var item in items) {
      //   final subtotalPerItem =
      //       _formatCurrency((item['quantity'] as int) * (item['price'] as int));

      //   bytes += generator.text(item['name'] as String,
      //       styles: PosStyles(bold: true));
      //   bytes += generator.row([
      //     PosColumn(
      //         text:
      //             '${_formatCurrency(item['quantity'] as int)} x ${_formatCurrency(item['price'] as int)}',
      //         width: 4,
      //         styles: PosStyles(align: PosAlign.left)),
      //     PosColumn(
      //         text: subtotalPerItem,
      //         width: 8,
      //         styles: PosStyles(
      //           align: PosAlign.right,
      //         )),
      //   ]);
      // }

      // bytes += generator.hr();
      // // Calculate total price
      // final totalPrice = items.fold<int>(
      //     0,
      //     (sum, item) =>
      //         sum +
      //         ((item['quantity'] as int? ?? 0) * (item['price'] as int? ?? 0)));

      // bytes += generator.row([
      //   PosColumn(
      //       text: "Discount",
      //       width: 4,
      //       styles: PosStyles(align: PosAlign.left)),
      //   PosColumn(
      //       text: _formatCurrency(), width: 8, styles: PosStyles(align: PosAlign.right))
      // ]);

      // bytes += generator.row([
      //   PosColumn(
      //       text: "Subtotal",
      //       width: 4,
      //       styles: PosStyles(align: PosAlign.left)),
      //   PosColumn(
      //       text: _formatCurrency(totalPrice),
      //       width: 8,
      //       styles: PosStyles(align: PosAlign.right))
      // ]);

      //! STATUS
      bytes += generator.row([
        PosColumn(text: 'Status', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: lastTransaction.transactionStatus,
            width: 6,
            styles: PosStyles(align: PosAlign.right, bold: true)),
      ]);

      //! DISCOUNT
      if (lastTransaction.transactionDiscount != 0) {
        bytes += generator.row([
          PosColumn(
              text: "Diskon",
              width: 4,
              styles: PosStyles(align: PosAlign.left)),
          PosColumn(
              text: _formatCurrency(lastTransaction.transactionDiscount),
              width: 8,
              styles: PosStyles(align: PosAlign.right))
        ]);
      }

      final totalAmount = products.fold<int>(
          0,
          (sum, product) =>
              sum +
              (product['quantity'] as int) *
                  (product['product_sell_price'] as int));

      //! SUBTOTAL

      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 6, styles: PosStyles()),
        PosColumn(
            text: _formatCurrency(totalAmount),
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);

      //! TOTAL

      bytes += generator.row([
        PosColumn(text: 'Total', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: _formatCurrency(lastTransaction.transactionTotal),
            width: 6,
            styles: PosStyles(align: PosAlign.right, bold: true)),
      ]);

      bytes += generator.hr();

      //! CUSTOMER

      bytes += generator.text(
          "Customer: ${lastTransaction.transactionCustomerName}",
          styles: PosStyles(align: PosAlign.left));

      bytes += generator.feed(2);

      //! FOOTER FROM PROFILE

      bytes += generator.text(settingFooter ?? '',
          styles: PosStyles(align: PosAlign.center));

      //! BARCODE
      // const String bau = "MAKAN tefa MAKAN tefa MAKAN tefa MAKAN tefa  MAKAN tefa MAKAN tefa MAKAN tefa";
      // final List<dynamic> barcdA = "{A$bau".split("");
      // bytes += generator.text("code128 A");
      // bytes += generator.barcode(Barcode.code128(barcdA),
      //     textPos: BarcodeText.none,
      //     height: bau.length > 20 ? 130 : 110,
      //     width: 2);

      // bytes +=
      //     generator.text("$bau", styles: PosStyles(align: PosAlign.center));

      //! QRCODE
      // bytes += generator.qrcode(bau, size: QRSize.size6);
      // bytes += generator.text(bau, styles: PosStyles(align: PosAlign.center));

      //! CETAK RESI
      // const String bau = "MAKAN MAKAN MAKAN MAKAN MAKAN MAKA NMAKAN";

      // const jasa = "Express";
      // bytes += generator.text(jasa,
      //     styles: PosStyles(
      //         bold: true,
      //         height: PosTextSize.size2,
      //         width: PosTextSize.size2,
      //         align: PosAlign.center));

      // bytes += generator.feed(1);

      // final List<dynamic> barcdA = "{A$bau".split("");
      // bytes += generator.barcode(Barcode.code128(barcdA),
      //     textPos: BarcodeText.none,
      //     height: bau.length > 20 ? 130 : 110,
      //     width: 2);

      // bytes +=
      //     generator.text("$bau", styles: PosStyles(align: PosAlign.center));

      // bytes += generator.feed(1);

      // bytes += generator.text("nabildr.tech",
      //     styles: PosStyles(bold: true, align: PosAlign.center));
      // bytes += generator.text("Nonton Anime di https://watch.nabildr.tech",
      //     styles: PosStyles(align: PosAlign.center));

      bytes += generator.feed(3);
      bytes += generator.feed(3);

      for (var i = 0; i < bytes.length; i += chunkSize) {
        var end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await printerCharacteristic.write(bytes.sublist(i, end));
      }
      print("Struk berhasil dicetak.");
    } catch (e) {
      print("Error saat mencetak: $e");
    } finally {
      await device.disconnect();
    }
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

  static const int chunkSize = 245;

  static String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
