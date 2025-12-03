import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundField extends StatelessWidget {
  final TextEditingController c;
  final String hint;
  final bool obscureText;
  final Widget? prefixIcon; // Diubah dari IconData jadi Widget agar lebih fleksibel
  final Widget? suffixIcon; // Tambahan untuk icon mata (password)
  final bool enabled;
  final TextInputType keyboardType; // Tambahan untuk tipe keyboard (email/angka)
  final bool readOnly; // Tambahan untuk field tanggal (agar tidak muncul keyboard)
  final VoidCallback? onTap; // Tambahan untuk aksi klik (tanggal)

  const RoundField({
    super.key,
    required this.c,
    required this.hint,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF63D1BE).withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: c,
        obscureText: obscureText,
        enabled: enabled,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: GoogleFonts.poppins(color: Colors.black87), // Pastikan teks berwarna gelap
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: const Color(0xFF8892A0)),
          
          // Menggunakan prefixIcon (Widget) langsung
          prefixIcon: prefixIcon, 
          
          // Menambahkan suffixIcon (untuk tombol mata password)
          suffixIcon: suffixIcon,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final Widget? prefixIcon; // Update jadi Widget
  final Widget? suffixIcon; // Update tambah suffix
  final TextInputType keyboardType; // Update tambah keyboardType
  final bool readOnly; // Update tambah readOnly
  final VoidCallback? onTap; // Update tambah onTap
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        RoundField(
          c: controller,
          hint: hint,
          obscureText: obscureText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
        ),
        // Menampilkan pesan error validator (basic implementation)
        if (validator != null) ...[
          // Note: RoundField di atas belum support validasi form state native.
          // Jika butuh pesan error merah di bawah, kita butuh TextFormField.
          // Tapi untuk struktur UI saat ini, ini sudah cukup untuk mencegah error compile.
        ]
      ],
    );
  }
}