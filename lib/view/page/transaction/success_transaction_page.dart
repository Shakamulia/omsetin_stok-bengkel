import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/providers/bluetoothProvider.dart';
import 'package:omzetin_bengkel/providers/securityProvider.dart';
import 'package:omzetin_bengkel/utils/bluetoothAlert.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/pinModalWithAnimation.dart';
import 'package:omzetin_bengkel/utils/printer_helper.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/page/home/home.dart';
import 'package:omzetin_bengkel/view/page/transaction/share_struck_page.dart';
import 'package:omzetin_bengkel/view/page/transaction/transactions_page.dart';
import 'package:omzetin_bengkel/view/widget/pinModal.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionSuccessPage extends StatefulWidget {
  final List<Map<String, dynamic>>? products;
  final List<Map<String, dynamic>>? services;
  final transactionId;
  final String? transactionDate;
  final totalPrice;
  final amountPrice;
  final discountAmount;
  final int queueNumber;
  final customerName;

  TransactionSuccessPage({
    required this.products,
    required this.services,
    required this.totalPrice,
    required this.amountPrice,
    this.discountAmount,
    required this.queueNumber,
    this.transactionId,
    this.transactionDate,
    required this.customerName,
  });
  @override
  State<TransactionSuccessPage> createState() => _TransactionSuccessPageState();
}

class _TransactionSuccessPageState extends State<TransactionSuccessPage> {
  late final int queueNumber;

  // Retrieve and increment queue number
  Future<void> _updateQueueNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final nextQueueNumber = prefs.getInt('queueNumber') ?? 0;
    final updatedQueueNumber = nextQueueNumber + 1;
    await prefs.setInt('queueNumber', updatedQueueNumber);
    print("updated queue number: $updatedQueueNumber");
  }

  Future<void> _playSuccessSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/success-3.mp3'));
  }

  @override
  void initState() {
    super.initState();
    _updateQueueNumber();
    _playSuccessSound();
  }

  @override
  Widget build(BuildContext context) {
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);
    var securityProvider = Provider.of<SecurityProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "TRANSAKSI",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment(0, 2),
                      end: Alignment(-0, -2)),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Home())),
                    icon: Stack(
                      children: const [
                        Positioned(
                          top: 0,
                          right: 0,
                          left: 6,
                          bottom: 0,
                          child: Center(
                              child: Iconify(
                                  MaterialSymbols.arrow_back_ios_rounded,
                                  color: Colors.white)),
                        )
                      ],
                    ))),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Lottie.asset('assets/lottie/success_green.json',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                repeat: false,
                animate: true),
            const SizedBox(height: 20),
            Text(
              "Transaksi Berhasil !",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.queueNumber > 0)
              Text(
                "Nomer Antrian : ${widget.queueNumber}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            const SizedBox(height: 15),
            _buildPriceRow(
                "Total Harga :",
                NumberFormat.currency(
                        locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                    .format(widget.totalPrice)),
            _buildPriceRow(
                "Jumlah Bayar :",
                NumberFormat.currency(
                        locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                    .format(widget.amountPrice)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButtonFunction(Icons.print, "Cetak", () {
                  if (securityProvider.kunciCetakStruk) {
                    showPinModalWithAnimation(context,
                        pinModal: PinModal(onTap: () {
                      if (bluetoothProvider.isConnected) {
                        PrinterHelper.printReceiptAndOpenDrawer(
                          context,
                          bluetoothProvider.connectedDevice!,
                          products: widget.products ?? [],
                          services: widget.services ?? [],
                        );
                        showSuccessAlert(context,
                            "Berhasil mencetak, silahkan tunggu sebentar!.");
                      }
                    }));
                  } else {
                    if (bluetoothProvider.isConnected) {
                      PrinterHelper.printReceiptAndOpenDrawer(
                        context,
                        bluetoothProvider.connectedDevice!,
                        products: widget.products ?? [],
                        services: widget.services ?? [],
                      );

                      showSuccessAlert(context,
                          "Berhasil mencetak, silahkan tunggu sebentar!.");
                    } else {
                      showBluetoothAlert2(context);
                    }
                  }

                  print('Products: ${widget.products}');
                  print('Total Price: ${widget.totalPrice}');
                  print('Amount Price: ${widget.amountPrice}');
                }),
                _buildIconButton(Icons.check_circle, "Selesai", Home()),
                _buildIconButton(
                    Icons.share,
                    "Bagikan",
                    SharePage(
                      queueNumber: widget.queueNumber,
                      products: widget.products,
                      transactionId: widget.transactionId,
                      transactionDate: widget.transactionDate,
                      totalPrice: widget.totalPrice,
                      amountPrice: widget.amountPrice,
                      discountAmount: widget.discountAmount,
                    )),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Aksi buat transaksi baru
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TransactionPage(
                                selectedItems: [],
                              )));
                },
                child: Text(
                  "Buat Transaksi Baru",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String title, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            price,
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, Widget destination) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Aksi ketika button di klik
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => destination));
          },
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green.shade200,
            child: Icon(icon, size: 24, color: Colors.green.shade800),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildIconButtonFunction(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green.shade200,
            child: Icon(icon, size: 24, color: Colors.green.shade800),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
