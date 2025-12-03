import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/widgets/locked_feature_widget.dart';
import 'package:provider/provider.dart';
import '../package/package_theme.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage =
        packageProvider.currentUserPackage != null && packageProvider.currentUserPackage!.isNotEmpty;
    const Color secondaryColor = Color(0xFFC7F4F6);
    final packageTheme = PackageThemeResolver.resolve(packageProvider.currentUserPackage);

    final double topPadding = MediaQuery.of(context).padding.top;
    const double headerHeight = 200;
    final double contentTop = topPadding + 100;
    final double contentHeight = MediaQuery.of(context).size.height - contentTop;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: packageTheme.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: packageTheme.headerGradient,
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
                            Row(
                              children: [
                                Icon(Icons.assessment, color: packageTheme.accent),
                                const SizedBox(width: 8),
                                Text(
                                  'Ringkasan Kinerja',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              title: 'Total Chat',
                              value: '1.240',
                              subtitle: '+8% dari minggu lalu',
                              accent: packageTheme.accent,
                            ),
                            const SizedBox(height: 14),
                            _buildInfoCard(
                              title: 'Konversi',
                              value: '18%',
                              subtitle: '+2% dari minggu lalu',
                              accent: packageTheme.accent,
                            ),
                            const SizedBox(height: 24),
                            _buildChartCard(secondaryColor, packageTheme.accent),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: LockedFeatureWidget(
                        title: 'Fitur Terkunci',
                        message: 'Upgrade paketmu untuk membuka halaman Laporan.',
                        icon: Icons.article_outlined,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(Color secondaryColor, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Interaksi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(1, 1.5),
                      FlSpot(2, 1.2),
                      FlSpot(3, 1.9),
                      FlSpot(4, 1.5),
                      FlSpot(5, 2.2),
                      FlSpot(6, 2.0),
                    ],
                    isCurved: true,
                    color: accent,
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      color: accent.withOpacity(0.15),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.trending_up, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
