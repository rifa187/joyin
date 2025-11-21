import 'package:flutter/material.dart';

class AppColors {
  // Private constructor agar class ini tidak bisa di-instantiate
  AppColors._();

  // --- Brand & Gradients ---
  // Digunakan untuk background gradient atau elemen branding utama
  static const Color joyin = Color(0xFF1A9C8A); // Warna tergelap (Bisa untuk status bar)
  
  static const Color grad1 = Color(0xFF1A9C8A);
  static const Color grad2 = Color(0xFF20BFA2);
  static const Color grad3 = Color(0xFF63D1BE);

  // --- Main UI Colors ---
  static const Color primary = Color(0xFF63D1BE);      // Tombol Utama, Loading
  static const Color secondary = Color(0xFF20BFA2);    // Link, Icon aktif
  static const Color accent = Color(0xFFFF6B6B);       // Notifikasi badge, elemen "hot"

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFF333333);  // Judul, Teks utama
  static const Color textSecondary = Color(0xFF8892A0); // Subtitle, Hint text
  static const Color textInverse = Colors.white;       // Teks di dalam tombol berwarna

  // --- Backgrounds & Surfaces ---
  static const Color background = Color(0xFFF5F7FA);   // Warna latar belakang screen
  static const Color surface = Colors.white;           // Warna Card / Container
  static const Color border = Color(0xFFE0E0E0);       // Garis pembatas / Border form

  // --- Functional / Feedback (PENTING untuk Form) ---
  static const Color error = Color(0xFFD32F2F);        // Merah untuk pesan error
  static const Color success = Color(0xFF388E3C);      // Hijau untuk sukses
}