import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<_TutorialItem> _tutorials = const [
    _TutorialItem(
      title: 'Cara Membuat Chatbot Pertama Kamu',
      date: '10 Oktober 2025',
      category: 'Dasar',
    ),
    _TutorialItem(
      title: 'Cara Mendapatkan Link Referral Joyin',
      date: '10 Oktober 2025',
      category: 'Referral',
    ),
    _TutorialItem(
      title: 'Cara Upgrade / Downgrade Paket',
      date: '10 Oktober 2025',
      category: 'Paket',
    ),
    _TutorialItem(
      title: 'Tips Membuat Chatbot yang Lebih Personal',
      date: '10 Oktober 2025',
      category: 'Tips',
    ),
    _TutorialItem(
      title: 'Cara Menambahkan Balasan Otomatis Berbasis Kata Kunci',
      date: '10 Oktober 2025',
      category: 'Otomasi',
    ),
    _TutorialItem(
      title: 'Cara Mengimpor Kontak dari File CSV/Excel',
      date: '10 Oktober 2025',
      category: 'Kontak',
    ),
    _TutorialItem(
      title: 'Strategi Broadcast Pertama',
      date: '10 Oktober 2025',
      category: 'Broadcast',
    ),
    _TutorialItem(
      title: 'Optimasi Jam Aktif Bot',
      date: '10 Oktober 2025',
      category: 'Otomasi',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Pusat Tutorial',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF60CA86), Color(0xFFD9F27F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearch(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGrid(),
              ),
              const SizedBox(height: 28),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 360;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF60CA86), Color(0xFFD9F27F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroBadge(),
                    const SizedBox(height: 12),
                    Text(
                      'Belajar Joyin lebih praktis',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pelajari cara membuat chatbot, integrasi platform, sampai optimasi kampanye. Panduan singkat supaya kamu langsung praktik.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isNarrow) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Image.asset(
                    'assets/images/joy-stetoskop.png',
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
          hintText: 'Cari tutorial...',
          hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final filtered = _tutorials
        .where((item) => item.title.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 720;
        final double spacing = 12;
        final double cardWidth = isWide
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: filtered
              .map(
                (item) => SizedBox(
                  width: cardWidth,
                  child: _TutorialCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Image.asset(
            'assets/images/logo_joyin.png',
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Belajar lebih cepat,',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 6),
              Text(
                'buat pelanggan makin betah.',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo_joyin.png',
            height: 18,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Text(
            'Pusat Tutorial Joyin',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  final _TutorialItem item;

  const _TutorialCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 118,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_note_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.joyin.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.category,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                    color: AppColors.joyin,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat detail',
            style: GoogleFonts.poppins(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialItem {
  final String title;
  final String date;
  final String category;

  const _TutorialItem({
    required this.title,
    required this.date,
    required this.category,
  });
}
