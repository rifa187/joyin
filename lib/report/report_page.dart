import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/widgets/locked_feature_widget.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../package/package_theme.dart';
import '../widgets/typing_text.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _cardSlide;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final AnimationController _chartController;
  bool _chartVisible = false;
  static const List<FlSpot> _interactionSpots = [
    FlSpot(0, 1),
    FlSpot(1, 1.5),
    FlSpot(2, 1.2),
    FlSpot(3, 1.9),
    FlSpot(4, 1.5),
    FlSpot(5, 2.2),
    FlSpot(6, 2.0),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _cardSlide = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1, curve: Curves.easeOutBack),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 1, curve: Curves.easeOut),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  Widget _buildHeroSection(double topPadding, PackageTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 48, 24, 120),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.headerGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypingText(
            text: 'Laporan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            duration: const Duration(milliseconds: 900),
            delay: const Duration(milliseconds: 80),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              'Pantau performa tim & bot, temukan tren interaksi, dan ambil keputusan lebih cepat.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(0.25, 0.8, curve: Curves.easeOutCubic),
              )),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Insight',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportBody(Color accent, Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildSummaryHeader(accent),
        const SizedBox(height: 16),
        _buildInfoGrid(accent),
        const SizedBox(height: 20),
        _buildChartCard(secondaryColor, accent),
      ],
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage =
        packageProvider.currentUserPackage != null && packageProvider.currentUserPackage!.isNotEmpty;
    const Color secondaryColor = Color(0xFFC7F4F6);
    final packageTheme = PackageThemeResolver.resolve(packageProvider.currentUserPackage);
    final double topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: packageTheme.backgroundGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(topPadding, packageTheme),
              Transform.translate(
                offset: const Offset(0, -80),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_cardSlide),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: packageTheme.accent.withOpacity(0.12),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: hasPackage
                        ? FadeTransition(
                            opacity: _contentFade,
                            child: SlideTransition(
                              position: _contentSlide,
                              child: _buildReportBody(packageTheme.accent, secondaryColor),
                            ),
                          )
                        : const LockedFeatureWidget(
                            title: 'Fitur Terkunci',
                            message: 'Upgrade paketmu untuk membuka halaman Laporan.',
                            icon: Icons.article_outlined,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(Color accent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.assessment, color: accent),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Kinerja',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Aktivitas 7 hari terakhir',
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoGrid(Color accent) {
    final cards = [
      ('Total Chat', '1.240', '+8% minggu lalu', Icons.chat_outlined),
      ('Konversi', '18%', '+2% minggu lalu', Icons.trending_up),
      ('Respons Bot', '92%', 'Rata-rata 3 dtk', Icons.bolt_outlined),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;
        final itemWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards.asMap().entries.map((entry) {
            final index = entry.key;
            final c = entry.value;
            final double start = 0.2 + (index * 0.08);
            final double end = (start + 0.4).clamp(0, 1);
            final Animation<double> fade = CurvedAnimation(
              parent: _entranceController,
              curve: Interval(start, end, curve: Curves.easeOut),
            );
            final Animation<Offset> slide = Tween<Offset>(
              begin: const Offset(0.12, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _entranceController,
                curve: Interval(start, end, curve: Curves.easeOutCubic),
              ),
            );
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: SizedBox(
                  width: itemWidth,
                  child: _buildInfoCard(
                    title: c.$1,
                    value: c.$2,
                    subtitle: c.$3,
                    accent: accent,
                    icon: c.$4,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildChartCard(Color secondaryColor, Color accent) {
    final Animation<double> chartAnim = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );
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
            child: VisibilityDetector(
              key: const Key('chart-visibility'),
              onVisibilityChanged: (info) {
                if (info.visibleFraction > 0.25 && !_chartVisible) {
                  _chartVisible = true;
                  _chartController.forward(from: 0);
                } else if (info.visibleFraction < 0.05 && _chartVisible) {
                  _chartVisible = false;
                  _chartController.reset();
                }
              },
              child: AnimatedBuilder(
                animation: chartAnim,
                builder: (context, _) {
                  final double t = chartAnim.value.clamp(0, 1);
                  final double maxX = _interactionSpots.last.x;
                  final double sweepX = maxX * t;

                  // Sweep along X axis: include full points up to sweep, then add an interpolated point.
                  final List<FlSpot> animatedSpots = [];
                  for (int i = 0; i < _interactionSpots.length; i++) {
                    final FlSpot current = _interactionSpots[i];
                    if (current.x <= sweepX) {
                      animatedSpots.add(current);
                      continue;
                    }
                    if (animatedSpots.isEmpty) {
                      animatedSpots.add(FlSpot(0, _interactionSpots.first.y * t));
                    } else {
                      final FlSpot prev = animatedSpots.last;
                      final double span = (current.x - prev.x).clamp(0.0001, double.infinity);
                      final double ratio = ((sweepX - prev.x) / span).clamp(0, 1);
                      final double interpY = prev.y + (current.y - prev.y) * ratio;
                      animatedSpots.add(FlSpot(sweepX, interpY));
                    }
                    break;
                  }

                  return LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: animatedSpots,
                          isCurved: true,
                          color: accent,
                          barWidth: 4,
                          belowBarData: BarAreaData(
                            show: true,
                            color: accent.withOpacity(0.12 + (0.08 * t)),
                          ),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  );
                },
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
    IconData icon = Icons.trending_up,
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
            child: Icon(icon, color: accent),
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
