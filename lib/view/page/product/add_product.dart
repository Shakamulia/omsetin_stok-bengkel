import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi_light.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/code.dart';
import 'package:omzetin_bengkel/providers/bluetoothProvider.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/bluetoothAlert.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/failedAlert.dart';
import 'package:omzetin_bengkel/utils/formatters.dart';
import 'package:omzetin_bengkel/utils/image.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/printer_helper.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/page/product/select_category.dart';
import 'package:omzetin_bengkel/view/page/qr_code_scanner.dart';
import 'package:omzetin_bengkel/view/widget/add_category_modal.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math';

import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // db

  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productBarcodeController =
      TextEditingController();
  final TextEditingController _productStockController = TextEditingController();
  final TextEditingController _productSatuanController =
      TextEditingController();
  final TextEditingController _productHargaBeliController =
      TextEditingController(text: '0');
  final TextEditingController _productHargaJualController =
      TextEditingController(text: '0');
  final TextEditingController _productCreateCategoryController =
      TextEditingController();
  final TextEditingController _productCategoryController =
      TextEditingController();
  final TextEditingController _productBarcodeTypeController =
      TextEditingController(text: "barcode");
  final TextEditingController _productBarcodeTextController =
      TextEditingController(text: "Barcode Saja");
  final TextEditingController _profitController = TextEditingController();
  final TextEditingController _lossController = TextEditingController();
  final TextEditingController _productSoldController =
      TextEditingController(text: "0");

  // focus node for add category textfield
  final FocusNode _categoryFocusNode = FocusNode();

  File? image;
  bool _isBarcodeFilled = false;
  bool _isChecked = false;

  String noImage = "assets/products/add-image.png";

  void _checkBarcodeInput() {
    setState(() {
      _productBarcodeController.text.isNotEmpty
          ? _isBarcodeFilled = true
          : _isBarcodeFilled = false;
    });
  }

  void _handleCheckboxChange(bool? value) {
    setState(() {
      _isChecked = value ?? false;
      if (_isChecked) {
        _productStockController.text = '0';
      }
    });
  }

  String _formatCurrency(double value) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  Future<void> scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrCodeScanner()),
    );

    if (result != null && mounted) {
      setState(() {
        _productBarcodeController.text = result;
        _checkBarcodeInput();
      });
    }
  }

  Future pickImage(ImageSource source, context) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      Navigator.pop(context);
      if (pickedImage == null) return;

      final imageTemporary = File(pickedImage.path);
      print(pickedImage);
      setState(() => this.image = imageTemporary);

      final croppedImage = await cropImage(imageTemporary);

      if (croppedImage != null) {
        setState(() {
          image = croppedImage;
        });
      }
    } on PlatformException catch (e) {
      print("Error: $e");
    }
  }

  void _selectCameraOrGalery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => pickImage(ImageSource.camera, context),
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
              onTap: () => pickImage(ImageSource.gallery, context),
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

  void _showBarcodeModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Type Code',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Iconify(
                        Ion.close_circled,
                        color: Colors.white,
                        size: 20,
                      ))
                ],
              ),
              const Gap(10),
              Container(
                decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.only(
                    top: 5, right: 10, bottom: 5, left: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saat ini:',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        Text(
                          _productBarcodeTextController.text,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          backgroundColor: primaryColor,
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: itemQRCode.length,
                itemBuilder: (context, index) {
                  return ZoomTapAnimation(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        // ini untuk teks yang ada di button nya
                        _productBarcodeTextController.text =
                            itemQRCode[index].text;
                        // ini untuk teks yang akan di kirim lewat
                        _productBarcodeTypeController.text =
                            itemQRCode[index].type;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Image.asset(
                                  itemQRCode[index].image,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Text(
                              itemQRCode[index].text,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _productHargaBeliController.addListener(_calculateKeuntungan);
    _productHargaBeliController.addListener(_calculatePersentaseKeuntungan);

    _productHargaJualController.addListener(_calculateKeuntungan);
    _productHargaJualController.addListener(_calculatePersentaseKeuntungan);

    _profitController.addListener(_calculateFromKeuntunganListener);
    _lossController.addListener(_calculateFromPersentaseListener);
  }

  @override
  void dispose() {
    _productHargaBeliController.removeListener(_calculateKeuntungan);
    _productHargaBeliController.removeListener(_calculatePersentaseKeuntungan);

    _productHargaJualController.removeListener(_calculateKeuntungan);
    _productHargaJualController.removeListener(_calculatePersentaseKeuntungan);

    _profitController.removeListener(_calculateFromKeuntunganListener);
    _lossController.removeListener(_calculateFromPersentaseListener);

    _productHargaBeliController.dispose();
    _productHargaJualController.dispose();
    _profitController.dispose();
    _lossController.dispose();
    super.dispose();
  }

  bool _isManualUpdate = false;
  final formatterDecimal = NumberFormat.decimalPattern('id');

  void _calculateKeuntungan() {
    final hargaBeli =
        int.tryParse(_productHargaBeliController.text.replaceAll('.', '')) ?? 0;
    final hargaJual =
        int.tryParse(_productHargaJualController.text.replaceAll('.', '')) ?? 0;
    final keuntungan = hargaJual - hargaBeli;

    _profitController.value = TextEditingValue(
      text: formatterDecimal.format(keuntungan),
      selection: TextSelection.collapsed(
        offset: formatterDecimal.format(keuntungan).length,
      ),
    );
  }

  void _calculatePersentaseKeuntungan() {
    final hargaBeli =
        int.tryParse(_productHargaBeliController.text.replaceAll('.', '')) ?? 0;
    final hargaJual =
        int.tryParse(_productHargaJualController.text.replaceAll('.', '')) ?? 0;

    // Hitung keuntungan (pastikan tidak minus)
    final keuntungan = max(hargaJual - hargaBeli, 0);

    // Hitung persentase (pastikan hargaBeli tidak nol untuk menghindari division by zero)
    final persentaseKeuntungan =
        hargaBeli > 0 ? (keuntungan / hargaBeli * 100) : 0;

    _lossController.value = TextEditingValue(
      text: '${formatterDecimal.format(persentaseKeuntungan)}%',
      selection: TextSelection.collapsed(
        offset: formatterDecimal.format(persentaseKeuntungan).length,
      ),
    );

    // Update profit controller juga
    _profitController.value = TextEditingValue(
      text: formatterDecimal.format(keuntungan),
      selection: TextSelection.collapsed(
        offset: formatterDecimal.format(keuntungan).length,
      ),
    );
  }

  void calculateFromPercentage() {
    final hargaBeli =
        int.tryParse(_productHargaBeliController.text.replaceAll('.', '')) ?? 0;
    final persenStr = _lossController.text
        .replaceAll('%', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final persentase =
        max(double.tryParse(persenStr) ?? 0, 0); // Pastikan tidak minus

    final keuntungan = (hargaBeli * persentase / 100).round();
    final hargaJual =
        hargaBeli + max(keuntungan, 0); // Pastikan keuntungan tidak minus

    _profitController.value = TextEditingValue(
      text: formatterDecimal.format(keuntungan),
      selection: TextSelection.collapsed(
        offset: formatterDecimal.format(keuntungan).length,
      ),
    );

    _productHargaJualController.value = TextEditingValue(
      text: formatterDecimal.format(hargaJual),
      selection: TextSelection.collapsed(
        offset: formatterDecimal.format(hargaJual).length,
      ),
    );
  }

  void calculateFromKeuntungan() {
    final hargaBeli =
        int.tryParse(_productHargaBeliController.text.replaceAll('.', '')) ?? 0;
    final keuntungan = max(
        int.tryParse(_profitController.text.replaceAll('.', '')) ?? 0,
        0); // Pastikan tidak minus

    final hargaJual = hargaBeli + keuntungan;
    final persentase = hargaBeli > 0 ? (keuntungan / hargaBeli * 100) : 0;

    _productHargaJualController.value = TextEditingValue(
      text: formatterDecimal.format(hargaJual),
      selection: TextSelection.collapsed(
        offset: formatterDecimal.format(hargaJual).length,
      ),
    );

    _lossController.value = TextEditingValue(
      text: '${formatterDecimal.format(persentase)}%',
      selection: TextSelection.collapsed(
        offset: formatterDecimal.format(persentase).length,
      ),
    );
  }

  void _calculateFromKeuntunganListener() {
    if (_isManualUpdate) return;

    if (_productHargaBeliController.text.isNotEmpty &&
        _profitController.text.isNotEmpty) {
      _isManualUpdate = true;
      calculateFromKeuntungan();
      _isManualUpdate = false;
    }
  }

  void _calculateFromPersentaseListener() {
    if (_isManualUpdate) return;

    if (_productHargaBeliController.text.isNotEmpty &&
        _lossController.text.isNotEmpty) {
      _isManualUpdate = true;
      calculateFromPercentage();
      _isManualUpdate = false;
    }
  }

  Future<void> _createNewProduct() async {
    String productImage;

    final productName = _productNameController.text;

    // Simpan gambar ke direktori yang diinginkan
    if (image == null || image!.path.isEmpty) {
      productImage = "assets/products/no-image.png";
    } else {
      final directory = await getExternalStorageDirectory();
      final productDir = Directory('${directory!.path}/product');
      if (!await productDir.exists()) {
        await productDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await image!.copy('${productDir.path}/$fileName');
      productImage = savedImage.path;
    }

    final productBarcode = _productBarcodeController.text;
    final productBarcodeType = _productBarcodeTypeController.text;
    final productStock = _productStockController.text;
    final productSatuan = _productSatuanController.text;
    final productHargaBeli = _productHargaBeliController.text;
    final productHargaJual = _productHargaJualController.text;
    final productDateAdded = DateTime.now().toIso8601String();
    final productCategory = _productCategoryController.text;
    final productSold = _productSoldController.text;

    if (productName.isEmpty ||
        productBarcode.isEmpty ||
        productBarcodeType.isEmpty ||
        // productStock.isEmpty ||
        productHargaBeli.isEmpty ||
        productHargaJual.isEmpty ||
        productSatuan.isEmpty) {
      showNullDataAlert(context,
          message: "Harap isi semua kolom yang wajib diisi!");
      return;
    }

    try {
      _databaseService.addProducts(
        productImage,
        productName,
        productBarcode,
        productBarcodeType,
        0,
        productSatuan,
        int.parse(productSold),
        int.parse(productHargaBeli.replaceAll('.', '')),
        int.parse(productHargaJual.replaceAll('.', '')),
        productCategory,
        productDateAdded,
      );

      showSuccessAlert(
          context, "Berhasil Menambahkan Spare Part $productName!");
      Navigator.pop(context, true);
    } catch (e) {
      showFailedAlert(context, message: "Gagal menambahkan Spare Part: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);
    return Scaffold(
      backgroundColor: bgColor,
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              scrolledUnderElevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              titleSpacing: 0,
              leading: const CustomBackButton(),
              title: Text(
                'TAMBAH SPARE PART',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          _selectCameraOrGalery();
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: image != null
                                    ? Image.file(
                                        image!,
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        noImage,
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            if (image != null)
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
                                      image = null;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom:
                                  10, // Adjust this value to move the button higher or lower
                              right:
                                  10, // Adjust this value to move the button left or right
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const IconButton(
                                  icon: Iconify(
                                    Bi.camera_fill,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              _checkBarcodeInput();
                            },
                            controller: _productBarcodeController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: cardColor,
                              hintText: "Barcode",
                              hintStyle: const TextStyle(fontSize: 17),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20)),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20)),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                            maxLines: 1,
                          ),
                        ),
                        ElevatedButton(
                            onPressed: scanQRCode,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              minimumSize: const Size(0, 55),
                            ),
                            child: const Icon(
                              Icons.barcode_reader,
                              color: Colors.white,
                              size: 25,
                            )),
                      ],
                    ),
                    _isBarcodeFilled
                        ? Column(
                            children: [
                              const Gap(8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        elevation: 0,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: _showBarcodeModal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _productBarcodeTextController
                                                    .text.isEmpty
                                                ? 'Barcode Saja'
                                                : _productBarcodeTextController
                                                            .text.length >
                                                        6
                                                    ? '${_productBarcodeTextController.text.substring(0, 7)}...'
                                                    : _productBarcodeTextController
                                                        .text,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Icon(
                                              Icons.keyboard_arrow_down_rounded)
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Gap(5),
                                  Expanded(
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (bluetoothProvider.isConnected) {
                                              PrinterHelper.printCode(
                                                  bluetoothProvider
                                                      .connectedDevice!,
                                                  codeType:
                                                      _productBarcodeTypeController
                                                          .text,
                                                  codeText:
                                                      _productBarcodeController
                                                          .text,
                                                  productName:
                                                      _productNameController
                                                          .text,
                                                  productPrice:
                                                      _productHargaJualController
                                                          .text);
                                            } else {
                                              showBluetoothAlert(context);
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Iconify(
                                                Ion.printer,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              Gap(5),
                                              Expanded(
                                                child: Text(
                                                  "Cetak Barcode",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontFamily: 'Poppins'),
                                                ),
                                              ),
                                            ],
                                          )))
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    const Gap(45),
                    const Text(
                      "Nama Spare Part",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                    const Gap(10),
                    CustomTextField(
                        fillColor: cardColor,
                        obscureText: false,
                        hintText: "Nama Spare Part",
                        prefixIcon: const Icon(Icons.shopping_bag_rounded),
                        controller: _productNameController,
                        maxLines: 1,
                        suffixIcon: null),
                    if (!_isChecked) const Gap(15),
                    const Text(
                      "Satuan Spare Part",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                    const Gap(10),
                    CustomTextField(
                      fillColor: cardColor,
                      hintText: "Satuan Spare Part",
                      prefixIcon: const Icon(Icons.shopping_cart_checkout),
                      controller: _productSatuanController,
                      maxLines: 1,
                      obscureText: false,
                      suffixIcon: null,
                    ),
                    const Gap(15),
                    const Text(
                      "Harga Beli",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                    const Gap(10),
                    CustomTextField(
                      fillColor: cardColor,
                      hintText: "Harga Beli",
                      prefixIcon: const Icon(Icons.calculate),
                      controller: _productHargaBeliController,
                      maxLines: 1,
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                        currencyInputFormatter(),
                      ],
                      prefixText: _productHargaBeliController.text.length <= 3
                          ? "Rp. "
                          : "Rp ",
                      obscureText: false,
                      suffixIcon: null,
                      keyboardType: TextInputType.number,
                    ),
                    const Gap(15),
                    const Text(
                      "Presentase Keuntungan",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                    const Gap(10),
                    CustomTextField(
                      fillColor: cardColor,
                      hintText: "Persentase Keuntungan",
                      prefixIcon: null,
                      controller: _lossController,
                      maxLines: 1,
                      obscureText: false,
                      suffixIcon: null,
                      keyboardType: TextInputType.number,
                      inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const Gap(5),
                    Text(
                      "Harga Jual",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                    const Gap(10),
                    CustomTextField(
                        fillColor: cardColor,
                        hintText: "Harga Jual",
                        prefixIcon: const Icon(Icons.calculate),
                        controller: _productHargaJualController,
                        maxLines: 1,
                        prefixText: _productHargaJualController.text.length <= 3
                            ? "Rp. "
                            : "Rp ",
                        obscureText: false,
                        readOnly: false,
                        suffixIcon: null,
                        keyboardType: TextInputType.number,
                        inputFormatter: [
                          FilteringTextInputFormatter.digitsOnly,
                          currencyInputFormatter()
                        ]),
                    const Gap(15),
                    Text(
                      "Keuntungan",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                    const Gap(10),
                    CustomTextField(
                      fillColor: cardColor,
                      hintText: "Keuntungan",
                      prefixIcon: null,
                      controller: _profitController,
                      maxLines: 1,
                      prefixText:
                          _profitController.text.length <= 3 ? "Rp. " : "Rp ",
                      obscureText: false,
                      suffixIcon: null,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                        currencyInputFormatter()
                      ],
                      // readOnly: true,
                    ),
                    const Gap(78)
                  ],
                ),
              ),
              ExpensiveFloatingButton(
                onPressed: () => _createNewProduct(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
