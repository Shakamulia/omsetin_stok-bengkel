// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:omsetin_stok/utils/colors.dart';
// import 'package:omsetin_stok/utils/null_data_alert.dart';
// import 'package:omsetin_stok/view/page/cashier/add_cashier_page.dart';
// import 'package:omsetin_stok/view/page/cashier/select_cashier.dart';
// import 'package:omsetin_stok/view/page/expense/expense_detail.dart';
// import 'package:omsetin_stok/view/page/print_resi/select_expedition.dart';
// import 'package:omsetin_stok/view/widget/custom_textfield.dart';
// import 'package:omsetin_stok/view/widget/pin_input.dart';

// class LoginCashier extends StatefulWidget {
//   const LoginCashier({super.key});

//   @override
//   _LoginCashierState createState() => _LoginCashierState();
// }

// class _LoginCashierState extends State<LoginCashier> {
//   final TextEditingController _cashierController = TextEditingController();
//   final TextEditingController _cashierPinController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _cashierPinController.addListener(() {
//       if (_cashierPinController.text.length == 6) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             List<TextEditingController> pinControllers =
//                 List.generate(6, (index) => TextEditingController());
//             return AlertDialog(
//               backgroundColor: Colors.white,
//               title: Text(
//                 'Masukkan PIN',
//                 style: TextStyle(color: Colors.black),
//               ),
//               content: PinInputWidget(controllers: pinControllers),
//               actions: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey,
//                     elevation: 0,
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Batal',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     elevation: 0,
//                   ),
//                   onPressed: () {
//                     String pin = pinControllers
//                         .map((controller) => controller.text)
//                         .join();
//                     if (pin == _cashierPinController.text) {
//                       Navigator.pop(context);
//                       Navigator.pop(context, {
//                         'cashierName': _cashierController.text,
//                         'cashierPin': _cashierPinController.text
//                       });
//                     } else {
//                       showNullDataAlert(context,
//                           message: "Pin Salah, Silahkan coba kembali.");
//                     }
//                   },
//                   child: Text(
//                     'OK',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _cashierController.dispose();
//     _cashierPinController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 26.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Gap(150),
//                   RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       style: GoogleFonts.poppins(
//                         fontSize: 35,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                       children: const [
//                         TextSpan(text: 'Pilih Kasir'),
//                       ],
//                     ),
//                   ),
//                   const Gap(35),
//                   Image.asset(
//                     'assets/images/Cashier_Icon.png',
//                     height: 100,
//                   ),
//                   const Gap(40),
//                   Align(
//                       alignment: Alignment.centerLeft,
//                       child: TextFieldLabel(label: 'Akun Kasir')),
//                   ElevatedButton(
//                     onPressed: () async {
//                       final selectedCategory = await Navigator.of(context)
//                           .push<Map<String, dynamic>>(
//                         PageRouteBuilder(
//                           opaque: false,
//                           pageBuilder:
//                               (context, animation, secondaryAnimation) {
//                             return FadeTransition(
//                               opacity: animation,
//                               child: SelectCashier(),
//                             );
//                           },
//                           transitionsBuilder:
//                               (context, animation, secondaryAnimation, child) {
//                             return SlideTransition(
//                               position: Tween<Offset>(
//                                 begin: const Offset(0, 1),
//                                 end: Offset.zero,
//                               ).animate(animation),
//                               child: child,
//                             );
//                           },
//                         ),
//                       );

//                       if (selectedCategory != null) {
//                         setState(() {
//                           _cashierController.text =
//                               selectedCategory["cashierName"];
//                               _cashierPinController.text = selectedCategory["cashierPin"];
//                         });
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       backgroundColor: Color.fromARGB(255, 242, 243, 247),
//                       foregroundColor: Colors.grey[800],
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(13)),
//                       ),
//                       minimumSize: const Size(0, 55),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           _cashierController.text.isEmpty
//                               ? "Pilih Kasir"
//                               : _cashierController.text,
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Gap(10),
//                   Align(
//                       alignment: Alignment.centerLeft,
//                       child: TextFieldLabel(label: "Pin")),
//                   CustomTextField(
//                     suffixIcon: null,
//                     fillColor: Color.fromARGB(255, 242, 243, 247),
//                     obscureText: true,
//                     hintText: 'Masukkan Pin',
//                     prefixIcon: null,
//                     controller: null,
//                     maxLines: 1,
//                   ),
//                   const Gap(10),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => AddCashierPage()),
//                       );
//                     },
//                     child: Text(
//                       'Tambah Kasir?',
//                       style: TextStyle(
//                         color: Colors.blue[400],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             child: Container(
//               height: 40,
//               width: MediaQuery.of(context).size.width,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [primaryColor, secondaryColor],
//                   begin: Alignment(0, 2),
//                   end: Alignment(-0, -2),
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 16.0),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Versi 1.0.0',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
