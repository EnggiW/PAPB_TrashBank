import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Lupapassword extends StatefulWidget {
  const Lupapassword({super.key});

  @override
  _LupapasswordState createState() => _LupapasswordState();
}

class _LupapasswordState extends State<Lupapassword> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  // Fungsi untuk mengirim link reset password ke email
  Future<void> _sendResetPasswordLink(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validasi apakah email valid
      if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
        _showMessage("Masukkan email yang valid.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Kirimkan link reset password menggunakan FirebaseAuth
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _showMessage("Link reset password berhasil dikirim ke $email");
      Navigator.pop(context); // Menutup halaman setelah berhasil

    } on FirebaseAuthException catch (e) {
      // Menangani error Firebase
      _showMessage("Terjadi kesalahan: ${e.message}");
    } catch (e) {
      // Menangani error umum
      _showMessage("Terjadi kesalahan: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk menampilkan pesan menggunakan SnackBar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Lupa Password", style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF3F7D20),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Logo
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/LOGO TRASHBANK.png',
                height: 80,
              ),
            ),
            const SizedBox(height: 20),

            // Ilustrasi Lupa Password
            Image.asset(
              'assets/LUPAPass.png', // Tambahkan ilustrasi di folder assets
              height: 150,
            ),
            const SizedBox(height: 30),

            // Input Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF3F7D20),
                    width: 1.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF3F7D20),
                    width: 1.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Kirim
            _isLoading
                ? const Center(child: CircularProgressIndicator()) // Loading spinner
                : ElevatedButton(
              onPressed: () => _sendResetPasswordLink(emailController.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F7D20),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Kirim Link Reset Password', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),

            // Garis horizontal di atas tombol Masuk
            Row(
              children: const [
                Expanded(
                  child: Divider(
                    color: Color(0xFF3F7D20),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tombol Masuk
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
              child: const Text(
                'Masuk',
                style: TextStyle(color: Color(0xFF3F7D20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
