import 'package:flutter/material.dart';

// ===== IMPORT SEMUA PAGE =====
import 'pages/login.dart';
import 'pages/dashboard_page.dart';
import 'pages/tambah_surat_page.dart';
import 'pages/divisi_dashboard_page.dart';
import 'pages/umum_dashboard_page.dart';
import 'pages/disposisi_surat_page.dart';
import 'pages/dashboard_kepala.dart';
import 'pages/disposisi_kepala.dart';
import 'pages/surat_dari_kepala.dart'; // ⬅️ halaman baru
import 'pages/tracking_surat_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Monitoring Surat BNN",

      // ===== HALAMAN AWAL =====
      initialRoute: "/login",

      // ===== ROUTING STATIC =====
      routes: {
        // ================= AUTH =================
        "/login": (context) => const LoginPage(),

        // ================= ADMIN =================
        "/dashboard": (context) => const DashboardPage(),
        "/tambah-surat": (context) => const TambahSuratPage(),
        "/disposisi-surat": (context) => const DisposisiSuratPage(),

        // ================= DIVISI =================
        "/divisi": (context) => const DivisiDashboardPage(),

        // ================= UMUM =================
        "/umum": (context) => const DashboardUmumPage(),

        // ================= KEPALA =================
        "/kepala": (context) => const DashboardKepalaPage(),

        // ================= SURAT DARI KEPALA =================
        "/surat-dari-kepala": (context) => const SuratDariKepalaPage(),
        "/tracking-surat": (context) => const TrackingSuratPage(),
      },

      // ===== ROUTE DENGAN ARGUMENT =====
      onGenerateRoute: (settings) {
        if (settings.name == '/disposisi-kepala') {
          final surat = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DisposisiKepalaPage(surat: surat),
          );
        }
        return null;
      },
    );
  }
}
