import 'package:flutter/material.dart';

class RulesPage extends StatefulWidget {
  RulesPage({Key? key}) : super(key: key);

  @override
  _RulesPageState createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // Daftar SOP
  final List<Map<String, String>> sop = [
    {"title": "Verifikasi Data Pelanggan", "description": "Pastikan semua data pelanggan lengkap dan valid."},
    {"title": "Proses Penukaran Poin", "description": "Pastikan poin cukup dan lakukan verifikasi OTP."},
    {"title": "Catatan Transaksi", "description": "Catat transaksi dengan benar untuk keperluan audit."},
    {"title": "Penyelesaian Masalah", "description": "Segera laporkan masalah teknis kepada supervisor."},
  ];

  // Daftar Rules Kerja
  final List<Map<String, String>> rules = [
    {"title": "Integritas dan Kejujuran", "description": "Jaga integritas dalam setiap proses."},
    {"title": "Jaga Kerahasiaan Data", "description": "Data pelanggan harus dijaga kerahasiaannya."},
    {"title": "Tepat Waktu", "description": "Selesaikan tugas sesuai jadwal yang ditentukan."},
    {"title": "Kepuasan Pelanggan", "description": "Utamakan kepuasan pelanggan dengan layanan terbaik."},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Initialize the TabController
  }

  @override
  void dispose() {
    _tabController.dispose(); // Properly dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SOP dan Aturan Kerja Petugas',
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
            Tab(text: "SOP"),
            Tab(text: "Rules Kerja"),
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
          _buildSopList(),
          _buildRulesList(),
        ],
      ),
    );
  }

  // Widget untuk menampilkan SOP
  Widget _buildSopList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: sop.length,
        itemBuilder: (context, index) {
          final item = sop[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFFF9F9F9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget untuk menampilkan Rules Kerja
  Widget _buildRulesList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: rules.length,
        itemBuilder: (context, index) {
          final item = rules[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFFF9F9F9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
