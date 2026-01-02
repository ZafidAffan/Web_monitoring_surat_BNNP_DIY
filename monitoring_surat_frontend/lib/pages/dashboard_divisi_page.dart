import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardDivisiPage extends StatefulWidget {
  const DashboardDivisiPage({super.key});

  @override
  State<DashboardDivisiPage> createState() => _DashboardDivisiPageState();
}

class _DashboardDivisiPageState extends State<DashboardDivisiPage> {
  List disposisiList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDisposisiDivisi();
  }

  // ================= FETCH DISPOSISI DIVISI =================
  Future<void> fetchDisposisiDivisi() async {
    final token = html.window.localStorage['token'];

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/disposisi/divisi'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          disposisiList = data
              .where((d) => d['status_proses'] == 'menunggu_divisi')
              .toList();
          loading = false;
        });
      } else {
        loading = false;
      }
    } catch (e) {
      loading = false;
    }
  }

  // ================= TERIMA DISPOSISI =================
  Future<void> terimaDisposisi(int idDisposisi) async {
    final token = html.window.localStorage['token'];

    final response = await http.put(
      Uri.parse(
        'http://localhost:3000/api/disposisi/$idDisposisi/terima',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disposisi berhasil diterima')),
      );
      fetchDisposisiDivisi(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menerima disposisi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Dashboard Divisi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : disposisiList.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada disposisi masuk',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: disposisiList.length,
                  itemBuilder: (context, index) {
                    final d = disposisiList[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['no_surat'] ?? '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Perihal: ${d['perihal'] ?? '-'}'),
                            const SizedBox(height: 4),
                            Text(
                              'Perintah:',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(d['perintah'] ?? '-'),
                            if (d['keterangan'] != null &&
                                d['keterangan'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Catatan: ${d['keterangan']}',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    terimaDisposisi(d['id_disposisi']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'Terima Disposisi',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
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
