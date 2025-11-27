import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final String? hintText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[400],
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF63D1BE)),
            ),
          ),
        ),
      ],
    );
  }
}