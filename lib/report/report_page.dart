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
  static const List<_StatusMetric> _statusMetrics = [
    _StatusMetric('Dikirim', 898, Color(0xFF63CBA1)),
    _StatusMetric('Terkirim', 511, Color(0xFFF6B644)),
    _StatusMetric('Dibaca', 350, Color(0xFF8B5CF6)),
    _StatusMetric('Gagal', 37, Color(0xFFEF6A6A)),
  ];
  static const List<_WeeklyMetric> _weeklyMetrics = [
    _WeeklyMetric(sent: 180, delivered: 120, read: 90, failed: 15),
    _WeeklyMetric(sent: 165, delivered: 110, read: 85, failed: 12),
    _WeeklyMetric(sent: 150, delivered: 105, read: 82, failed: 10),
    _WeeklyMetric(sent: 155, delivered: 108, read: 88, failed: 9),
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
        _buildAnimatedSection(
          delayStart: 0.15,
          child: _buildDateRangeRow(),
        ),
        const SizedBox(height: 16),
        _buildAnimatedSection(
          delayStart: 0.25,
          child: _buildMetricGrid(),
        ),
        const SizedBox(height: 18),
        _buildAnimatedSection(
          delayStart: 0.38,
          child: _buildChartsSection(),
        ),
        const SizedBox(height: 18),
        _buildAnimatedSection(
          delayStart: 0.52,
          child: Center(child: _buildDownloadButton()),
        ),
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
                              child: _buildReportBody(
                                packageTheme.accent,
                                secondaryColor,
                              ),
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

  Widget _buildDateRangeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            label: 'Tanggal Mulai',
            value: '16/11/2025',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField(
            label: 'Tanggal Akhir',
            value: '16/12/2025',
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const Icon(Icons.calendar_month_outlined,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 720;
        final double itemWidth = isWide
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _statusMetrics.asMap().entries.map((entry) {
            final index = entry.key;
            final metric = entry.value;
            return SizedBox(
              width: itemWidth,
              child: _buildAnimatedSection(
                delayStart: 0.28 + (index * 0.06),
                child: _buildMetricCard(metric),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMetricCard(_StatusMetric metric) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: metric.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: metric.color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: metric.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: metric.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    final Animation<double> chartAnim = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );

    return VisibilityDetector(
      key: const Key('report-chart-visibility'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_chartVisible) {
          _chartVisible = true;
          _chartController.forward(from: 0);
        } else if (info.visibleFraction < 0.05 && _chartVisible) {
          _chartVisible = false;
          _chartController.reset();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 720;
          final Widget statusCard = _buildStatusCard(chartAnim);
          final Widget weeklyCard = _buildWeeklyCard(chartAnim);
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildAnimatedSection(
                    delayStart: 0.44,
                    child: statusCard,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnimatedSection(
                    delayStart: 0.5,
                    child: weeklyCard,
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              _buildAnimatedSection(
                delayStart: 0.44,
                child: statusCard,
              ),
              const SizedBox(height: 12),
              _buildAnimatedSection(
                delayStart: 0.52,
                child: weeklyCard,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Animation<double> chartAnim) {
    final total = _statusMetrics.fold<int>(0, (sum, m) => sum + m.value);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Pengiriman',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: _statusMetrics.map((metric) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: metric.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    metric.label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: chartAnim,
              builder: (context, _) {
                final double t = chartAnim.value.clamp(0, 1).toDouble();
                return Opacity(
                  opacity: t,
                  child: Transform.scale(
                    scale: 0.92 + (0.08 * t),
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: _statusMetrics.map((metric) {
                          final value = metric.value / total * 100 * t;
                          return PieChartSectionData(
                            value: value,
                            color: metric.color,
                            radius: 26,
                            title: '',
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCard(Animation<double> chartAnim) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Mingguan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: _statusMetrics.map((metric) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: metric.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    metric.label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: chartAnim,
              builder: (context, _) {
                final double t = chartAnim.value.clamp(0, 1).toDouble();
                return Opacity(
                  opacity: t,
                  child: Transform.scale(
                    scale: 0.96 + (0.04 * t),
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                final label = 'Minggu ${index + 1}';
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    label,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(_weeklyMetrics.length, (index) {
                          final week = _weeklyMetrics[index];
                          final values = [
                            week.sent,
                            week.delivered,
                            week.read,
                            week.failed,
                          ];
                          return BarChartGroupData(
                            x: index,
                            barRods: List.generate(values.length, (i) {
                              final color = _statusMetrics[i].color;
                              return BarChartRodData(
                                toY: values[i] * t,
                                width: 8,
                                borderRadius: BorderRadius.circular(4),
                                color: color,
                              );
                            }),
                            barsSpace: 4,
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF5BC5A3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.download, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'Download Excel',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({
    required double delayStart,
    required Widget child,
  }) {
    final double start = delayStart.clamp(0, 0.9);
    final double end = (start + 0.35).clamp(start + 0.05, 1);
    final Animation<double> fade = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _StatusMetric {
  final String label;
  final int value;
  final Color color;

  const _StatusMetric(this.label, this.value, this.color);
}

class _WeeklyMetric {
  final double sent;
  final double delivered;
  final double read;
  final double failed;

  const _WeeklyMetric({
    required this.sent,
    required this.delivered,
    required this.read,
    required this.failed,
  });
}
