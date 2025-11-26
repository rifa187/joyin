import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Masukkan helper widget (StatCard) di sini atau import jika dibuat global
class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildDateRangeSelector(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildReportSummaryStatistics(),
            ),
            // Anda bisa import dan panggil Grafik lagi di sini jika mau
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))]),
      child: ListTile(
        title: Text('Pilih Rentang Tanggal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.calendar_today, color: Color(0xFF63D1BE)),
        onTap: () {},
      ),
    );
  }

  Widget _buildReportSummaryStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ringkasan Statistik', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('245', 'Pesan Masuk', const Color(0xFF63D1BE), const Color(0xFFE9FFF8))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('198', 'Pesan Terjawab', const Color(0xFFB79CEF), const Color(0xFFF3ECFF))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color accent, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: accent.withOpacity(0.4))),
      child: Column(children: [Text(value, style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: accent)), Text(label, style: GoogleFonts.poppins(fontSize: 12))]),
    );
  }
}