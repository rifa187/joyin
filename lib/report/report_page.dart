import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna bisa ambil dari AppColors atau hardcode sementara
    const Color primaryColor = Color(0xFF4ECDC4);
    const Color secondaryColor = Color(0xFFC7F4F6);

    // ❌ KITA HAPUS SCAFFOLD & APPBAR DISINI
    // ✅ Langsung return body-nya saja (SingleChildScrollView)
    // agar header "Laporan" dikendalikan oleh DashboardPage.
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      // Tambahkan jarak aman di atas agar tidak ketutup AppBar Dashboard
      // karena Dashboard Anda pakai extendBodyBehindAppBar di beberapa halaman, 
      // tapi untuk halaman Laporan (Index 2) sepertinya aman (extendBodyBehindAppBar = false).
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Bagian Pilih Tanggal ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Pilih Rentang Tanggal", style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.calendar_today, color: primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Judul Statistik ---
          const Text("Statistik Pengiriman Pesan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("2.9 rata-rata/bulan", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // --- CHART BATANG ---
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 6,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.grey, fontSize: 10);
                        switch (value.toInt()) {
                          case 0: return const Text('Jan', style: style);
                          case 2: return const Text('Mar', style: style);
                          case 4: return const Text('May', style: style);
                          case 6: return const Text('Jul', style: style);
                          case 8: return const Text('Sep', style: style);
                          case 10: return const Text('Nov', style: style);
                          default: return const Text('', style: style);
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false), // Grid dimatikan biar bersih
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 2, secondaryColor),
                  _makeGroupData(1, 4, secondaryColor),
                  _makeGroupData(2, 5, primaryColor),
                  _makeGroupData(3, 3, secondaryColor),
                  _makeGroupData(4, 2, secondaryColor),
                  _makeGroupData(5, 6, primaryColor),
                  _makeGroupData(6, 5, secondaryColor),
                  _makeGroupData(7, 3, secondaryColor),
                  _makeGroupData(8, 2, secondaryColor),
                  _makeGroupData(9, 4, secondaryColor),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --- Judul Status Pesan ---
          const Text("Status Pesan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // --- CHART DONAT ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 150, height: 150,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(color: const Color(0xFF4ECDC4), value: 40, radius: 25, showTitle: false),
                            PieChartSectionData(color: const Color(0xFFFFD93D), value: 30, radius: 25, showTitle: false),
                            PieChartSectionData(color: const Color(0xFFFF6B6B), value: 15, radius: 25, showTitle: false),
                            PieChartSectionData(color: const Color(0xFF4D96FF), value: 15, radius: 25, showTitle: false),
                          ],
                        ),
                      ),
                      const Center(child: Text("100%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _LegendItem(color: Color(0xFF4ECDC4), text: "Dikirim (40%)"),
                      SizedBox(height: 10),
                      _LegendItem(color: Color(0xFFFFD93D), text: "Dibaca (30%)"),
                      SizedBox(height: 10),
                      _LegendItem(color: Color(0xFFFF6B6B), text: "Gagal (15%)"),
                      SizedBox(height: 10),
                      _LegendItem(color: Color(0xFF4D96FF), text: "Terkirim (15%)"),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y, color: color, width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}