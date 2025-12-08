import 'dart:math' as math;
import 'dart:ui';
import 'package:joyin/providers/package_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/app_colors.dart';
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

class _HomeContentState extends State<HomeContent> with TickerProviderStateMixin {
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
  final double _mascotHeight = 200;
  double _mascotOffsetX = -50;
  double _mascotOffsetY = 130;
  late final AnimationController _entranceController;
  late final AnimationController _textController;
  late final Animation<double> _cardSlide;
  late final AnimationController _bgGradientController;
  late final AnimationController _pieController;
  bool _pieIsVisible = false;

  @override
  void initState() {
    super.initState();
    _chartYears = List<int>.generate(4, (index) => DateTime.now().year - index);
    _selectedChartYear = _chartYears.first;
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _cardSlide = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    );
    _bgGradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _pieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _textController.dispose();
    _bgGradientController.dispose();
    _pieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final String? packageName = packageProvider.currentUserPackage;
    final PackageTheme packageTheme = PackageThemeResolver.resolve(packageName);
    final bool hasPackage = packageName != null && packageName.isNotEmpty;
    final bool animateBackground = packageTheme.backgroundGradient.toSet().length > 1;
    final bool animateHeader = packageTheme.headerGradient.toSet().length > 1;
    final bool shouldAnimateGradient = animateBackground || animateHeader;

