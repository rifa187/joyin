import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BotSettingsPage extends StatelessWidget {
  const BotSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Bot', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildCard('Pengaturan Umum', [
              _buildTextField('Nama Bot'),
              _buildTextField('Pesan Selamat Datang', maxLines: 3),
              _buildSwitch('Aktifkan Bot', true),
            ]),
            const SizedBox(height: 24),
            _buildCard('Balasan Otomatis', [
              _buildTextField('Pesan default', maxLines: 3),
              _buildTextField('Jeda (detik)', isNumber: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...children.expand((w) => [w, const SizedBox(height: 16)]),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  Widget _buildSwitch(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: GoogleFonts.poppins(fontSize: 16)), Switch(value: value, onChanged: (v) {}, activeColor: const Color(0xFF63D1BE))],
    );
  }
}   