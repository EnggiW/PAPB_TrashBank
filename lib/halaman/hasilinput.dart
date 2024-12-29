import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'beranda.dart';

class HasilInputPage extends StatelessWidget {
  final String noTelepon;
  final int points;
  final bool isMember;

  const HasilInputPage({
    super.key,
    required this.noTelepon,
    required this.points,
    required this.isMember,
  });

  // Fungsi untuk mengambil data pelanggan berdasarkan nomor telepon
  Future<DocumentSnapshot> _getUserData() async {
    return await FirebaseFirestore.instance
        .collection('data_pelanggan')
        .doc(noTelepon)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // Warna AppBar hijau
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3F7D20)), // Tombol kembali
          onPressed: () {
            Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Menampilkan tulisan 'Berhasil'
            const Text(
              'Berhasil!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3F7D20), // Warna hijau
              ),
            ),
            const SizedBox(height: 20),

            // Mengganti ikon centang dengan gambar
            Image.asset(
              'assets/berhasil.png', // Gambar yang digunakan, pastikan file berada di folder assets
              width: 165,
              height: 165,
            ),
            const SizedBox(height: 20),

            // Menampilkan poin yang didapat
            Text(
              '+$points Poin',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F7D20), // Warna hijau
              ),
            ),
            const SizedBox(height: 20),

            // Pesan terima kasih
            const Text(
              'Terima Kasih\nSudah Buang Sampah Hari Ini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F7D20),
              ),
            ),
            const SizedBox(height: 30),

            // Judul untuk melanjutkan input sampah
            const Text(
              'Buang Sampah Lagi Yuk!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F7D20),
              ),
            ),
            const SizedBox(height: 20),

            // Pilihan kategori sampah
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _categoryButton(context, 'Botol', Icons.local_drink),
                const SizedBox(width: 20),
                _categoryButton(context, 'Kardus', Icons.inventory_2),
                const SizedBox(width: 20),
                _categoryButton(context, 'Koran', Icons.newspaper),
                const SizedBox(width: 20),
                _categoryButton(context, 'Elektro', Icons.electrical_services),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Navigasi kembali ke halaman BerandaPage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BerandaPage(username: '', email: '',),
                  ),
                      (Route<dynamic> route) => false, // Menghapus semua rute sebelumnya
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F7D20), // Warna tombol hijau
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk kategori sampah
  Widget _categoryButton(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman input sampah dengan kategori yang dipilih
        Navigator.pushNamed(
          context,
          '/inputSampah',
          arguments: title, // Kirim kategori yang dipilih
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF3F7D20), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF3F7D20), size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
