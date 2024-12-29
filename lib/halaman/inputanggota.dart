import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'otp.dart'; // Halaman OTP verification

class InputAnggotaPage extends StatefulWidget {
  const InputAnggotaPage({super.key});

  @override
  _InputAnggotaPageState createState() => _InputAnggotaPageState();
}

class _InputAnggotaPageState extends State<InputAnggotaPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Fungsi untuk menghasilkan OTP secara acak
  String generateOtp() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Fungsi untuk mengirim OTP melalui API eksternal
  Future<void> sendOTP(String phoneNumber, String otp) async {
    const String apiUrl = 'https://api.fonnte.com/send';
    const String apiKey = 'oyP6GBW35CD1vNiC2mGr'; // Masukkan API Key Anda

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'target': phoneNumber,
          'message': 'Kode OTP Anda adalah: $otp',
          'countryCode': '62',  // Pastikan menggunakan kode negara yang benar
          'delay': '2',
        },
      );

      if (response.statusCode == 200) {
        print('OTP sent successfully');
      } else {
        print('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  // Fungsi untuk mengirimkan notifikasi ke petugas
  Future<void> sendNotification(String name, String phoneNumber) async {
    try {
      // Menambahkan notifikasi ke Firestore
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'title': 'Anggota Baru Didaftarkan',
        'message': 'Anggota baru bernama $name dengan nomor telepon $phoneNumber telah terdaftar.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Fungsi untuk menyimpan data anggota
  Future<void> saveMemberData() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data')),
      );
      return;
    }

    String phoneNumber = phoneController.text.trim();
    String name = nameController.text.trim();

    try {
      // Cek apakah nomor telepon sudah ada di database
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('data_pelanggan')
          .doc(phoneNumber)  // Gunakan nomor telepon sebagai ID dokumen
          .get();

      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor telepon sudah terdaftar')),
        );
        return;
      }

      // Jika nomor telepon belum ada, simpan data anggota
      await FirebaseFirestore.instance.collection('data_pelanggan').doc(phoneNumber).set({
        'nama': name,
        'no_telepon': phoneNumber,
        'tanggal_daftar': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anggota berhasil didaftarkan')),
      );

      // Clear input fields
      nameController.clear();
      phoneController.clear();

      // Generate OTP
      String otp = generateOtp();

      // Kirim OTP ke nomor telepon
      await sendOTP(phoneNumber, otp);

      // Kirim notifikasi ke petugas setelah anggota berhasil didaftarkan
      await sendNotification(name, phoneNumber);

      // Arahkan ke halaman OTP dengan nomor telepon dan OTP yang dihasilkan
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            phone: phoneNumber,
            otp: otp,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Input Anggota Baru',
          style: TextStyle(
            color: Color(0xFF3F7D20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3F7D20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image and Title
            Center(
              child: Column(
                children: const [
                  Image(
                    image: AssetImage('assets/Lengkapi.png'),
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Lengkapi Data Diri Anggota',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F7D20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Phone Field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm Button
            ElevatedButton(
              onPressed: saveMemberData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F7D20),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Konfirmasi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
