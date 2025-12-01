import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/widgets/locked_feature_widget.dart';
import 'package:provider/provider.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage = packageProvider.currentUserPackage != null &&
        packageProvider.currentUserPackage!.isNotEmpty;

    const Color primaryColor = Color(0xFF4ECDC4);
    const Color secondaryColor = Color(0xFFC7F4F6);
    final double topPadding = MediaQuery.of(context).padding.top;
    const double headerHeight = 200;
    final double contentTop = topPadding + 100;
    final double contentHeight =
        MediaQuery.of(context).size.height - contentTop;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4DB6AC), Color(0xFF81C784)],
              ),
            ),
            padding: EdgeInsets.only(top: topPadding + 16, left: 20, right: 20),
            alignment: Alignment.topCenter,
            child: Text(
              'Laporan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: contentTop),
            height: contentHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: hasPackage
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Pilih Rentang Tanggal",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Icon(Icons.calendar_today,
                                    color: primaryColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Statistik Pengiriman Pesan",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "2.9 rata-rata/bulan",
                            style: GoogleFonts.poppins(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 300,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
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
                                        const style = TextStyle(
                                            color: Colors.grey, fontSize: 10);
                                        switch (value.toInt()) {
                                          case 0:
                                            return const Text('Jan', style: style);
                                          case 2:
                                            return const Text('Mar', style: style);
                                          case 4:
                                            return const Text('May', style: style);
                                          case 6:
                                            return const Text('Jul', style: style);
                                          case 8:
                                            return const Text('Sep', style: style);
                                          case 10:
                                            return const Text('Nov', style: style);
                                          default:
                                            return const Text('', style: style);
                                        }
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(show: false),
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
                          Text(
                            "Status Pesan",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Stack(
                                    children: [
                                      PieChart(
                                        PieChartData(
                                          sectionsSpace: 0,
                                          centerSpaceRadius: 40,
                                          sections: [
                                            PieChartSectionData(
                                              color: const Color(0xFF4ECDC4),
                                              value: 40,
                                              radius: 25,
                                              showTitle: false,
                                            ),
                                            PieChartSectionData(
                                              color: const Color(0xFFFFD93D),
                                              value: 30,
                                              radius: 25,
                                              showTitle: false,
                                            ),
                                            PieChartSectionData(
                                              color: const Color(0xFFFF6B6B),
                                              value: 15,
                                              radius: 25,
                                              showTitle: false,
                                            ),
                                            PieChartSectionData(
                                              color: const Color(0xFF4D96FF),
                                              value: 15,
                                              radius: 25,
                                              showTitle: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "100%",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _LegendItem(
                                        color: const Color(0xFF4ECDC4),
                                        text: "Dikirim (40%)",
                                      ),
                                      const SizedBox(height: 10),
                                      _LegendItem(
                                        color: const Color(0xFFFFD93D),
                                        text: "Dibaca (30%)",
                                      ),
                                      const SizedBox(height: 10),
                                      _LegendItem(
                                        color: const Color(0xFFFF6B6B),
                                        text: "Gagal (15%)",
                                      ),
                                      const SizedBox(height: 10),
                                      _LegendItem(
                                        color: const Color(0xFF4D96FF),
                                        text: "Terkirim (15%)",
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: LockedFeatureWidget(
                        title: 'Laporan Terkunci',
                        message:
                            'Upgrade paketmu untuk melihat laporan dan statistik.',
                        icon: Icons.article_outlined,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
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
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
