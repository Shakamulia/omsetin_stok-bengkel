import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_bengkel/model/income.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/formatters.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/view/widget/Income_card.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/custom_textfield.dart';

class IncomeDetailPage extends StatefulWidget {
  final Income? income;

  const IncomeDetailPage({super.key, this.income});

  @override
  State<IncomeDetailPage> createState() => _IncomeDetailPageState();
}

class _IncomeDetailPageState extends State<IncomeDetailPage> {
  String? name;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateAddedController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      name = widget.income!.incomeName;
      amountController.text =
          NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0)
              .format(widget.income!.incomeAmount);
      noteController.text = widget.income!.incomeNote;
      dateAddedController.text = DateFormat('dd/MM/yyyy')
          .format(DateTime.parse(widget.income!.incomeDateAdded));
      nameController.text = name!;
    }
  }

  DateTime selectedDate = DateTime.now();

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
                'DETAIL PEMASUKAN ${IncomeCard.truncate(name!, length: 5)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      SizeHelper.Fsize_normalTitle(context), // Perbesar font
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: primaryColor,
              leading: CustomBackButton(),
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20, // Tambah tinggi toolbar
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
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
                            const TextFieldLabel(label: 'Nama Pemasukan'),
                            CustomTextField(
                              fillColor: Colors.grey[200],
                              obscureText: false,
                              hintText: "Nama Pemasukan...",
                              textColor: const Color.fromARGB(255, 77, 77, 77),
                              prefixIcon: null,
                              readOnly: true,
                              controller: nameController,
                              maxLines: null,
                              suffixIcon: null,
                            ),
                            const Gap(10),
                            const TextFieldLabel(label: 'Catatan'),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 216, 216, 216),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: TextField(
                                  controller: noteController,
                                  readOnly: true,
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 77, 77, 77),
                                  ),
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText:
                                        "Catatan tentang Pemasukan ini...",
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(10),
                            const TextFieldLabel(label: 'Nominal'),
                            CustomTextField(
                                fillColor: Colors.grey[200],
                                obscureText: false,
                                hintText: null,
                                textColor:
                                    const Color.fromARGB(255, 77, 77, 77),
                                prefixIcon: null,
                                controller: amountController,
                                maxLines: null,
                                readOnly: true,
                                suffixIcon: null,
                                prefixText: "Rp. ",
                                keyboardType: TextInputType.number,
                                inputFormatter: [currencyInputFormatter()]),
                            const Gap(10),
                            const TextFieldLabel(label: 'Tanggal Pemasukan'),
                            GestureDetector(
                              onTap: () async {
                                // final DateTime? picked = await showDatePicker(
                                //   context: context,
                                //   initialDate: selectedDate,
                                //   firstDate: DateTime(2000),
                                //   lastDate: DateTime(2101),
                                // );
                                // if (picked != null && picked != selectedDate) {
                                //   setState(() {
                                //     selectedDate = picked;
                                //   });
                                // }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 216, 216, 216),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${DateTime.parse(widget.income!.incomeDate).day}/${DateTime.parse(widget.income!.incomeDate).month}/${DateTime.parse(widget.income!.incomeDate).year}, ${DateFormat.EEEE('id_ID').format(DateTime.parse(widget.income!.incomeDate))}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 77, 77, 77),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(10),
                            const TextFieldLabel(
                                label: 'Tanggal Pemasukan di tambahkan'),
                            GestureDetector(
                              onTap: () async {
                                // final DateTime? picked = await showDatePicker(
                                //   context: context,
                                //   initialDate: selectedDate,
                                //   firstDate: DateTime(2000),
                                //   lastDate: DateTime(2101),
                                // );
                                // if (picked != null && picked != selectedDate) {
                                //   setState(() {
                                //     selectedDate = picked;
                                //   });
                                // }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 216, 216, 216),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${DateTime.parse(widget.income!.incomeDateAdded).day}/${DateTime.parse(widget.income!.incomeDateAdded).month}/${DateTime.parse(widget.income!.incomeDateAdded).year}, ${DateFormat.EEEE('id_ID').format(DateTime.parse(widget.income!.incomeDateAdded))} ${DateFormat('hh:mm a').format(DateTime.parse(widget.income!.incomeDateAdded))}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 77, 77, 77),
                                  ),
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
      ),
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      //   color: Colors.grey[300],
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: primaryColor,
      //       padding: const EdgeInsets.symmetric(vertical: 16),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(8),
      //       ),
      //     ),
      //     onPressed: tambahPemasukan,
      //     child: const Text(
      //       "SIMPAN",
      //       style: TextStyle(
      //           color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // ),
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
