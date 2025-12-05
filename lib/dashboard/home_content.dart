import 'package:joyin/providers/package_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import  g;
import '../providers/user_provider.dart';
// Import file grafik yang baru kita buat
import 'widgets/dashboard_charts.dart'; 
import '../screens/pilih_paket_screen.dart';
import '../package/package_theme.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  // Data
  final List<_MonthlyStat> _monthlyStats = const [
    _MonthlyStat('Jan', 1.0), _MonthlyStat('Feb', 3.0), _MonthlyStat('Mar', 4.0),
    _MonthlyStat('Apr', 3.0), _MonthlyStat('May', 2.0), _MonthlyStat('Jun', 5.0),
    _MonthlyStat('Jul', 4.0), _MonthlyStat('Aug', 2.0), _MonthlyStat('Sep', 1.0),
    _MonthlyStat('Oct', 3.0), _MonthlyStat('Nov', 2.0), _MonthlyStat('Dec', 5.0),
  ];

  // Perhatikan tipe data PieChartData diambil dari dashboard_charts.dart
  final List<PieChartData> _pieChartData = const [
    PieChartData('Dikirim', 40, Color(0xFF52C7A0)),
    PieChartData('Dibaca', 30, Color(0xFFFFC857)),
    PieChartData('Gagal', 15, Color(0xFFE96479)),
    PieChartData('Terkirim', 15, Color(0xFF4A90E2)),
  ];

  late final List<int> _chartYears;
  late int _selectedChartYear;

  // Mascot
  double _mascotHeight = 200;
  double _mascotOffsetX = -50;
  double _mascotOffsetY = 130;
  late final AnimationController _entranceController;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    _chartYears = List<int>.generate(4, (index) => DateTime.now().year - index);
    _selectedChartYear = _chartYears.first;
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _cardSlide = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    );
    _cardFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final String? packageName = packageProvider.currentUserPackage;
    final PackageTheme packageTheme = PackageThemeResolver.resolve(packageName);
    final bool hasPackage = packageName != null && packageName.isNotEmpty;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        final displayName = (user?.displayName?.contains('@') ?? false
                ? user?.displayName?.split('@').first
                : user?.displayName) ?? 'User';
        final topPadding = MediaQuery.of(context).padding.top;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: packageTheme.backgroundGradient,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroBanner(displayName, topPadding, hasPackage, packageTheme),
                  Transform.translate(
                    offset: const Offset(0, -80),
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_cardSlide),
                        child: hasPackage
                            ? _buildHomeOverviewCard(packageTheme)
                            : _buildHomeOverviewCardNoPackage(packageTheme),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroBanner(String displayName, double topPadding, bool hasPackage, PackageTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 52, 24, 132),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, height: 1.4, fontWeight: FontWeight.w600),
                    children: hasPackage
                        ? [
                            const TextSpan(text: 'Selamat datang, '),
                            TextSpan(
                              text: displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFC047),
                              ),
                            ),
                            const TextSpan(text: '\nJoyin siap nemenin bisnismu.'),
                          ]
                        : [
                            const TextSpan(text: 'Selamat datang di Joyin!'),
                            const TextSpan(text: '\nUpgrade akunmu untuk mulai.'),
                          ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.bottomRight,
              child: _MascotFadeSlide(
                child: GestureDetector(
                  onPanUpdate: (details) => setState(() {
                    _mascotOffsetX += details.delta.dx;
                    _mascotOffsetY += details.delta.dy;
                  }),
                  child: Transform.translate(
                    offset: Offset(_mascotOffsetX, _mascotOffsetY),
                    child: Image.asset('assets/images/maskot_kiri.png', height: _mascotHeight, fit: BoxFit.contain,
                        errorBuilder: (c, o, s) => const Icon(Icons.image_not_supported, color: Colors.white, size: 50)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeOverviewCardNoPackage(PackageTheme theme) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: theme.accent.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Fitur Terkunci', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          Text('Beli paket untuk membuka semua fitur dan mulai kelola chat bisnismu dengan lebih mudah.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PilihPaketScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Lihat Pilihan Paket', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeOverviewCard(PackageTheme theme) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: theme.accent.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Chat Masuk', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          _buildChatStatRow(),
          const SizedBox(height: 24),
          Text('Statistik Pengiriman Pesan', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildMessageLegend(),
          const SizedBox(height: 16),
          // MENGGUNAKAN FUNGSI ASLI
          _buildMessageVolumeChart(),
          const SizedBox(height: 24),
          // MENGGUNAKAN FUNGSI ASLI
          _buildMessageStatusChart(),
        ],
      ),
    );
  }

  // ... (Fungsi Stat Row & Legend SAMA SEPERTI SEBELUMNYA) ...
  Widget _buildChatStatRow() {
    final accent = PackageThemeResolver.resolve(context.read<PackageProvider>().currentUserPackage).accent;
    final stats = [
      _ChatStatCardData(value: '0', label: 'Chat Bulanan', accent: accent, background: accent.withOpacity(0.1)),
      _ChatStatCardData(value: '0', label: 'Chat Harian', accent: accent.withOpacity(0.8), background: accent.withOpacity(0.08)),
      _ChatStatCardData(value: '0', label: 'Chat Mingguan', accent: accent.withOpacity(0.6), background: accent.withOpacity(0.06)),
    ];
    return Row(children: stats.map((s) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: _buildChatStatCard(s)))).toList());
  }

  Widget _buildChatStatCard(_ChatStatCardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(color: data.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: data.accent.withOpacity(0.4))),
      child: Column(children: [Text(data.value, style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: data.accent)), const SizedBox(height: 4), Text(data.label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: data.accent))]),
    );
  }

  Widget _buildMessageLegend() {
    return Wrap(spacing: 16, runSpacing: 8, children: _pieChartData.map((d) => _buildLegendChip(d.label, d.color)).toList());
  }

  Widget _buildLegendChip(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 6), Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4A4A4A)))]);
  }

  // === KEMBALIKAN LOGIC GRAFIK DISINI ===
  Widget _buildMessageVolumeChart() {
    final stats = _monthlyStats;
    final double maxValue = stats.map((stat) => stat.value).reduce((a, b) => a > b ? a : b);
    final double chartTopValue = maxValue == 0 ? 2.0 : (maxValue / 2).ceil() * 2.0;
    final double average = stats.fold<double>(0, (sum, stat) => sum + stat.value) / stats.length;

    return Column(
      children: [
        // Dropdown Tahun
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12)
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedChartYear,
                items: _chartYears.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                onChanged: (v) => setState(() => _selectedChartYear = v!),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 210,
          padding: const EdgeInsets.only(top: 20, right: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double labelSpace = 36;
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: ChartGridPainter( // Panggil Painter
                  maxValue: chartTopValue,
                  averageValue: average,
                  labelSpace: labelSpace,
                  leftPadding: 30,
                ),
                // (Logic anak-anak bar chart bisa ditambahkan di sini, 
                //  tapi Painter di atas sudah menggambar grid dasarnya)
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageStatusChart() {
    final double totalValue = _pieChartData.fold(0, (sum, item) => sum + item.value);
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: PieChartPainter(data: _pieChartData), // Panggil Painter
        child: Center(
          child: Text('${totalValue.toInt()}%', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

// --- HELPER CLASSES ---
class _ChatStatCardData { final String value, label; final Color accent, background; const _ChatStatCardData({required this.value, required this.label, required this.accent, required this.background}); }
class _MonthlyStat { final String label; final double value; const _MonthlyStat(this.label, this.value); }

class _MascotFadeSlide extends StatefulWidget { final Widget child; const _MascotFadeSlide({required this.child}); @override State<_MascotFadeSlide> createState() => _MascotFadeSlideState(); }
class _MascotFadeSlideState extends State<_MascotFadeSlide> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
  late final Animation<double> _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
}
