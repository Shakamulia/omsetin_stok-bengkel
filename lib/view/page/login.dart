import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:omsetin_bengkel/providers/appVersionProvider.dart';
import 'package:omsetin_bengkel/services/authService.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/failedAlert.dart';
import 'package:omsetin_bengkel/utils/toast.dart';
import 'package:omsetin_bengkel/view/page/home/home.dart';
import 'package:omsetin_bengkel/view/widget/custom_textfield.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OMSETin Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;
  String appVersion = 'Loading...';

  @override
  void dispose() {
    _serialNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
    });

    try {
      await _authService.loginWithSerialNumber(
        context,
        _serialNumberController.text,
        _passwordController.text,
      );

      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Home(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ));
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      showFailedAlert(context, message: errorMessage);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    var appVersionProvider = AppVersionProvider();
    appVersionProvider.getAppVersion().then((_) {
      setState(() {
        appVersion = appVersionProvider.appVersion;
      });
    });

    _loadRememberedCredentials();
  }

  bool _isPasswordObscured = true;
  void _loadRememberedCredentials() async {
    final secure = FlutterSecureStorage();

    _serialNumberController.text =
        await secure.read(key: 'remember_serial') ?? '';
    _passwordController.text = await secure.read(key: 'remember_pass') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/loginv2.png", // replace with your actual background image path
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 65),
                    Center(
                      child: Image.asset(
                        "assets/images/omsetin.png",
                        width: 200,
                        height: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          children: const [
                            TextSpan(text: 'Jualan Cepat, Laporan Akurat\n'),
                          ],
                        ),
                      ),
                    ),
                    Gap(10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Masukan Nomor Serial dan Password',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 139, 139, 139)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const Gap(15),
                    CustomTextField(
                      fillColor: Colors.grey[200],
                      suffixIcon: null,
                      obscureText: false,
                      hintText: 'Nomor Serial',
                      prefixIcon: const Icon(Icons.onetwothree_rounded),
                      controller: _serialNumberController,
                      maxLines: 1,
                    ),
                    const Gap(15),
                    CustomTextField(
                      suffixIcon: IconButton(
                        icon: _isPasswordObscured
                            ? const Iconify(Ic.twotone_visibility)
                            : Iconify(Ic.twotone_visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                      fillColor: Colors.grey[200],
                      obscureText: _isPasswordObscured,
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_person),
                      controller: _passwordController,
                      maxLines: 1,
                    ),
                    // Row(
                    //   children: [
                    //     Checkbox(
                    //       value: _rememberMe,
                    //       onChanged: (bool? value) {
                    //         setState(() {
                    //           _rememberMe = value ?? false;
                    //         });
                    //       },
                    //       activeColor: secondaryColor,
                    //     ),
                    //     const Text(
                    //       'Ingat aku xixi',
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         color: Color.fromARGB(255, 100, 100, 100),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const Gap(20),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _loading == true ? Colors.white : null,
                          gradient: _loading == true
                              ? null
                              : LinearGradient(
                                  colors: [secondaryColor, secondaryColor],
                                  begin: Alignment(0, 5),
                                  end: Alignment(-0, -2),
                                ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            side: _loading == true
                                ? BorderSide(color: secondaryColor, width: 2)
                                : BorderSide.none,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: _loading == true
                              ? Lottie.asset(
                                  'assets/lottie/loading-2.json',
                                  width: 100,
                                  height: 100,
                                )
                              : Text(
                                  "LOGIN",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const Gap(5),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4.0,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding: const EdgeInsets.only(
                                          top: 20,
                                          bottom: 50,
                                          left: 70,
                                          right: 70),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                          Gap(10),
                                          Lottie.asset(
                                            'assets/lottie/info.json',
                                            width: 120,
                                            height: 120,
                                          ),
                                          Gap(10),
                                          const Text(
                                            'Lupa Nomor Serial atau Password?',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          const Gap(10),
                                          Text(
                                            'Hubungi Admin untuk Melakukan Reset.',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Lupa Password?',
                                style: TextStyle(
                                  color: Colors.blue[400],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Versi $appVersion',
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
