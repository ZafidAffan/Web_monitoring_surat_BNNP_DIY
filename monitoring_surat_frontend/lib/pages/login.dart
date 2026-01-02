import 'dart:convert';
import 'dart:html' as html; // Flutter Web localStorage
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:3000/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailC.text,
          "password": passC.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String token = data['token'];
        final Map<String, dynamic> user = data['user'];

        final String role = user['role'];
        final String divisi = user['divisi'] ?? '';
        final String nama = user['nama'] ?? user['email'];

        // 🔐 SIMPAN KE LOCAL STORAGE
        html.window.localStorage['token'] = token;
        html.window.localStorage['role'] = role;
        html.window.localStorage['divisi'] = divisi;
        html.window.localStorage['nama'] = nama;

        debugPrint("TOKEN  : $token");
        debugPrint("ROLE   : $role");
        debugPrint("DIVISI : $divisi");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login berhasil, selamat datang $nama")),
        );

        // 🚦 ROUTING BERDASARKAN ROLE & DIVISI
        if (role == 'admin') {
          // ✅ ADMIN → DASHBOARD MONITORING SURAT
          Navigator.pushReplacementNamed(context, '/dashboard');
        } 
        else if (role == 'kepala') {
          Navigator.pushReplacementNamed(context, '/kepala');
        } 
        else if (role == 'umum') {
          // ✅ DIVISI UMUM (punya fitur disposisi)
          Navigator.pushReplacementNamed(context, '/umum');
        } 
        else if (role == 'divisi') {
          // ✅ DIVISI LAIN (P2M, Rehab, dll)
          Navigator.pushReplacementNamed(context, '/divisi');
        } 
        else {
          Navigator.pushReplacementNamed(context, '/login');
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login gagal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: emailC,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: passC,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
