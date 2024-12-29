import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tbank/halaman/hasilinput.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF3F7D20); // Primary Green
  static const Color secondaryGreen = Color(0xFF6DAF44); // Lighter Green for background
  static const Color background = Color(0xFFF0F0F0); // Light background color
  static const Color white = Colors.white; // White for text or buttons
  static const Color grey = Colors.grey; // Grey for inactive elements
}

class InputSampahPage extends StatefulWidget {
  final String kategori;

  const InputSampahPage({super.key, required this.kategori});

  @override
  _InputSampahPageState createState() => _InputSampahPageState();
}

class _InputSampahPageState extends State<InputSampahPage> {
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  int points = 0;
  bool isMember = true;
  late String selectedKategori;

  @override
  void initState() {
    super.initState();
    selectedKategori = widget.kategori;
    calculatePoints();
  }

  void calculatePoints() {
    int weight = int.tryParse(weightController.text) ?? 0;
    int multiplier = selectedKategori == 'Elektro' ? 2 : 1;
    setState(() {
      points = isMember ? (weight / 100 * multiplier).floor() : 0;
    });
  }

  // Fungsi untuk mengirimkan notifikasi ke petugas
  Future<void> sendNotification(String name, String phone, String category, int points) async {
    try {
      // Menambahkan notifikasi ke Firestore
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'title': 'Input Sampah Baru',
        'message': 'Pelanggan $name (No. Telepon: $phone) telah memasukkan sampah kategori $category dan mendapatkan $points poin.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> saveData() async {
    if (weightController.text.isEmpty || (isMember && (phoneController.text.isEmpty || nameController.text.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data yang diperlukan')),
      );
      return;
    }

    String phoneNumber = isMember ? phoneController.text.trim() : '';
    String name = isMember ? nameController.text.trim() : 'Non-Anggota';

    try {
      if (isMember) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('data_pelanggan')
            .doc(phoneNumber)  // Gunakan nomor telepon sebagai ID dokumen
            .get();

        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

        if (data == null || !data.containsKey('nama') || data['nama'] != name) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nama atau nomor telepon tidak cocok dengan data pelanggan')),
          );
          return;
        }
      }

      // Simpan data ke Firestore
      await FirebaseFirestore.instance.collection('riwayat').add({
        'kategori': selectedKategori,
        'berat': int.parse(weightController.text),
        'poin': points,
        'tanggal': Timestamp.now(),
        'isMember': isMember,
        'nama': name,
        'no_telepon': phoneNumber,
      });

      // Kirim notifikasi ke petugas setelah input berhasil
      await sendNotification(name, phoneNumber, selectedKategori, points);

      // Navigasi ke halaman Hasil Input
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilInputPage(
            points: points,
            noTelepon: phoneNumber,
            isMember: isMember,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildRiwayatSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Inputan Anda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('riwayat')
                  .orderBy('tanggal', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada riwayat.'));
                }

                var historyList = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    var history = historyList[index].data() as Map<String, dynamic>;
                    var kategori = history['kategori'] ?? 'Tidak diketahui';
                    var berat = history['berat'] ?? 0;
                    var poin = history['poin'] ?? 0;
                    var tanggal = history['tanggal']?.toDate() ?? DateTime.now();
                    var nama = history['nama'] ?? 'Non-Anggota';

                    String formattedDate = "${tanggal.day}-${tanggal.month}-${tanggal.year}";

                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text('$kategori - $nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Berat: $berat gram'),
                            Text('Poin: $poin'),
                            Text('Tanggal: $formattedDate', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, IconData> kategoriIcons = {
      'Botol': Icons.local_drink,
      'Kardus': Icons.inventory_2,
      'Koran': Icons.newspaper,
      'Elektro': Icons.electrical_services,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buang Sampah $selectedKategori',
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      kategoriIcons[selectedKategori] ?? Icons.help_outline,
                      color: AppColors.primaryGreen,
                      size: 60,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedKategori,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ChoiceChip(
                  label: const Text('Botol'),
                  selected: selectedKategori == 'Botol',
                  onSelected: (selected) {
                    setState(() {
                      selectedKategori = 'Botol';
                      calculatePoints();
                    });
                  },
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.secondaryGreen,
                  labelStyle: const TextStyle(color: AppColors.white),
                ),
                ChoiceChip(
                  label: const Text('Kardus'),
                  selected: selectedKategori == 'Kardus',
                  onSelected: (selected) {
                    setState(() {
                      selectedKategori = 'Kardus';
                      calculatePoints();
                    });
                  },
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.secondaryGreen,
                  labelStyle: const TextStyle(color: AppColors.white),
                ),
                ChoiceChip(
                  label: const Text('Koran'),
                  selected: selectedKategori == 'Koran',
                  onSelected: (selected) {
                    setState(() {
                      selectedKategori = 'Koran';
                      calculatePoints();
                    });
                  },
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.secondaryGreen,
                  labelStyle: const TextStyle(color: AppColors.white),
                ),
                ChoiceChip(
                  label: const Text('Elektro'),
                  selected: selectedKategori == 'Elektro',
                  onSelected: (selected) {
                    setState(() {
                      selectedKategori = 'Elektro';
                      calculatePoints();
                    });
                  },
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.secondaryGreen,
                  labelStyle: const TextStyle(color: AppColors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Anggota'),
                  selected: isMember,
                  onSelected: (selected) {
                    setState(() {
                      isMember = selected;
                      calculatePoints();
                    });
                  },
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.secondaryGreen,
                  labelStyle: const TextStyle(color: AppColors.white),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Non-Anggota'),
                  selected: !isMember,
                  onSelected: (selected) {
                    setState(() {
                      isMember = !selected;
                      calculatePoints();
                    });
                  },
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.secondaryGreen,
                  labelStyle: const TextStyle(color: AppColors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isMember)
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Masukkan Nomor Telepon',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.white,
                ),
              ),
            if (isMember) const SizedBox(height: 12),
            if (isMember)
              TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Masukkan Nama',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.white,
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              onChanged: (value) => calculatePoints(),
              decoration: InputDecoration(
                labelText: 'Berapa Gram Sampahnya?',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isMember ? '$points Poin' : 'Non-Anggota Tidak Mendapatkan Poin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Konfirmasi',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildRiwayatSection(),
          ],
        ),
      ),
    );
  }
}
