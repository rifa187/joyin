import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundField extends StatelessWidget {
  final TextEditingController c;
  final String hint;
  final bool ob;
  final IconData? icon;
  final bool enabled;

  const RoundField({
    super.key,
    required this.c,
    required this.hint,
    this.ob = false,
    this.icon,
    this.enabled = true,
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
        obscureText: ob,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: const Color(0xFF8892A0)),
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF8892A0))
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.prefixIcon,
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
          ob: obscureText,
          icon: prefixIcon,
        ),
      ],
    );
  }
}
