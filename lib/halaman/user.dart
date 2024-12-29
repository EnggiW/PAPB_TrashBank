import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart'; // Pastikan ini sesuai dengan lokasi file ThemeProvider

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fungsi mengambil data user dari Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('data_pengguna') // Koleksi data Firestore
            .doc(user.uid) // Ambil data berdasarkan UID
            .get();

        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengakses status tema dari ThemeProvider
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF111D13) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Color(0xFF3F7D20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profil',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Color(0xFF3F7D20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: isDarkMode ? Color(0xFF111D13) : Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Avatar
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 10),

              // Nama dan Email
              Text(
                userData['nama'] ?? 'Nama Tidak Tersedia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Color(0xFF3F7D20),
                ),
              ),
              Text(
                userData['email'] ?? 'Email tidak tersedia',
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Color(0xFF3F7D20)),
              ),
              Text(
                userData['no_hp'] ?? '+62 000 0000 0000',
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Color(0xFF3F7D20)),
              ),
              const SizedBox(height: 20),

              // Informasi Pengguna
              _infoSection('Nama Petugas', '${userData['nama'] ?? 'nama'}', isDarkMode),
              _infoSection('Alamat Petugas', userData['alamat'] ?? 'Alamat tidak tersedia', isDarkMode),
              _infoSection('Alamat Pusat Perusahaan', 'Jl. Siliwangi Jl. Jombor Lor, Mlati Krajan, Sendangadi, Kec. Mlati, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55284', isDarkMode),

              const SizedBox(height: 20),

              // Tombol Keluar
              OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  side: BorderSide(color: isDarkMode ? Colors.white : Color(0xFF3F7D20)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Keluar',
                  style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Color(0xFF3F7D20)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan bagian informasi
  Widget _infoSection(String title, String content, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF3F7D20),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black),
          ),
          const Divider(color: Colors.black26, height: 20),
        ],
      ),
    );
  }
}
