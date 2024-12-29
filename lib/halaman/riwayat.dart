import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Tab untuk Riwayat dan Notifikasi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesan',
          style: TextStyle(
            color: Color(0xFF3F7D20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3F7D20),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF3F7D20),
          tabs: const [
            Tab(text: "Notifikasi"),
            Tab(text: "Riwayat"),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3F7D20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotifikasiList(),
          _buildRiwayatList(),
        ],
      ),
    );
  }

  // Fungsi untuk menambah notifikasi ke Firestore
  Future<void> addNotifikasi(String title, String message, String noTelepon) async {
    await FirebaseFirestore.instance.collection('notifikasi').add({
      'title': title,
      'message': message,
      'no_telepon': noTelepon,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // StreamBuilder untuk menampilkan daftar notifikasi
  Widget _buildNotifikasiList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifikasi')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada notifikasi.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        var notifikasiList = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifikasiList.length,
          itemBuilder: (context, index) {
            var notifikasi = notifikasiList[index].data() as Map<String, dynamic>;
            var title = notifikasi['title'] ?? 'Tidak ada judul';
            var message = notifikasi['message'] ?? 'Tidak ada pesan';
            var noTelepon = notifikasi['no_telepon'] ?? 'Tidak tersedia';
            var isRead = notifikasi['isRead'] ?? false;
            var timestamp = notifikasi['timestamp']?.toDate() ?? DateTime.now();

            String formattedDate = "${timestamp.day}-${timestamp.month}-${timestamp.year}";

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  isRead ? Icons.notifications : Icons.notifications_active,
                  color: isRead ? Colors.grey : const Color(0xFF3F7D20),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F7D20),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message),
                    const SizedBox(height: 5),
                    Text(
                      "Tanggal: $formattedDate",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  // Tandai notifikasi sebagai sudah dibaca
                  FirebaseFirestore.instance
                      .collection('notifikasi')
                      .doc(notifikasiList[index].id)
                      .update({'isRead': true});
                },
              ),
            );
          },
        );
      },
    );
  }

  // StreamBuilder untuk menampilkan daftar riwayat
  Widget _buildRiwayatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('riwayat')
          .orderBy('tanggal', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada riwayat.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        var riwayatList = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: riwayatList.length,
          itemBuilder: (context, index) {
            var riwayat = riwayatList[index].data() as Map<String, dynamic>;
            var kategori = riwayat['kategori'] ?? 'Tidak diketahui';
            var nama = riwayat['nama'] ?? 'Tidak diketahui';
            var noTelepon = riwayat['no_telepon'] ?? 'Tidak tersedia';
            var berat = riwayat['berat'] ?? 0;
            var poin = riwayat['poin'] ?? 0;
            var isMember = riwayat['isMember'] ?? false;
            var tanggal = riwayat['tanggal']?.toDate() ?? DateTime.now();

            String formattedDate = "${tanggal.day}-${tanggal.month}-${tanggal.year}";

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF3F7D20)),
                  ),
                  child: Icon(
                    isMember ? Icons.star : Icons.history,
                    color: const Color(0xFF3F7D20),
                  ),
                ),
                title: Text(
                  kategori,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F7D20),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama: $nama"),
                    Text("No Telepon: $noTelepon"),
                    Text("Berat: $berat kg"),
                    Text("Poin: $poin"),
                    Text(
                      "Tanggal: $formattedDate",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  // Aksi ketika riwayat di-tap (jika ada detail tambahan)
                },
              ),
            );
          },
        );
      },
    );
  }
}
