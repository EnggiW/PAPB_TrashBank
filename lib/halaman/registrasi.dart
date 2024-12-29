import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'otp.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});

  @override
  _RegistrasiPage createState() => _RegistrasiPage();
}

class _RegistrasiPage extends State<RegistrasiPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final birthDateController = TextEditingController();
  final addressController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

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
          'countryCode': '62',
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

  // Fungsi untuk melakukan registrasi
  Future<void> register() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (nameController.text.isEmpty ||
          phoneController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          birthDateController.text.isEmpty ||
          addressController.text.isEmpty) {
        throw Exception("Semua kolom harus diisi!");
      }

      // Validasi nomor telepon
      if (phoneController.text.length < 10) {
        throw Exception("Nomor telepon tidak valid!");
      }

      // Validasi format email
      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
          .hasMatch(emailController.text)) {
        throw Exception("Format email tidak valid!");
      }

      // Validasi password (minimal 6 karakter)
      if (passwordController.text.length < 6) {
        throw Exception("Password harus terdiri dari minimal 6 karakter!");
      }

      // Membuat user baru dengan email dan password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text);

      // Mendapatkan User UID untuk identifikasi
      String uid = userCredential.user!.uid;

      // Mendapatkan tanggal bergabung saat ini
      Timestamp tanggalBergabung = Timestamp.now();

      // Menyimpan data pengguna ke Firestore dengan koleksi data_pengguna
      await FirebaseFirestore.instance.collection('data_pengguna').doc(uid).set({
        'nama': nameController.text.trim(),
        'no_hp': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'alamat': addressController.text.trim(),
        'tgl_lahir': birthDateController.text.trim(),
        'tanggal_bergabung': tanggalBergabung, // Menyimpan tanggal bergabung
      });

      // Menghasilkan OTP dan mengirimkannya
      String otp = generateOtp();
      await sendOTP(phoneController.text.trim(), otp);

      // Pindah ke halaman OTP setelah berhasil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(phone: phoneController.text, otp: otp),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendaftar: ${e.message}")),
      );
      print("FirebaseAuthException: ${e.code} - ${e.message}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
      print("Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/LOGO TRASHBANK.png',
                height: 60,
              ),
              const SizedBox(height: 20),
              const Text(
                'Registrasi & Lengkapi Data Diri Anda',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F7D20),
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Nama Lengkap',
                      icon: Icons.person,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          birthDateController.text =
                              DateFormat('dd MMMM yyyy').format(pickedDate);
                        }
                      },
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: birthDateController,
                          label: 'Tanggal Lahir',
                          icon: Icons.calendar_today,
                          obscureText: false,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: addressController,
                      label: 'Alamat Lengkap',
                      icon: Icons.home,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email,
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: passwordController,
                      label: 'Kata Sandi',
                      icon: Icons.lock,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: phoneController,
                      label: 'Nomor Telepon',
                      icon: Icons.phone,
                      obscureText: false,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          register();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F7D20),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF3F7D20)),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3F7D20)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
