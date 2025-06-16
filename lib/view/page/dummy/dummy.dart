import 'package:flutter/material.dart';

void main() => runApp(KedaiJusApp()); // <-- Lem untuk rekatkan semua lego

class KedaiJusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: JusScreen(), // <-- Pintu masuk
    );
  }
}

class JusScreen extends StatefulWidget {
  @override
  _JusScreenState createState() => _JusScreenState();
}

class _JusScreenState extends State<JusScreen> {
  int jusJeruk = 0; // State: jumlah jus jeruk

  void beliJeruk() {
    setState(() { // <-- Kabarin kalau ada perubahan!
      jusJeruk++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // <-- Ruangan kosong siap diisi
      appBar: AppBar(title: Text("KEDAI JUS")), // Plang nama
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("JUS JERUK - Rp 10.000", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20), // <-- Spasi (seperti batu kosong)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (jusJeruk > 0) jusJeruk--;
                    });
                  }, // Tombol minus
                ),
                Text("$jusJeruk", style: TextStyle(fontSize: 30)), // Jumlah
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: beliJeruk, // <-- Panggil fungsi beli
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "Total: Rp ${jusJeruk * 10000}",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}