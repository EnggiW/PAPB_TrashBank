import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tbank/halaman/hasilinput.dart';
import 'package:tbank/halaman/inputSampah.dart';
import 'package:tbank/halaman/registrasi.dart';
import 'package:tbank/halaman/reset_password.dart';
import 'package:tbank/halaman/rules.dart';
import 'package:tbank/halaman/riwayat.dart';
import 'package:tbank/halaman/user.dart';
import 'firebase_options.dart'; // Pastikan path ini benar
import 'halaman/inputanggota.dart';
import 'halaman/login.dart'; // Layar login
import 'halaman/beranda.dart';
import 'halaman/lupaPassword.dart';
import 'halaman/peringatan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'halaman/provider.dart'; // Import shared_preferences

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding sebelum Firebase diinisialisasi
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Menyediakan ThemeProvider untuk seluruh aplikasi
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadThemePreference(), // Memuat tema saat aplikasi pertama kali dibuka
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mengambil status tema dari ThemeProvider
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trash Bank',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light, // Tema terang
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.green),
          titleTextStyle: TextStyle(color: Colors.green),
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(bodyLarge: TextStyle(color: Colors.black)), // Warna teks untuk tema terang
        iconTheme: IconThemeData(color: Colors.green), // Warna ikon untuk tema terang
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark, // Tema gelap
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF111D13), // Warna latar belakang AppBar di tema gelap
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        scaffoldBackgroundColor: Color(0xFF111D13), // Warna latar belakang di tema gelap
        textTheme: TextTheme(bodyLarge: TextStyle(color: Colors.white)), // Warna teks untuk tema gelap
        iconTheme: IconThemeData(color: Colors.white), // Warna ikon untuk tema gelap
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(username: '',),
        '/beranda': (context) => BerandaPage(username: '', email: ''),
        '/inputSampah': (context) => const InputSampahPage(kategori: '',),
        '/inputananggota': (context) => const InputAnggotaPage(),
        '/hasilinput': (context) => HasilInputPage(points: 0, noTelepon: '', isMember: false,),
        '/user': (context) => const UserPage(),
        '/riwayat': (context) => const RiwayatPage(),
        '/rules': (context) => RulesPage(),
        '/registrasi': (context) => const RegistrasiPage(),
        '/reset_password': (context) => ResetPasswordPage(),
        '/lupaPassword': (context) => Lupapassword(),
      },
    );
  }
}
