import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // Import provider
import 'provider.dart'; // Import ThemeProvider
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences


class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key, required this.username, required this.email});

  final String username;
  final String email;

  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final searchController = TextEditingController();
  String searchQuery = '';


// Fungsi untuk memeriksa apakah peringatan sudah ditampilkan
  Future<bool> _isWarningDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isWarningDialogShown') ?? false;
  }

// Fungsi untuk menyimpan status bahwa peringatan telah ditampilkan
  Future<void> _setWarningDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isWarningDialogShown', true);
  }
  @override
  void initState() {
    super.initState();

    // Tampilkan dialog peringatan hanya jika belum pernah ditampilkan
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isShown = await _isWarningDialogShown();
      if (!isShown) {
        _showRulesWarningDialog();
        _setWarningDialogShown(); // Set agar peringatan tidak ditampilkan lagi
      }
    });
  }

  // Fungsi untuk menghitung berapa hari sejak bergabung
  int _calculateDaysSinceJoined(Timestamp? joinDate) {
    if (joinDate == null) return 0;
    final joinDateTime = joinDate.toDate();
    final currentDate = DateTime.now();
    return currentDate.difference(joinDateTime).inDays;
  }

  // Fungsi untuk mengambil data pengguna yang sedang login
  Future<DocumentSnapshot?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('data_pengguna')
          .doc(user.uid)
          .get();
    }
    return null;
  }

  // Fungsi untuk mengambil daftar anggota dari Firestore
  Future<QuerySnapshot> _getAnggotaList() async {
    if (searchQuery.isEmpty) {
      return await FirebaseFirestore.instance
          .collection('data_pelanggan')
          .orderBy('tanggal_daftar', descending: true)
          .get();
    } else {
      return await FirebaseFirestore.instance
          .collection('data_pelanggan')
          .where('no_telepon', isGreaterThanOrEqualTo: searchQuery)
          .where('no_telepon', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .get();
    }
  }

  // Fungsi untuk menghitung total poin anggota dari koleksi riwayat
  Future<int> _getTotalPoinAnggota(String noTelepon) async {
    int totalPoin = 0;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('riwayat')
        .where('no_telepon', isEqualTo: noTelepon)
        .get();

    for (var doc in querySnapshot.docs) {
      var poin = doc['poin'] ?? 0; // Default poin adalah 0 jika null
      totalPoin += poin is int ? poin : (poin is double
          ? poin.toInt()
          : 0); // Konversi poin ke int
    }

    return totalPoin;
  }

  // Menampilkan peringatan untuk membaca rules sebelum melakukan pekerjaan
  void _showRulesWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog tidak dapat ditutup dengan tap di luar
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF3F7D20),
              ),
              const SizedBox(width: 10),
              const Text(
                "Peringatan!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Harap baca aturan sebelum melanjutkan pekerjaan Anda.",
            style: TextStyle(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Membuat tombol di tengah
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Menutup dialog
                  },
                  child: const Text('Tutup'),
                ),
                const SizedBox(width: 10), // Jarak antar tombol
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F7D20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Menutup dialog
                    Navigator.pushNamed(context, '/rules'); // Mengarahkan ke halaman rules
                  },
                  child: const Text('Baca Aturan'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengakses status tema dari ThemeProvider
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: FutureBuilder<DocumentSnapshot?>(  // Data pengguna
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (!snapshot.hasData || snapshot.data == null ||
                    !snapshot.data!.exists) {
                  return const Center(child: Text('Data pengguna tidak ditemukan.'));
                }

                var userData = snapshot.data!;
                var userMap = userData.data() as Map<String, dynamic>?;
                var userName = userMap?['nama'] ?? 'Nama tidak tersedia';
                var joinDate = userMap?['tanggal_bergabung'] as Timestamp?;
                int daysWorked = _calculateDaysSinceJoined(joinDate);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(userName, isDarkMode), // Pass isDarkMode to the header
                    const SizedBox(height: 20),
                    _buildWorkDaysCard(daysWorked),
                    const SizedBox(height: 20),
                    _buildBuangSampahSection(),
                    const SizedBox(height: 20),
                    _buildAnggotaSection(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

// Mengubah bagian _buildHeader untuk menerima parameter isDarkMode
  Widget _buildHeader(String userName, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assalamu\'alaikum,',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF3F7D20),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F7D20),
              ),
            ),
          ],
        ),
        // Tombol Ubah Tema di kanan atas
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Color(0xFF3F7D20),
            ),
            onPressed: () {
              // Mengubah tema dengan menggunakan ThemeProvider
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ),
      ],
    );
  }


  Widget _buildWorkDaysCard(int daysWorked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3F7D20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terimakasih, anda sudah bekerja selama:',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            '$daysWorked Hari',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuangSampahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/inputSampah');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F7D20), Color(0xFF2D5A1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete_outline, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Input Sampah Disini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnggotaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Anggota',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F7D20),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/inputananggota');
              },
              child: const Text(
                'Daftarkan Anggota Baru',
                style: TextStyle(color: Color(0xFF3F7D20)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Masukkan Nomor Telepon',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF3F7D20)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3F7D20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3F7D20)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<QuerySnapshot>(
          future: _getAnggotaList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Tidak ada anggota.'));
            }

            var anggotaList = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: anggotaList.length,
              itemBuilder: (context, index) {
                var anggota = anggotaList[index];
                var nama = anggota['nama'] ?? 'Nama tidak tersedia';
                var noTelepon = anggota['no_telepon'] ?? 'Nomor tidak tersedia';
                var tanggalDaftar = anggota['tanggal_daftar']?.toDate() ??
                    DateTime.now();

                String formattedDate = "${tanggalDaftar.day} ${tanggalDaftar.month} ${tanggalDaftar.year}";

                return FutureBuilder<int>(
                  future: _getTotalPoinAnggota(anggota.id),
                  builder: (context, poinSnapshot) {
                    if (poinSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (poinSnapshot.hasError) {
                      return Text("Error: ${poinSnapshot.error}");
                    }

                    int totalPoin = poinSnapshot.data ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F7D20),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(noTelepon),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Tanggal Bergabung: $formattedDate"),
                                Text("Poin: $totalPoin", style: TextStyle(color: Color(0xFF3F7D20), fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Widget Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3F7D20),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/beranda'); // Arahkan ke Beranda
        } else if (index == 1) {
          Navigator.pushNamed(context, '/rules');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/riwayat'); // Arahkan ke Riwayat
        } else if (index == 3) {
          Navigator.pushNamed(context, '/user'); // Arahkan ke Profil
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Rules',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Pesan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

