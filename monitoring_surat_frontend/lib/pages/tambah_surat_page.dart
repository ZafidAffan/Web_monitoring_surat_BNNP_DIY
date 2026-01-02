import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class TambahSuratPage extends StatefulWidget {
  const TambahSuratPage({super.key});

  @override
  State<TambahSuratPage> createState() => _TambahSuratPageState();
}

class _TambahSuratPageState extends State<TambahSuratPage> {
  final noSuratController = TextEditingController();
  final dariController = TextEditingController();
  final perihalController = TextEditingController();
  final tanggalSuratController = TextEditingController();
  final tanggalTerimaController = TextEditingController();

  Uint8List? pdfBytes;
  String? pdfName;
  bool isLoading = false;

  // ================= PICK DATE =================
  Future<void> pickDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      controller.text = date.toIso8601String().substring(0, 10);
    }
  }

  // ================= PICK PDF =================
  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        pdfBytes = result.files.single.bytes;
        pdfName = result.files.single.name;
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> submitSurat() async {
    if (pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF wajib diupload')),
      );
      return;
    }

    final token = html.window.localStorage['token'];

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:3000/api/surat-masuk'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Fields
    request.fields.addAll({
      'no_surat': noSuratController.text,
      'tanggal_surat': tanggalSuratController.text,
      'tanggal_terima': tanggalTerimaController.text,
      'dari': dariController.text,
      'perihal': perihalController.text,
    });

    // File upload (nama field harus sama dengan multer di backend)
    request.files.add(
      http.MultipartFile.fromBytes(
        'file_surat', // HARUS SAMA DENGAN upload.single('file_surat')
        pdfBytes!,
        filename: pdfName!,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    setState(() => isLoading = true);
    final response = await request.send();
    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Surat berhasil disimpan')),
      );
      Navigator.pop(context);
    } else {
      final body = await response.stream.bytesToString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(body)));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Surat Masuk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildField(noSuratController, 'Nomor Surat'),
            buildDate(tanggalSuratController, 'Tanggal Surat'),
            buildDate(tanggalTerimaController, 'Tanggal Terima'),
            buildField(dariController, 'Dari'),
            buildField(perihalController, 'Perihal'),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(pdfName ?? 'Upload PDF'),
              onPressed: pickPDF,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitSurat,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Surat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildDate(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        readOnly: true,
        onTap: () => pickDate(c),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
