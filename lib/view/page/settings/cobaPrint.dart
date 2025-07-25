import 'package:flutter/material.dart';
import 'package:omzetin_bengkel/providers/bluetoothProvider.dart';
import 'package:omzetin_bengkel/utils/printer_helper.dart';
import 'package:provider/provider.dart';

class PrinterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Printer & Cash Drawer')),
      body: Center(
        child: bluetoothProvider.isConnected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Terhubung ke: ${bluetoothProvider.connectedDevice!.name}"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // PrinterHelper.printReceiptAndOpenDrawer(
                      //     bluetoothProvider.connectedDevice!);
                    },
                    child: Text("Print Struk & Buka Cash Drawer"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      bluetoothProvider.disconnectDevice();
                    },
                    child: Text("Disconnect"),
                  ),
                ],
              )
            : Text("Belum ada perangkat yang terhubung"),
      ),
    );
  }
}
