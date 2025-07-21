import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/alert.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/null_data_alert.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/custom_textfield.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';

class InputExpensePage extends StatefulWidget {
  const InputExpensePage({super.key});

  @override
  State<InputExpensePage> createState() => _InputExpensePageState();
}

class _InputExpensePageState extends State<InputExpensePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  Future<void> tambahPengeluaran() async {
    final expenseName = nameController.text.trim();
    final expenseNote = noteController.text.trim();
    final expenseAmount = amountController.text.replaceAll('.', '').trim();

    if (expenseName.isEmpty || expenseNote.isEmpty || expenseAmount.isEmpty) {
      showNullDataAlert(context,
          message: "Harap isi semua kolom yang wajib diisi!");
      return;
    }

    try {
      await _databaseService.addExpense(
        expenseName,
        selectedDate.toIso8601String(),
        expenseNote,
        selectedDate.toIso8601String(),
        int.parse(expenseAmount),
      );
      showSuccessAlert(context, 'Pengeluaran berhasil ditambahkan!');
      Navigator.pop(context, true);
    } catch (e) {
      showErrorDialog(context, 'Gagal menambahkan pengeluaran: $e');
    }
  }

  TextInputFormatter currencyInputFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final formatter = NumberFormat.currency(
        locale: 'id',
        symbol: '',
        decimalDigits: 0,
      );
      String newText = newValue.text.replaceAll('.', '');
      if (newText.isNotEmpty) {
        newText = formatter.format(int.parse(newText));
      }
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + 20), // Tambah tinggi AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor, // Warna akhir gradient
                  primaryColor, // Warna awal gradient
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              title: Text(
                'TAMBAH PENGELUARAN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      SizeHelper.Fsize_normalTitle(context), // Perbesar font
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              leading: CustomBackButton(),
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20, // Tambah tinggi toolbar
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextFieldLabel(label: 'Nama Pengeluaran'),
                                CustomTextField(
                                  fillColor: Colors.grey[200],
                                  obscureText: false,
                                  hintText: "Nama Pengeluaran",
                                  prefixIcon: null,
                                  controller: nameController,
                                  maxLines: null,
                                  suffixIcon: null,
                                ),
                                const Gap(10),
                                const TextFieldLabel(label: 'Catatan'),
                                CustomTextField(
                                  fillColor: Colors.grey[200],
                                  obscureText: false,
                                  hintText: "Catatan",
                                  prefixIcon: null,
                                  controller: noteController,
                                  maxLines: 5,
                                  suffixIcon: null,
                                ),
                                const Gap(10),
                                const TextFieldLabel(label: 'Nominal'),
                                CustomTextField(
                                  fillColor: Colors.grey[200],
                                  obscureText: false,
                                  hintText: null,
                                  prefixIcon: null,
                                  controller: amountController,
                                  maxLines: null,
                                  suffixIcon: null,
                                  prefixText: "Rp. ",
                                  keyboardType: TextInputType.number,
                                  inputFormatter: [currencyInputFormatter()],
                                ),
                                const Gap(10),
                                const TextFieldLabel(
                                    label: 'Tanggal Pengeluaran'),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null &&
                                        picked != selectedDate) {
                                      setState(() {
                                        selectedDate = picked;
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ExpensiveFloatingButton(
              right: 12,
              left: 12,
              onPressed: () async {
                await tambahPengeluaran();
              },
            )
          ],
        ),
      ),
    );
  }
}

class TextFieldLabel extends StatelessWidget {
  final String label;

  const TextFieldLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
