import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/widgets/locked_feature_widget.dart';
import 'package:provider/provider.dart';
import '../package/package_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _cardFade;
  late final Animation<double> _cardSlide;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

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
    _cardFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1, curve: Curves.easeOut),
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
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage =
        packageProvider.currentUserPackage != null && packageProvider.currentUserPackage!.isNotEmpty;
    final packageTheme = PackageThemeResolver.resolve(packageProvider.currentUserPackage);
    final accent = packageTheme.accent;

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
                child: FadeTransition(
                  opacity: _cardFade,
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
                            color: accent.withOpacity(0.12),
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
                                child: _buildChatBody(accent),
                              ),
                            )
                          : const LockedFeatureWidget(
                              title: 'Fitur Terkunci',
                              message: 'Upgrade paketmu untuk membuka halaman Obrolan dan fitur terkait.',
                              icon: Icons.chat_bubble_outline,
                            ),
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
          Text(
            'Obrolan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pantau percakapan pelanggan dan tetap responsif di semua channel.',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody(Color accent) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildHeaderTile(accent),
        const SizedBox(height: 16),
        _buildAnimatedCard(_buildEmptyState(accent)),
        const SizedBox(height: 14),
        _buildAnimatedCard(_buildQuickActions(accent)),
        const SizedBox(height: 14),
        _buildAnimatedCard(_buildFilters(accent)),
        const SizedBox(height: 20),
        _buildAnimatedCard(_buildCTA(accent)),
      ],
    );
  }

  Widget _buildHeaderTile(Color accent) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [accent, accent.withOpacity(0.6)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Obrolan Pelanggan', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Pantau percakapan, balas cepat, dan aktifkan bot untuk auto-reply.',
              style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: accent.withOpacity(0.12),
            child: Icon(Icons.chat_bubble_outline, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada percakapan',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mulai obrolan baru atau hubungkan channel untuk melihat chat di sini.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Color accent) {
    return Row(
      children: [
        Expanded(
          child: _actionChip(
            icon: Icons.add_comment_rounded,
            label: 'Buat chat baru',
            accent: accent,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionChip(
            icon: Icons.link_rounded,
            label: 'Hubungkan channel',
            accent: accent,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionChip(
            icon: Icons.auto_awesome_rounded,
            label: 'Aktifkan bot',
            accent: accent,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _actionChip({required IconData icon, required String label, required Color accent, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(Color accent) {
    final filters = ['Semua', 'Belum dibalas', 'Butuh follow-up', 'Bot aktif'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = filters[index];
          final selected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? accent.withOpacity(0.12) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? accent : Colors.grey.shade300),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: selected ? accent : Colors.grey[700],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCTA(Color accent) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              shadowColor: accent.withOpacity(0.4),
            ),
            onPressed: () {},
            child: Text(
              'Mulai Obrolan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tip: hubungkan WhatsApp/IG untuk menarik percakapan ke sini.',
          style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}
