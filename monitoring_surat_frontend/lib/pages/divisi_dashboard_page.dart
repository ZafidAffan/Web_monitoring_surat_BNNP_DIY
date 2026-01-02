import 'dart:convert';
import 'dart:html' as html; // Flutter Web localStorage
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DivisiDashboardPage extends StatefulWidget {
  const DivisiDashboardPage({super.key});

  @override
  State<DivisiDashboardPage> createState() => _DivisiDashboardPageState();
}

class _DivisiDashboardPageState extends State<DivisiDashboardPage> {
  bool loading = true;
  List disposisiList = [];

  @override
  void initState() {
    super.initState();
    fetchDisposisi();
  }

  // ================= FETCH DATA =================
  Future<void> fetchDisposisi() async {
    final token = html.window.localStorage['token'];

    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:3000/api/divisi/dashboard"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          disposisiList = jsonDecode(response.body);
          loading = false;
        });
      } else {
        debugPrint("Gagal fetch disposisi: ${response.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error API: $e");
      setState(() => loading = false);
    }
  }

  // ================= TERIMA DISPOSISI =================
  Future<void> terimaDisposisi(int idDisposisi) async {
    final token = html.window.localStorage['token'];

    try {
      final response = await http.put(
        Uri.parse(
            "http://127.0.0.1:3000/api/disposisi/$idDisposisi/terima"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        fetchDisposisi();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menerima disposisi")),
        );
      }
    } catch (e) {
      debugPrint("Error terima disposisi: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Dashboard Divisi",
          style: TextStyle(color: Colors.white),
        ),
      ),

      drawer: Drawer(
        child: Container(
          color: Colors.blue,
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  "Menu Divisi",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              buildMenuItem(Icons.mail, "Surat Masuk", () {
                Navigator.pop(context);
              }),
              buildMenuItem(Icons.logout, "Logout", () {
                html.window.localStorage.clear();
                Navigator.pushReplacementNamed(context, "/login");
              }),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER GAMBAR
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/gedung.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // SEARCH (UI SAJA)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari surat...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // LIST SURAT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: loading
                  ? const CircularProgressIndicator()
                  : disposisiList.isEmpty
                      ? const Text("Tidak ada surat masuk")
                      : Column(
                          children: disposisiList.map((item) {
                            return buildSuratCard(item);
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD SURAT =================
  Widget buildSuratCard(Map item) {
    final status = item['status_konfirmasi'] ?? 'belum diterima';

    Color statusColor = status == "belum diterima"
        ? Colors.red
        : Colors.green;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Row(
              children: [
                const Icon(Icons.description, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['perihal'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text("No Surat: ${item['no_surat'] ?? '-'}"),
            Text("Dari: ${item['dari'] ?? '-'}"),

            const SizedBox(height: 8),
            Text(
              "Perintah: ${item['perintah'] ?? '-'}",
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              "Keterangan: ${item['keterangan'] ?? '-'}",
            ),

            const SizedBox(height: 10),

            // ===== FOOTER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),

                if (status == 'belum diterima')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      terimaDisposisi(item['id_disposisi']);
                    },
                    child: const Text(
                      "Terima",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= MENU =================
  Widget buildMenuItem(IconData icon, String label, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