    if (shouldAnimateGradient && !_bgGradientController.isAnimating) {
      _bgGradientController.repeat(reverse: true);
    } else if (!shouldAnimateGradient && _bgGradientController.isAnimating) {
      _bgGradientController.stop();
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        final displayName = (user?.displayName?.contains('@') ?? false
                ? user?.displayName?.split('@').first
                : user?.displayName) ?? 'User';
        final topPadding = MediaQuery.of(context).padding.top;

        return AnimatedBuilder(
          animation: _bgGradientController,
          builder: (context, child) {
            final double shift = shouldAnimateGradient
                ? lerpDouble(-1.2, 1.2, _bgGradientController.value) ?? 0
                : 0;
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.8 + shift, -1),
                        end: Alignment(1.8 + shift, 1),
                        colors: packageTheme.backgroundGradient,
                        tileMode: TileMode.mirror,
                      ),
                    ),
                  ),
                ),
                if (shouldAnimateGradient)
                  Positioned.fill(
                    child: _AuroraOverlay(
                      colors: packageTheme.backgroundGradient,
                      value: _bgGradientController.value,
                    ),
                  ),
                Positioned.fill(child: child!),
              ],
            );
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroBanner(
                  displayName,
                  topPadding,
                  hasPackage,
                  packageTheme,
                  shouldAnimateGradient
                      ? lerpDouble(-0.4, 0.4, _bgGradientController.value) ?? 0
                      : 0,
                  animateHeader,
                ),
                Transform.translate(
                  offset: const Offset(0, -80),
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
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner(
    String displayName,
    double topPadding,
    bool hasPackage,
    PackageTheme theme,
    double gradientShift,
    bool animateHeader,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 52, 24, 132),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.headerGradient,
          begin: Alignment(-1 + (animateHeader ? gradientShift : 0), -1),
          end: Alignment(1 + (animateHeader ? gradientShift : 0), 1),
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
                _buildWelcomeText(displayName, hasPackage),
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

  Widget _buildWelcomeText(String displayName, bool hasPackage) {
    final baseStyle = GoogleFonts.poppins(
      fontSize: 20,
      color: Colors.white,
      height: 1.4,
      fontWeight: FontWeight.w600,
    );
    final highlightStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFFFFC047),
    );

    final lines = hasPackage
        ? [
            [_TextSegment('Selamat datang,', baseStyle)],
            [_TextSegment('Joyin siap nemenin', baseStyle)],
            [_TextSegment('bisnismu', baseStyle)],
          ]
        : [
            [_TextSegment('Selamat datang di Joyin!', baseStyle)],
            [_TextSegment('Upgrade akunmu untuk mulai.', baseStyle)],
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SplitTextLine(segments: lines[0], controller: _textController, maxSpread: 0.25),
        const SizedBox(height: 4),
        if (hasPackage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _TypingText(
              text: displayName,
              style: highlightStyle,
              duration: Duration(milliseconds: (displayName.length * 90).clamp(600, 1400)),
              delay: const Duration(milliseconds: 80),
            ),
          ),
        _SplitTextLine(
          segments: lines[hasPackage ? 1 : 0],
          controller: _textController,
          delayOffset: hasPackage ? 0.28 : 0.12,
          maxSpread: 0.28,
        ),
        const SizedBox(height: 2),
        _SplitTextLine(
          segments: lines[hasPackage ? 2 : 1],
          controller: _textController,
          delayOffset: hasPackage ? 0.44 : 0.24,
          maxSpread: 0.28,
        ),
      ],
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
      child: VisibilityDetector(
        key: const Key('pie-status-visibility'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.2 && !_pieIsVisible) {
            _pieIsVisible = true;
            _pieController.forward(from: 0);
          } else if (info.visibleFraction < 0.05 && _pieIsVisible) {
            _pieIsVisible = false;
            _pieController.reset();
          }
        },
        child: AnimatedBuilder(
          animation: _pieController,
          builder: (context, child) {
            final double t = Curves.easeOutCubic.transform(_pieController.value);
            return Opacity(
              opacity: t,
              child: Transform.scale(
                scale: 0.92 + (0.08 * t),
                child: CustomPaint(
                  painter: PieChartPainter(
                    data: _pieChartData,
                    progress: t,
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: Center(
            child: Text(
              '${totalValue.toInt()}%',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuroraOverlay extends StatelessWidget {
  final List<Color> colors;
  final double value;

  const _AuroraOverlay({
    required this.colors,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();
    final Color primary = colors.first;
    final Color secondary = colors.length > 1 ? colors[1] : primary;
    final Color tertiary = colors.length > 2 ? colors[2] : secondary;

    return IgnorePointer(
      child: Stack(
        children: [
          _AuroraBlob(
            color: primary.withOpacity(0.20),
            baseAlignment: const Alignment(-0.6, -0.2),
            travel: const Offset(0.35, 0.25),
            size: 420,
            blur: 180,
            value: value,
            phase: 0,
          ),
          _AuroraBlob(
            color: secondary.withOpacity(0.18),
            baseAlignment: const Alignment(0.5, -0.4),
            travel: const Offset(-0.25, 0.35),
            size: 380,
            blur: 160,
            value: value,
            phase: 0.35,
          ),
          _AuroraBlob(
            color: tertiary.withOpacity(0.12),
            baseAlignment: const Alignment(0.0, 0.7),
            travel: const Offset(0.4, -0.25),
            size: 520,
            blur: 220,
            value: value,
            phase: 0.65,
          ),
        ],
      ),
    );
  }
}

class _AuroraBlob extends StatelessWidget {
  final Color color;
  final Alignment baseAlignment;
  final Offset travel;
  final double size;
  final double blur;
  final double value;
  final double phase;

  const _AuroraBlob({
    required this.color,
    required this.baseAlignment,
    required this.travel,
    required this.size,
    required this.blur,
    required this.value,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final double wave = math.sin((value + phase) * math.pi * 2);
    final Offset offset = Offset(travel.dx * wave, travel.dy * wave);
    return Align(
      alignment: Alignment(baseAlignment.x + offset.dx, baseAlignment.y + offset.dy),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: const SizedBox.shrink(),
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

class _TextSegment {
  final String text;
  final TextStyle style;
  const _TextSegment(this.text, this.style);
}

class _SplitTextLine extends StatelessWidget {
  final List<_TextSegment> segments;
  final AnimationController controller;
  final double stagger;
  final double offsetY;
  final double delayOffset;
  final double maxSpread;
  final double segmentDelay;

  const _SplitTextLine({
    required this.segments,
    required this.controller,
    this.stagger = 0.08,
    this.offsetY = 12,
    this.delayOffset = 0,
    this.maxSpread = 0.3,
    this.segmentDelay = 0.02,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = <_TextSegment>[];
    final tokenSegmentIndex = <int>[];
    for (var segIndex = 0; segIndex < segments.length; segIndex++) {
      final segment = segments[segIndex];
      final regex = RegExp(r'\S+');
      final matches = regex.allMatches(segment.text);
      if (matches.isEmpty) {
        tokens.add(_TextSegment(segment.text, segment.style));
        tokenSegmentIndex.add(segIndex);
        continue;
      }
      for (final match in matches) {
        tokens.add(_TextSegment(match.group(0) ?? '', segment.style));
        tokenSegmentIndex.add(segIndex);
      }
    }
    if (tokens.isEmpty) return const SizedBox.shrink();

    final int total = tokens.length;
    final double spread = (stagger * (total - 1)).clamp(0, maxSpread);
    final double step = total > 1 ? spread / (total - 1) : 0;

    const double wordGap = 8;
    const double charStagger = 0.025;

    return Wrap(
      spacing: 0,
      runSpacing: 0,
      alignment: WrapAlignment.start,
      children: List.generate(tokens.length, (index) {
        final double segmentOffset = segmentDelay * (tokenSegmentIndex[index]);
        final double rawStart = (index * step) + delayOffset + segmentOffset;
        final double clampedStart = rawStart.clamp(0, 0.99);
        final double clampedEnd = (clampedStart + 0.35).clamp(clampedStart + 0.01, 1);
        final anim = CurvedAnimation(
          parent: controller,
          curve: Interval(
            clampedStart,
            clampedEnd,
            curve: Curves.easeOut,
          ),
        );

        return Padding(
          padding: EdgeInsets.only(right: wordGap),
          child: AnimatedBuilder(
            animation: anim,
            builder: (context, child) {
              final double t = anim.value;
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, offsetY * (1 - t)),
                  child: _AnimatedWord(
                    word: tokens[index].text,
                    style: tokens[index].style,
                    controller: controller,
                    baseDelay: clampedStart,
                    charStagger: charStagger,
                    offsetY: offsetY,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _AnimatedWord extends StatelessWidget {
  final String word;
  final TextStyle style;
  final AnimationController controller;
  final double baseDelay;
  final double charStagger;
  final double offsetY;

  const _AnimatedWord({
    required this.word,
    required this.style,
    required this.controller,
    required this.baseDelay,
    this.charStagger = 0.025,
    this.offsetY = 12,
  });

  @override
  Widget build(BuildContext context) {
    final chars = word.split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(chars.length, (i) {
        final double start = (baseDelay + (i * charStagger)).clamp(0, 0.99);
        final double end = (start + 0.25).clamp(start + 0.01, 1);
        final anim = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (context, child) {
            final double t = anim.value;
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, offsetY * (1 - t)),
                child: child,
              ),
            );
          },
          child: Text(chars[i], style: style),
        );
      }),
    );
  }
}

class _TypingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Duration delay;

  const _TypingText({
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
  });

  @override
  State<_TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<_TypingText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final int count = (_controller.value * widget.text.length).floor().clamp(0, widget.text.length);
        final visible = widget.text.substring(0, count);
        return Text(visible, style: widget.style);
      },
    );
  }
}
