import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:provider/provider.dart';
import 'package_theme.dart';
import '../screens/pilih_paket_screen.dart';

class PackageStatusPage extends StatefulWidget {
  const PackageStatusPage({super.key});

  @override
  State<PackageStatusPage> createState() => _PackageStatusPageState();
}

class _PackageStatusPageState extends State<PackageStatusPage> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage = packageProvider.currentUserPackage != null &&
        packageProvider.currentUserPackage!.isNotEmpty;
    final selectedName = packageProvider.currentUserPackage;
    final selectedDuration = selectedName != null
        ? packageProvider.selectedDurations[selectedName] ?? 1
        : 1;
    final selectedPackage = selectedName == null
        ? null
        : packageProvider.packages.firstWhere(
            (p) => p.name == selectedName,
            orElse: () => packageProvider.packages.first,
          );

    final PackageTheme theme = PackageThemeResolver.resolve(selectedPackage?.name);
    final Color accentColor = theme.accent;

    final now = DateTime.now();
    final dueDate = now.add(Duration(days: 30 * selectedDuration));
    final int daysLeft = dueDate.difference(now).inDays.clamp(0, 3650);
    final int totalDays = (30 * selectedDuration).clamp(1, 3650);
    final double progress = (daysLeft / totalDays).clamp(0, 1);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: hasPackage
              ? SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAnimatedSection(
                        start: 0.0,
                        end: 0.4,
                        child: _buildHeader(selectedPackage?.name ?? 'Paket Aktif', theme, daysLeft, selectedDuration, dueDate, progress, accentColor, context),
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedSection(
                        start: 0.2,
                        end: 0.6,
                        child: _buildPackageActions(context, accentColor),
                      ),
                      const SizedBox(height: 18),
                      _buildAnimatedSection(
                        start: 0.35,
                        end: 0.9,
                        child: _buildFeatureSection(selectedPackage?.features ?? [], accentColor),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAnimatedSection(
                        start: 0.0,
                        end: 0.4,
                        child: _buildPrePurchaseHero(accentColor, theme),
                      ),
                      const SizedBox(height: 18),
                      _buildAnimatedSection(
                        start: 0.2,
                        end: 0.65,
                        child: _PrePurchaseCard(
                          title: 'Kenapa harus upgrade?',
                          items: const [
                            'Balas otomatis 24/7 tanpa kehilangan sentuhan personal.',
                            'Bot siap pakai untuk alur chat, FAQ, dan broadcast.',
                            'Laporan ringkas untuk pantau performa tim dan pesan.',
                          ],
                          accent: accentColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildAnimatedSection(
                        start: 0.35,
                        end: 0.9,
                        child: _PrePurchaseCard(
                          title: 'Langkah cepat',
                          items: const [
                            'Pilih paket yang sesuai kebutuhan timmu.',
                            'Hubungkan channel chat utama dan atur bot.',
                            'Mulai kirimkan broadcast atau quick reply ke pelanggan.',
                          ],
                          accent: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({
    required double start,
    required double end,
    required Widget child,
  }) {
    final fade = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      ),
    );
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }

  Widget _buildHeader(
    String packageName,
    PackageTheme theme,
    int daysLeft,
    int durationMonths,
    DateTime dueDate,
    double progress,
    Color accentColor,
    BuildContext context,
  ) {
    final dateFormatter = DateFormat('d MMMM yyyy', 'id_ID');
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Paket $packageName',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Atur dan cek status paket langganan Anda',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 640;
              final pillWidth = isWide ? (constraints.maxWidth - 20) / 3 : constraints.maxWidth;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: pillWidth,
                    child: _StatPill(
                      label: 'Durasi Langganan',
                      value: '$durationMonths Bulan',
                      accent: accentColor,
                    ),
                  ),
                  SizedBox(
                    width: pillWidth,
                    child: _StatPill(
                      label: 'Masa Aktif',
                      value: '$daysLeft Hari Lagi',
                      accent: accentColor,
                      progress: progress,
                    ),
                  ),
                  SizedBox(
                    width: pillWidth,
                    child: _StatPill(
                      label: 'Jatuh Tempo',
                      value: dateFormatter.format(dueDate),
                      accent: accentColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildPrePurchaseHero(Color accentColor, PackageTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, theme.headerGradient.last],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.26),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mulai dengan Paket Joyin',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih paket yang cocok untuk bisnis kamu dan nikmati balasan otomatis, bot cerdas, serta laporan yang siap pakai.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PilihPaketScreen()),
                );
              },
              child: Text(
                'Lihat Pilihan Paket',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageActions(BuildContext context, Color accentColor) {
    final buttonTextStyle = GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w700,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PilihPaketScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text('Perpanjang Paket', style: buttonTextStyle),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PilihPaketScreen()));
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Upgrade Paket', style: buttonTextStyle.copyWith(color: Colors.white)),
        ),
        OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permintaan pembatalan paket terkirim.')),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Batalkan Paket', style: buttonTextStyle.copyWith(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildFeatureSection(List<String> features, Color accentColor) {
    final icons = <IconData>[
      Icons.chat_bubble_outline,
      Icons.rule_folder_outlined,
      Icons.access_time,
      Icons.query_stats_outlined,
      Icons.integration_instructions_outlined,
      Icons.help_outline,
      Icons.auto_graph,
      Icons.security_update_good_outlined,
    ];

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fitur yang Didapatkan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 640;
              final double cardWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: features.asMap().entries.map((entry) {
                  final index = entry.key;
                  final text = entry.value;
                  final icon = icons[index % icons.length];
                  return SizedBox(
                    width: cardWidth,
                    child: _FeatureCard(
                      icon: icon,
                      title: text.split(' ').take(3).join(' '),
                      description: text,
                      accent: accentColor,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final double? progress;
  final Color accent;

  const _StatPill({
    required this.label,
    required this.value,
    required this.accent,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              tween: Tween(begin: 0, end: progress!.clamp(0, 1)),
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
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
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
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

class _PrePurchasePackageView extends StatelessWidget {
  final Color accentColor;
  final PackageTheme theme;

  const _PrePurchasePackageView({
    required this.accentColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.headerGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, theme.headerGradient.last],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.26),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mulai dengan Paket Joyin',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih paket yang cocok untuk bisnis kamu dan nikmati balasan otomatis, bot cerdas, serta laporan yang siap pakai.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PilihPaketScreen()),
                          );
                        },
                        child: Text(
                          'Lihat Pilihan Paket',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _PrePurchaseCard(
                title: 'Kenapa harus upgrade?',
                items: const [
                  'Balas otomatis 24/7 tanpa kehilangan sentuhan personal.',
                  'Bot siap pakai untuk alur chat, FAQ, dan broadcast.',
                  'Laporan ringkas untuk pantau performa tim dan pesan.',
                ],
                accent: accentColor,
              ),
              const SizedBox(height: 14),
              _PrePurchaseCard(
                title: 'Langkah cepat',
                items: const [
                  'Pilih paket yang sesuai kebutuhan timmu.',
                  'Hubungkan channel chat utama dan atur bot.',
                  'Mulai kirimkan broadcast atau quick reply ke pelanggan.',
                ],
                accent: accentColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrePurchaseCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color accent;

  const _PrePurchaseCard({
    required this.title,
    required this.items,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
