import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:tbank/halaman/beranda.dart';
import 'package:tbank/halaman/login.dart';
import 'dart:convert';
import 'dart:math';
import 'package:tbank/halaman/registrasi.dart'; // Pastikan ini adalah halaman yang tepat

class OTPScreen extends StatefulWidget {
  final String phone;
  String otp; // OTP sekarang bisa berubah, tidak final lagi.

  OTPScreen({
    super.key,
    required this.phone,
    required this.otp,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  int timerSeconds = 60;
  Timer? _timer;
  bool isResendAllowed = false;

  final String apiUrl = 'https://api.fonnte.com/send';
  late String phoneNumber;

  @override
  void initState() {
    super.initState();
    phoneNumber = widget.phone;
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      isResendAllowed = false;
      timerSeconds = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
        } else {
          timer.cancel();
          isResendAllowed = true;
        }
      });
    });
  }

  String generateOtp() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  void verifyOtp() {
    String enteredOtp = otpController.text.trim();

    if (enteredOtp.isEmpty) {
      showSnackBar("Kode OTP tidak boleh kosong");
      return;
    }

    if (enteredOtp == widget.otp) {
      showSnackBar("Kode OTP benar! Anda berhasil masuk.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BerandaPage(username: widget.phone, email: '',)), // Pastikan username di sini sesuai
      );
    } else {
      showSnackBar("Kode OTP tidak valid. Silakan coba lagi.");
    }
  }

  Future<void> resendOtp() async {
    if (!isResendAllowed) return;

    showSnackBar("Mengirim ulang kode OTP...");

    try {
      String newOtp = generateOtp();
      setState(() {
        widget.otp = newOtp;
      });

      await sendOtpToPhone(phoneNumber, newOtp);
      startTimer();
      showSnackBar("Kode OTP baru telah dikirim ke ${widget.phone}");
    } catch (e) {
      showSnackBar("Gagal mengirim ulang OTP. Coba lagi nanti.");
    }
  }

  Future<void> sendOtpToPhone(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'oyP6GBW35CD1vNiC2mGr',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'target': phone,
          'message': 'Kode OTP Baru Anda adalah: $otp',
          'countryCode': '62',
          'delay': '2',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          print("OTP berhasil dikirim ke ${phone}");
        } else {
          print("Gagal kirim OTP: ${data['reason']}");
        }
      } else {
        print("Gagal mengirim OTP. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/otp.png', height: 150),
              Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: Colors.white,
                shadowColor: Colors.black.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      Text(
                        'OTP mu sudah dikirim ke : \n${widget.phone}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F7D20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: otpController,
                        decoration: InputDecoration(
                          labelText: "Kode OTP",
                          labelStyle: TextStyle(color: Colors.green.shade600),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF3F7D20),
                          ),
                          filled: true,
                          fillColor: Colors.green.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "Waktu tersisa: $timerSeconds detik",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: timerSeconds > 0 ? Colors.red.shade700 : const Color(0xFF3F7D20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F7D20),
                          padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: const Text(
                          "Verifikasi",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: isResendAllowed ? resendOtp : null,
                        child: Text(
                          isResendAllowed ? "Kirim Ulang OTP" : "Kirim Ulang OTP (Menunggu...)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isResendAllowed ? const Color(0xFF3F7D20) : Colors.grey,
                          ),
                        ),
                      ),
                    ],
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
