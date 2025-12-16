import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class TambahSuratPage extends StatefulWidget {
  const TambahSuratPage({super.key});

  @override
  State<TambahSuratPage> createState() => _TambahSuratPageState();
}

class _TambahSuratPageState extends State<TambahSuratPage> {
  final nomorSuratController = TextEditingController();
  final pengirimController = TextEditingController();
  final perihalController = TextEditingController();

  File? selectedPDF;

  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedPDF = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitSurat() async {
    if (nomorSuratController.text.isEmpty ||
        pengirimController.text.isEmpty ||
        perihalController.text.isEmpty ||
        selectedPDF == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    var uri = Uri.parse("http://localhost:3000/api/surat-masuk");

    var request = http.MultipartRequest("POST", uri);

    request.fields['nomor_surat'] = nomorSuratController.text;
    request.fields['pengirim'] = pengirimController.text;
    request.fields['perihal'] = perihalController.text;

    request.files.add(
      await http.MultipartFile.fromPath("file", selectedPDF!.path),
    );

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Surat berhasil ditambahkan")),
      );
      Navigator.pop(context);
    } else {
      print(responseBody);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $responseBody")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Surat Masuk")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nomorSuratController,
                decoration: const InputDecoration(labelText: "Nomor Surat"),
              ),
              TextField(
                controller: pengirimController,
                decoration: const InputDecoration(labelText: "Pengirim"),
              ),
              TextField(
                controller: perihalController,
                decoration: const InputDecoration(labelText: "Perihal"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: pickPDF,
                child: Text(
                  selectedPDF == null
                      ? "Upload File PDF"
                      : "PDF Dipilih: ${selectedPDF!.path.split('/').last}",
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: submitSurat,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
