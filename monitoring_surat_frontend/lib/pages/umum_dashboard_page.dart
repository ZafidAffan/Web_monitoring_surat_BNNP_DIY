import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardUmumPage extends StatefulWidget {
  const DashboardUmumPage({super.key});

  @override
  State<DashboardUmumPage> createState() => _DashboardUmumPageState();
}

class _DashboardUmumPageState extends State<DashboardUmumPage> {
  List suratList = [];
  bool isLoading = true;

  final Color bgColor = const Color(0xFFF5F0CD); // kuning lembut
  final Color primaryColor = const Color(0xFF347433); // hijau tua
  final Color textBlue = const Color(0xFF3674B5); // teks biru
  final Color textYellow = Colors.orange; // teks kuning untuk Disposisi Kepala
  final Color textGreen = Colors.green; // teks hijau untuk Disposisi Divisi

  @override
  void initState() {
    super.initState();
    fetchSurat();
  }

  // ================= FETCH SURAT =================
  Future<void> fetchSurat() async {
    setState(() => isLoading = true);
    final token = html.window.localStorage['token'];

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/api/surat-masuk'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          suratList = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetch surat: $e");
    }
  }

  // ================= TERIMA SURAT =================
  Future<void> terimaSurat(int idSurat) async {
    final token = html.window.localStorage['token'];
    final response = await http.put(
      Uri.parse('http://127.0.0.1:3000/api/aksi/$idSurat/terima'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) fetchSurat();
  }

  // ================= KIRIM KE KEPALA =================
  Future<void> kirimKeKepala(int idSurat) async {
    final token = html.window.localStorage['token'];
    final response = await http.put(
      Uri.parse('http://127.0.0.1:3000/api/aksi/$idSurat/kirim-ke-kepala'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) fetchSurat();
  }

  // ================= LOGOUT =================
  void logout() {
    html.window.localStorage.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ================= BUILD DRAWER ITEM =================
  Widget _buildDrawerItem(IconData icon, String text, VoidCallback onTap,
      {Color iconColor = Colors.black, Color textColor = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(text, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  // ================= BUILD PRIMARY BUTTON =================
  Widget _buildPrimaryButton(String text, VoidCallback onPressed,
      {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Dashboard Umum'),
        backgroundColor: primaryColor,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu Umum',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(Icons.mail, 'Surat Masuk', () {
              Navigator.pop(context);
              fetchSurat();
            }),
            _buildDrawerItem(Icons.person, 'Surat dari Kepala', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/surat-dari-kepala');
            }),
            _buildDrawerItem(Icons.assignment, 'Surat Disposisi', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/disposisi-surat');
            }),
            const Spacer(),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', logout,
                iconColor: Colors.red, textColor: Colors.red),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suratList.length,
              itemBuilder: (context, index) {
                final surat = suratList[index];
                final status = surat['status'];
                final statusProses = surat['status_proses'] ?? '';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surat['no_surat'] ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text('Dari: ${surat['dari']}'),
                        Text('Perihal: ${surat['perihal']}'),
                        Text('Status: $status'),
                        const SizedBox(height: 12),

                        if (status == 'Menunggu')
                          _buildPrimaryButton(
                              'Terima Surat', () => terimaSurat(surat['id_surat'])),

                        if (status == 'Diterima') ...[
                          _buildPrimaryButton('Kirim ke Kepala',
                              () => kirimKeKepala(surat['id_surat']),
                              color: Colors.orange),
                          const SizedBox(height: 6),
                          _buildPrimaryButton('Disposisi ke Divisi', () {
                            Navigator.pushNamed(
                              context,
                              '/disposisi-surat',
                              arguments: surat,
                            ).then((_) => fetchSurat());
                          }),
                        ],

                        if (status == 'Disposisi Kepala')
                          Text(
                            'Menunggu arahan Kepala',
                            style: TextStyle(
                                color: textYellow, fontWeight: FontWeight.bold),
                          ),

                        if (status == 'Disposisi Divisi Umum')
                          _buildPrimaryButton('Lihat Arahan Kepala', () {
                            Navigator.pushNamed(context, '/surat-dari-kepala');
                          }, color: textGreen),

                        if (status == 'Disposisi Divisi')
                          Text(
                            'Sudah didisposisikan ke Divisi',
                            style: TextStyle(
                                color: textGreen, fontWeight: FontWeight.bold),
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
