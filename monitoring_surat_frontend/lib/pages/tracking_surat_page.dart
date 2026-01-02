import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detail_tracking_surat_page.dart';

class TrackingSuratPage extends StatefulWidget {
  const TrackingSuratPage({super.key});

  @override
  State<TrackingSuratPage> createState() => _TrackingSuratPageState();
}

class _TrackingSuratPageState extends State<TrackingSuratPage> {
  List suratList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSuratMasuk();
  }

  // ================= FETCH SURAT MASUK =================
  Future<void> fetchSuratMasuk() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:3000/api/surat-masuk"),
      );

      if (response.statusCode == 200) {
        setState(() {
          suratList = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
      debugPrint("Error fetch surat masuk: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Tracking Surat",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : suratList.isEmpty
              ? const Center(child: Text("Tidak ada surat masuk"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: suratList.length,
                  itemBuilder: (context, index) {
                    final surat = suratList[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.mail, color: Colors.blue),
                        title: Text(
                          surat['no_surat'] ?? 'Tanpa Nomor',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surat['perihal'] ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Dari: ${surat['dari'] ?? '-'}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailTrackingSuratPage(
                                idSurat: surat['id_surat'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
