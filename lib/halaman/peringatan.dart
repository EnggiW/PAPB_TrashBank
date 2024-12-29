import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarningPage extends StatelessWidget {
  const WarningPage({super.key});

  Future<void> _setWarningStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasSeenWarning', true); // Tandai peringatan sudah dilihat

    String routeName = '/beranda';
    print('Navigating to route: $routeName');

    Navigator.of(context).pushReplacementNamed(routeName);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon peringatan dengan animasi
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.6),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.orange,
                    size: 60,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Pesan peringatan
              const Text(
                'Penting! Sebelum memulai pekerjaan, pastikan Anda sudah membaca SOP dan aturan yang berlaku. Semoga hari Anda produktif dan menyenangkan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              // Tombol OK yang lebih modern
              ElevatedButton(
                onPressed: () {
                  _setWarningStatus(context); // Tandai peringatan telah dilihat dan kembali ke halaman beranda
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: const Color(0xFF4CAF50), // Warna hijau
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Saya Mengerti',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
