import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omsetin_bengkel/services/authService.dart';
// import 'package:omsetin_bengkel/view/page/home.dart';
import 'package:omsetin_bengkel/view/page/home/home.dart';

class SplashScreenSTF extends StatefulWidget {
  const SplashScreenSTF({super.key});

  @override
  State<SplashScreenSTF> createState() => _SplashScreenSTFState();
}

class _SplashScreenSTFState extends State<SplashScreenSTF> {
  void checkTokenAndNavigate(BuildContext context) async {
    final authService = AuthService();
    final token = await authService.getToken();

    final isExpired = await authService.isTokenExpired(context, token!);
    if (isExpired == false) {
      // Token valid, lanjutkan ke halaman utama
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Home()));
    } else {
      // Token expired atau tidak ada, logout
      await authService.logout(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkTokenAndNavigate(context);
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final authService = AuthService();
  //   authService.getToken().then((token) {
  //     if (token == null) {
  //       authService.logout(context);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(),
                Text("Skip"),
              ],
            ),
            Gap(40),
            Text(
              "Risk Ready",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 50),
            ),
            Gap(20),
            Image.asset(
              "",
              fit: BoxFit.cover,
              width: 500,
              height: 500,
            ),
            Gap(20),
            Text(
              "Boldly risk to accelerate AI and secure a competitive badge",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        maximumSize: Size(double.infinity, 100)),
                    child: Text(
                      "Log In",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        maximumSize: Size(double.infinity, 100)),
                    child: Text(
                      "Sign Up",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
