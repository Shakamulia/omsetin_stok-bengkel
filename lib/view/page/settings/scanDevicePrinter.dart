import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/uim.dart';
import 'package:omsetin_stok/providers/bluetoothProvider.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ScanDevicePrinter extends StatefulWidget {
  @override
  _ScanDevicePrinterState createState() => _ScanDevicePrinterState();
}

class _ScanDevicePrinterState extends State<ScanDevicePrinter> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startScan();
  }

  Future<void> requestPermissions() async {
    await Permission.bluetoothScan.request(); // minta izinin nge-scan blutut
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
    await Permission.nearbyWifiDevices.request();
  }

  void startScan() {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!_devices.contains(result.device)) {
          setState(() {
            _devices.add(result.device);
          });
          final device = result.device;
          print("📡 Device found:");
          print("🆔 ID: ${device.remoteId}");
          print("📛 Name: ${device.name}");
          print("💻 Platform Name: ${device.platformName}");
          print("📣 Local Name (adv): ${result.advertisementData.localName}");
          print("🔁 Connectable: ${result.advertisementData.connectable}");
          print(
              "🛰️ Manufacturer Data: ${result.advertisementData.manufacturerData}");
        }
      }
    });

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _isScanning = false;
      });
      FlutterBluePlus.stopScan();
    });
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
                gradient: LinearGradient(colors: [
              secondaryColor,
              primaryColor,
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: AppBar(
              title: Text(
                "SCAN DEVICE PRINTER",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              leading: CustomBackButton(),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Stack(
          children: [
            if (_isScanning)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      child: Lottie.asset('assets/lottie/loadingBLE.json'),
                    ),
                    Gap(20),
                    Text("Mencari perangkat..."),
                  ],
                ),
              )
            else
              _devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black,
                            ),
                            padding: EdgeInsets.all(10),
                            child: Iconify(
                              MaterialSymbols.bluetooth_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          Gap(20),
                          Text("Tidak ada device yang di temukan."),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        if (bluetoothProvider.connectedDevice != null) Gap(10),
                        if (bluetoothProvider.connectedDevice != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Gap(10),
                              Text(
                                "Terhubung",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width <= 400
                                            ? 16
                                            : 20),
                              ),
                            ],
                          ),

                        if (bluetoothProvider.connectedDevice != null) Gap(10),

                        if (bluetoothProvider.connectedDevice != null)
                          GestureDetector(
                            onTap: () async {
                              await bluetoothProvider.disconnectDevice();
                              setState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Gap(10),
                                      const Iconify(
                                        MaterialSymbols.bluetooth_rounded,
                                      ),
                                      const Gap(10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bluetoothProvider.connectedDevice!
                                                    .platformName.isNotEmpty
                                                ? bluetoothProvider
                                                    .connectedDevice!.platformName
                                                : "Unknown Device",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <=
                                                        400
                                                    ? 12
                                                    : 18,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.start,
                                          ),
                                          Text(
                                            bluetoothProvider
                                                .connectedDevice!.id
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <=
                                                        400
                                                    ? 10
                                                    : 16),
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width <=
                                                    400
                                                ? 12
                                                : 16,
                                        vertical:
                                            MediaQuery.of(context).size.width <=
                                                    400
                                                ? 8
                                                : 10),
                                    child: Text(
                                      "Disconnect",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <=
                                                  400
                                              ? 12
                                              : 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (bluetoothProvider.connectedDevice != null)
                          const Gap(20),

                        if (bluetoothProvider.connectedDevice != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Gap(10),
                              Text(
                                "Tersedia",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width <= 400
                                            ? 16
                                            : 20),
                              ),
                            ],
                          ),

                        Expanded(
                          child: ListView.builder(
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Gap(10),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Gap(10),
                                            const Iconify(
                                              MaterialSymbols.bluetooth_rounded,
                                            ),
                                            const Gap(10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _devices[index]
                                                          .name
                                                          .isNotEmpty
                                                      ? _devices[index].name
                                                      : "Unknown Device",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <=
                                                                  400
                                                              ? 12
                                                              : 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.start,
                                                ),
                                                Text(
                                                  _devices[index].id.toString(),
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <=
                                                                  400
                                                              ? 10
                                                              : 16),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        bluetoothProvider.connectedDevice?.id ==
                                                _devices[index].id
                                            ? GestureDetector(
                                                //! Disconnect

                                                onTap: () async {
                                                  await bluetoothProvider
                                                      .disconnectDevice();
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <=
                                                                  400
                                                              ? 12
                                                              : 16,
                                                      vertical:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <=
                                                                  400
                                                              ? 8
                                                              : 10),
                                                  child: Text(
                                                    "Disconnect",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <=
                                                                400
                                                            ? 12
                                                            : 16,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              )
                                            : _isConnecting &&
                                                    bluetoothProvider
                                                            .connectingDevice
                                                            ?.id ==
                                                        _devices[index].id
                                                ? GestureDetector(
                                                    //! isConnecting and cancel
                                                    onTap: () async {
                                                      await bluetoothProvider
                                                          .disconnectDevice();
                                                      setState(() {});
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  _isConnecting ==
                                                                          false
                                                                      ? 16
                                                                      : 43,
                                                              vertical: 10),
                                                      child: Lottie.asset(
                                                          'assets/lottie/loading-connect-bluetooth.json',
                                                          width: 25,
                                                          height: 21),
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    //! connect
                                                    onTap: () async {
                                                      setState(() {
                                                        _isConnecting = true;
                                                        bluetoothProvider
                                                            .setConnectingDevice(
                                                                _devices[
                                                                    index]);
                                                      });
                                                      await bluetoothProvider
                                                          .connectToDevice(
                                                              _devices[index],
                                                              context);
                                                      setState(() {
                                                        _isConnecting = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <=
                                                                  400
                                                              ? 23
                                                              : 26,
                                                          vertical: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <=
                                                                  400
                                                              ? 8
                                                              : 10),
                                                      child: Text(
                                                        "Connect",
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <=
                                                                    400
                                                                ? 12
                                                                : 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // if (_isScanning != null)
                        //   Column(
                        //     children: [
                        //       Text("Connected: ${connectedDevice!.name}"),
                        //       ElevatedButton(
                        //         onPressed: disconnectDevice,
                        //         child: const Text("Disconnect"),
                        //       ),
                        //     ],
                        //   ),
                      ],
                    ),
            Positioned(
              bottom: 40,
              left: 10,
              child: ZoomTapAnimation(
                onTap: _isScanning ? null : startScan,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Iconify(
                    Uim.refresh,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
