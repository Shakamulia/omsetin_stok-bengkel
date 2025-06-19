import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/failedAlert.dart';
import 'package:omsetin_bengkel/utils/successAlert.dart';
import 'package:omsetin_bengkel/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gap/gap.dart';

Future<Map<String, dynamic>?> showModalQueue(BuildContext context,
    int queueNumber, bool isAutoReset, bool nonActivateQueue) async {
  return await showDialog(
    context: context,
    builder: (context) {
      bool localIsAutoReset = isAutoReset;

      Future<void> _saveAutoResetPreference(bool value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('isAutoReset')) {
          await prefs.setBool('isAutoReset', false);
        }
        await prefs.setBool('isAutoReset', value);
      }

      int localQueueNumber = queueNumber;
      TextEditingController queueTransactionController =
          TextEditingController(text: localQueueNumber.toString());

      void _incrementQueueNumber() {
        localQueueNumber++;
        queueTransactionController.text = localQueueNumber.toString();
      }

      void _decrementQueueNumber() {
        if (localQueueNumber > 1) {
          localQueueNumber--;
          queueTransactionController.text = localQueueNumber.toString();
        }
      }

      void _resetQueue() {
        localQueueNumber = 0;
        queueTransactionController.text = localQueueNumber.toString();
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
              ),
              height: 300,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Antrian",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _decrementQueueNumber();
                          });
                        },
                        icon: Image.asset(
                          'assets/images/minus.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const Gap(4),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            controller: queueTransactionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              enabled: false,
                              hintText: "Masukkan Nomor Antrian",
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const Gap(4),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _incrementQueueNumber();
                          });
                        },
                        icon: Image.asset(
                          'assets/images/Plus.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'queueNumber': localQueueNumber,
                            'isAutoReset': localIsAutoReset,
                          });

                          _saveAutoResetPreference(localIsAutoReset);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Ubah',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _resetQueue();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Reset antrian otomatis untuk besok?",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: localIsAutoReset,
                    onChanged: (value) {
                      try {
                        setState(() {
                          localIsAutoReset = value;
                        });
                        showSuccessAlert(context,
                            "Berhasil diubah menjadi ${value ? 'Otomatis' : 'Tidak Otomatis'}");
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
              ),
            ),
          );
        },
      );
    },
  );
}
