import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardKepalaPage extends StatefulWidget {
  const DashboardKepalaPage({super.key});

  @override
  State<DashboardKepalaPage> createState() => _DashboardKepalaPageState();
}

class _DashboardKepalaPageState extends State<DashboardKepalaPage> {
  List suratList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuratDisposisiKepala();
  }

  // ================= FETCH SURAT DISPOSISI KEPALA =================
  Future<void> fetchSuratDisposisiKepala() async {
    final token = html.window.localStorage['token'];

    final response = await http.get(
      Uri.parse('http://127.0.0.1:3000/api/surat-masuk'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List allSurat = jsonDecode(response.body);

      setState(() {
        suratList = allSurat
            .where((s) => s['status'] == 'Disposisi Kepala')
            .toList();
        isLoading = false;
      });
    } else {
      print('Gagal fetch surat kepala');
      isLoading = false;
    }
  }

  // ================= LOGOUT =================
  void logout() {
    html.window.localStorage.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'Dashboard Kepala',
          style: TextStyle(color: Colors.white),
        ),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              child: const Center(
                child: Text(
                  'Menu Kepala',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Surat Masuk'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : suratList.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada surat disposisi untuk kepala',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: suratList.length,
                  itemBuilder: (context, index) {
                    final surat = suratList[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surat['no_surat'] ?? '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Dari: ${surat['dari']}'),
                            Text('Perihal: ${surat['perihal']}'),
                            Text(
                              'Status: ${surat['status']}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.assignment),
                                label: const Text('Beri Instruksi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                   Navigator.pushNamed(
                                    context,
                                    '/disposisi-kepala',
                                    arguments: surat, // ⬅️ kirim data surat
                                  );
                                },
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
