import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'pages/dashboard_page.dart';
import 'pages/tambah_surat_page.dart';
// import 'pages/tracking_surat_page.dart'; // (opsional jika sudah ada)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Monitoring Surat",

      // Halaman awal aplikasi
      initialRoute: "/login",

      routes: {
        "/login": (context) => const LoginPage(),
        "/dashboard": (context) => const DashboardPage(),
        "/tambah-surat": (context) => const TambahSuratPage(),
        // "/tracking-surat": (context) => const TrackingSuratPage(), // optional
      },
    );
  }
}
