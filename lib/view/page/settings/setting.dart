import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/model/settingProfitType.dart';
import 'package:omzetin_bengkel/providers/bluetoothProvider.dart';
import 'package:omzetin_bengkel/providers/securityProvider.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/services/db.copy.dart';
import 'package:omzetin_bengkel/services/db_restore.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/failedAlert.dart';
import 'package:omzetin_bengkel/utils/formatters.dart';
import 'package:omzetin_bengkel/utils/pinModalWithAnimation.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/utils/toast.dart';
import 'package:omzetin_bengkel/view/page/settings/paymentManagement.dart';
import 'package:omzetin_bengkel/view/page/settings/scanDevicePrinter.dart';
import 'package:omzetin_bengkel/view/page/settings/selectTemplate.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/confirm_delete_dialog.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:omzetin_bengkel/view/widget/pinModal.dart';
import 'package:omzetin_bengkel/view/widget/queueActivation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  File? image;
  String noImage = "assets/products/no-image.png";
  String? currentImage;
  bool isSelectingImage = false;

  // profit
  String? _selectedProfitType;
  double _selectedProfit = 0;

  // struk
  String? _selectedTemplateText;
  String? _selectedTemplate;
  String? _selectedTemplatePapperSize;

  // printer
  String? _printerDevice;
  bool? _isPrinterAutoCutOn = false;
  bool? _isPrinterConnected = false;
  bool? _isCashdrawerOn = false;
  bool? _isSoundOn = false;

  final TextEditingController _percentController = TextEditingController();

  //* //* //* //* //* //* //*
  //? CONFIG: GLOBAL VARIABLE
  //?
  //?
  //?
  //?
  //* //* //* //* //* //* //*

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCashdrawerOn = prefs.getBool('isCashdrawerOn') ?? false;
      _isPrinterAutoCutOn = prefs.getBool('isPrinterAutoCutOn') ?? false;
      _isSoundOn = prefs.getBool('isSoundOn') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCashdrawerOn', _isCashdrawerOn!);
    await prefs.setBool('isPrinterAutoCutOn', _isPrinterAutoCutOn!);
    await prefs.setBool('isSoundOn', _isSoundOn!);
  }

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  int queueNumber = 1;
  bool isAutoReset = false;
  bool nonActivateQueue = false;

  Future<void> _loadQueueAndisAutoResetValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      queueNumber = prefs.getInt('queueNumber') ?? 1;
      isAutoReset = prefs.getBool('isAutoReset') ?? false;
      nonActivateQueue = prefs.getBool('nonActivateQueue') ?? false;
    });

    print('''
      loaded: 
      queueNumber: $queueNumber,
      isAutoReset: $isAutoReset
    ''');
  }

  @override
  void initState() {
    super.initState();
    _loadQueueAndisAutoResetValue();
    loadsettingProfitType();
    loadsettingProfit();
    loadSettingTemplate();
    _loadSettings();
    _saveSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //* //* //* //* //* //* //*
  //? load Setting from db
  //?
  //?
  //?
  //?
  //* //* //* //* //* //* //*

  Future<void> loadAllSettingData() async {
    final settingData = await _databaseService.getAllSettings();

    setState(() {});
  }

  Future<void> loadsettingProfitType() async {
    final settingProfitType = await _databaseService.getsettingProfitType();

    setState(() {
      _selectedProfitType = settingProfitType;
    });
    print(_selectedProfitType);
  }

  Future<void> loadsettingProfit() async {
    final settingProfit = await _databaseService.getSettingProfitOrZero();

    setState(() {
      _selectedProfit = settingProfit;
    });
    print('profit: $_selectedProfit');
  }

  Future<void> loadSettingTemplate() async {
    final settingTemplate = await _databaseService.getSettingReceipt();

    setState(() {
      _selectedTemplate = settingTemplate['settingReceipt'];
      _selectedTemplateText = settingTemplate['settingReceipt'] == 'default'
          ? 'Default'
          : "Tanpa Antrian";
      _selectedTemplatePapperSize = settingTemplate['settingReceiptSize'];
    });
    print(_selectedProfitType);
  }

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  //* //* //* //* //* //* //*
  //? IMAGE
  //?
  //?
  //?
  //?
  //?
  //* //* //* //* //* //* //*

  void _changesettingProfitType(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Container(
            color: Colors.white,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            width: 300,
            height: 180,
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Expanded(
                child: ListView.builder(
                  itemCount: itemProfit.length,
                  itemBuilder: (context, index) {
                    final settingProfitType = itemProfit[index];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _selectedProfitType == settingProfitType.profit
                                    ? greenColor
                                    : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedProfitType = settingProfitType.profit;
                            });
                          },
                          child: Text(
                            settingProfitType.profitText,
                            style: TextStyle(
                                color: _selectedProfitType ==
                                        settingProfitType.profit
                                    ? Colors.white
                                    : Colors.black),
                          )),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    "SIMPAN",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]),
          ));
        });
  }

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  //* //* //* //* //* //* //*
  //? SETTING PROFILE
  //?
  //?
  //?
  //?
  //* //* //* //* //* //* //*

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  //* //* //* //* //* //* //*
  //? SWITCH
  //?
  //?
  //?
  //* //* //* //* //* //* //*

  Widget _buildSettingItem(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context)),
        ),
        Switch(
          value: value,
          onChanged: (newValue) async {
            onChanged(newValue);
            try {
              await _saveSettings();
              showSuccessAlert(context, "Berhasil Mengubah $title");
            } catch (e) {
              showFailedAlert(context,
                  message: "Ada kesalahan, silakan lapor ke Admin!.");
            }
          },
          activeColor: Colors.white,
          activeTrackColor: primaryColor,
          inactiveTrackColor: greyColor,
          inactiveThumbColor: primaryColor,
        ),
      ],
    );
  }

  //* //* //* //* //* //* //*
  //? END
  //* //* //* //* //* //* //*

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);
    var securityProvider = Provider.of<SecurityProvider>(context);

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
                gradient: LinearGradient(colors: [
              secondaryColor,
              primaryColor,
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: AppBar(
              leading: const CustomBackButton(),
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              scrolledUnderElevation: 0,
              title: Text(
                'PENGATURAN',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //*
                      //! SETTING PROFIT
                      //!
                      //!
                      //!
                      //*

                      const Gap(10),
                      const _Label(text: "Pengaturan"),
                      const Gap(10),
                      const Gap(10),
                      ButtonPassingData(
                        onPressed: () async {
                          final result = await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const SelectTemplate(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ));

                          if (result != null) {
                            setState(() {
                              _selectedTemplate = result['type'] as String?;
                              _selectedTemplateText =
                                  result['typeText'] as String;
                              _selectedTemplatePapperSize =
                                  result['papperSize'];
                            });
                          }
                        },
                        text:
                            "Template Struk: $_selectedTemplateText | $_selectedTemplatePapperSize",
                      ),
                      const Gap(10),
                      ButtonPassingDataPrinter(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScanDevicePrinter(),
                            ),
                          );
                        },
                        text: "Printer",
                        isConnectedText: (bluetoothProvider.isConnected)
                            ? "Terhubung ke ${bluetoothProvider.connectedDevice?.platformName ?? 'Ada kesalahan'}"
                                        .length >
                                    20
                                ? "${"Terhubung ke ${bluetoothProvider.connectedDevice?.platformName ?? 'Ada kesalahan'}".substring(0, 20)}..."
                                : "Terhubung ke ${bluetoothProvider.connectedDevice?.platformName ?? 'Ada kesalahan'}"
                            : MediaQuery.of(context).size.width <= 400
                                ? "Tidak Terhubung"
                                : "Tidak ada Printer yang Terhubung",
                        isConnected: _isPrinterConnected ?? false,
                      ),
                      const Gap(10),

                      //* //* //* //* //* //*
                      //! SETTING SOUND
                      //!
                      //!
                      //!
                      //* //* //* //* //* //*

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: _Label(text: "Pengaturan Suara"),
                          ),
                          const Divider(
                            indent: 0,
                            endIndent: 0,
                            thickness: 1,
                            color: Colors.black,
                          ),
                          Column(
                            children: [
                              _buildSettingItem('Sound', _isSoundOn ?? false,
                                  (value) {
                                setState(() {
                                  _isSoundOn = value;
                                });
                              }),
                            ],
                          )
                        ],
                      ),

                      //* //* //* //* //* //* //*
                      //! END
                      //* //* //* //* //* //* //*

                      //*
                      //! SETTING PRINTER
                      //!
                      //!
                      //!
                      //*

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: _Label(text: "Pengaturan Printer"),
                          ),
                          const Divider(
                            indent: 0,
                            endIndent: 0,
                            thickness: 1,
                            color: Colors.black,
                          ),
                          Column(
                            children: [
                              _buildSettingItem('Printer AutoCut',
                                  _isPrinterAutoCutOn ?? false, (value) {
                                setState(() {
                                  _isPrinterAutoCutOn = value;
                                });
                              }),
                              _buildSettingItem(
                                  'Cashdrawer', _isCashdrawerOn ?? false,
                                  (value) {
                                setState(() {
                                  _isCashdrawerOn = value;
                                });
                              }),
                            ],
                          )
                        ],
                      ),
                      //* //* //* //* //* //* //*
                      //! END
                      //* //* //* //* //* //* //*

                      //?

                      //?

                      //* //* //* //* //* //*
                      //! SETTING MORE
                      //!
                      //!
                      //!
                      //* //* //* //* //* //*

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: _Label(text: "Pengaturan Lainnya"),
                          ),
                          const Divider(
                            indent: 0,
                            endIndent: 0,
                            thickness: 1,
                            color: Colors.black,
                          ),
                          Column(
                            children: [
                              _spaceBetweenTextAndButton(
                                  title: "Antrian",
                                  buttonText: 'Kelola Antrian',
                                  onPressed: () async {
                                    final result =
                                        await showModalQueueActivation(
                                            context,
                                            queueNumber,
                                            isAutoReset,
                                            nonActivateQueue);
                                    if (result != null) {
                                      print("queue: $result");

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setInt(
                                          'queueNumber', result['queueNumber']);
                                      await prefs.setBool(
                                          'isAutoReset', result['isAutoReset']);
                                      await prefs.setBool('nonActivateQueue',
                                          result['nonActivateQueue']);
                                      setState(() {
                                        queueNumber = result['queueNumber'];
                                      });

                                      _loadQueueAndisAutoResetValue();
                                    }
                                  }),
                              _spaceBetweenTextAndButton(
                                title: "Metode Pembayaran",
                                buttonText: 'Kelola Data',
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => PaymentManagement()));
                                },
                              ),
                            ],
                          )
                        ],
                      ),

                      //* //* //* //* //* //* //*
                      //! END
                      //* //* //* //* //* //* //*

                      //?

                      //* //* //* //* //* //*
                      //! SETTING MORE
                      //!
                      //!
                      //!
                      //!
                      //* //* //* //* //* //*
                      const Gap(10),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BackupRestoreButton(
                              iconify: Iconify(
                                MaterialSymbols.backup,
                                size: 30,
                              ),
                              text: "Backup",
                              onTap: () async {
                                List<Product> products =
                                    await _databaseService.getProducts();
                                await copyDatabaseToStorage(context, products);
                              },
                            ),
                            BackupRestoreButton(
                              iconify: Iconify(
                                MaterialSymbols.settings_backup_restore_rounded,
                                size: 30,
                              ),
                              text: "Restore",
                              onTap: () async {
                                if (securityProvider.kunciRestoreData) {
                                  showPinModalWithAnimation(
                                    context,
                                    pinModal: PinModal(onTap: () async {
                                      await restoreDB(context);
                                    }),
                                  );
                                } else {
                                  await restoreDB(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      //* //* //* //* //* //* //*
                      //! END
                      //* //* //* //* //* //* //*
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BackupRestoreButton extends StatelessWidget {
  final Iconify iconify;
  final String text;
  final VoidCallback onTap;

  const BackupRestoreButton({
    super.key,
    required this.iconify,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          iconify,
          const Gap(10),
          Text(
            text,
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}

class _spaceBetweenTextAndButton extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback? onPressed;

  const _spaceBetweenTextAndButton({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context)),
        ),
        ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              backgroundColor: primaryColor,
              foregroundColor: whiteMerona,
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                  fontSize:
                      SizeHelper.Fsize_spaceBetweenTextAndButton(context)),
            ))
      ],
    );
  }
}

class ButtonPassingDataPrinter extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final String isConnectedText;
  final bool isConnected;

  const ButtonPassingDataPrinter({
    super.key,
    required this.onPressed,
    required this.text,
    required this.isConnectedText,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        minimumSize: const Size(0, 55),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // const Icon(
          //   Icons.abc,
          // ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context),
                  color: Colors.black),
            ),
          ),
          Text(
            isConnectedText,
            style: TextStyle(
                fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context),
                color: isConnected ? gradientSec : Colors.red),
          ),
          const Gap(10),
          const ArrowRight(),
        ],
      ),
    );
  }
}

class ArrowRight extends StatelessWidget {
  const ArrowRight({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Iconify(
      MaterialSymbols.arrow_forward_ios_rounded,
      size: 18,
    );
  }
}

class ButtonPassingData extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;

  const ButtonPassingData({
    super.key,
    this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        minimumSize: const Size(0, 55),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // const Icon(
          //   Icons.abc,
          // ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text ?? "None Selected",
              style: TextStyle(
                  fontSize: SizeHelper.Fsize_spaceBetweenTextAndButton(context),
                  color: Colors.black),
            ),
          ),
          const ArrowRight()
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
              fontSize: SizeHelper.Fsize_settingLabel(context),
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
