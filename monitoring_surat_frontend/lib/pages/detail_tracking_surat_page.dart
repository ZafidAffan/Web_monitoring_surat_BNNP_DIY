import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailTrackingSuratPage extends StatefulWidget {
  final int idSurat;

  const DetailTrackingSuratPage({
    super.key,
    required this.idSurat,
  });

  @override
  State<DetailTrackingSuratPage> createState() =>
      _DetailTrackingSuratPageState();
}

class _DetailTrackingSuratPageState extends State<DetailTrackingSuratPage> {
  List trackingList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTracking();
  }

  // ================= FETCH TRACKING =================
  Future<void> fetchTracking() async {
    final token = html.window.localStorage['token'];

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Token tidak ditemukan, silakan login ulang"),
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "http://localhost:3000/api/tracking/surat/${widget.idSurat}",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          trackingList = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data tracking tidak ditemukan"),
          ),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Detail Tracking Surat",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : trackingList.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada riwayat tracking",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trackingList.length,
                  itemBuilder: (context, index) {
                    final item = trackingList[index];
                    final isLast = index == trackingList.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= TIMELINE (DOT & LINE) =================
                        Column(
                          children: [
                            // DOT
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),

                            // LINE
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 90,
                                color: Colors.blue.shade200,
                              ),
                          ],
                        ),

                        const SizedBox(width: 14),

                        // ================= CARD =================
                        Expanded(
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // STATUS
                                  Text(
                                    item['status'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // KETERANGAN
                                  if (item['keterangan'] != null &&
                                      item['keterangan']
                                          .toString()
                                          .isNotEmpty)
                                    Text(
                                      item['keterangan'],
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),

                                  const SizedBox(height: 8),

                                  // WAKTU
                                  Text(
                                    "Waktu: ${item['waktu']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
