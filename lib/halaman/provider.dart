import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Fungsi untuk mengganti tema
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    // Simpan preferensi tema ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners(); // Memberitahu widget yang menggunakan provider untuk rebuild
  }

  // Fungsi untuk memuat pengaturan tema dari SharedPreferences
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false; // Defaultnya terang
    notifyListeners();
  }
}
