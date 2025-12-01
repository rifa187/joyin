import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          'Tentang Joyin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.grad1, AppColors.grad3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _AboutHero(),
              SizedBox(height: 22),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _AboutHighlights(),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _AboutStory(),
              ),
              SizedBox(height: 26),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _AboutJourney(),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 170),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF5FCA84),
                Color(0xFF7FDB84),
                Color(0xFFC7E87B),
                Colors.white,
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/Bintang.png',
                    height: 32,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    'assets/images/bintang2.png',
                    height: 22,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Joyin hadir menemani bisnis bertumbuh',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Balas chat lebih cepat, tetap hangat, dan selalu on untuk pelangganmu.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.92),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _heroChip(Icons.flash_on_rounded, 'Respon otomatis 24/7'),
                  _heroChip(Icons.handshake_rounded, 'Ramah & personal'),
                  _heroChip(Icons.auto_graph_rounded, 'Bantu konversi naik'),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: -10,
          bottom: -14,
          child: Image.asset(
            'assets/images/maskot-kiri-crop.png',
            height: 220,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned(
          right: 20,
          bottom: -70,
          child: Column(
            children: [
              Image.asset(
                'assets/images/bintang2.png',
                height: 24,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 6),
              Image.asset(
                'assets/images/Bintang.png',
                height: 36,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heroChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHighlights extends StatelessWidget {
  const _AboutHighlights();

  @override
  Widget build(BuildContext context) {
    final cards = [
      _Highlight(
        title: 'Chat respons 24/7',
        subtitle: 'Bot siap menyapa pelanggan meski kamu lagi offline.',
        icon: Icons.nights_stay_rounded,
        accent: AppColors.grad1,
      ),
      _Highlight(
        title: 'Sentuhan manusiawi',
        subtitle: 'Bahasa natural biar pelanggan tetap merasa dekat.',
        icon: Icons.emoji_emotions_rounded,
        accent: AppColors.grad2,
      ),
      _Highlight(
        title: 'Fokus ke hasil',
        subtitle: 'Optimalkan konversi penjualan & retensi pelanggan.',
        icon: Icons.trending_up_rounded,
        accent: AppColors.grad3,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/joy-ngintip.png',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            Text(
              'Kenapa Joyin beda?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: cards
              .map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.accent.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.icon, color: item.accent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AboutStory extends StatelessWidget {
  const _AboutStory();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cerita singkat Joyin',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Joyin lahir untuk bantu UMKM dan brand membalas chat pelanggan tanpa kehilangan rasa hangat. Bot kami siaga 24 jam, pakai bahasa natural, dan siap meneruskan ke tim ketika dibutuhkan.',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Misi kami sederhana: bikin percakapan lebih hidup, membantu konversi naik, dan menjaga pelanggan merasa diperhatikan kapan pun mereka mengetuk pintu chatmu.',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 24,
          bottom: -12,
          child: Image.asset(
            'assets/images/bintang2.png',
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _AboutJourney extends StatelessWidget {
  const _AboutJourney();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _JourneyCard(
          title: 'Buat chat lebih hidup',
          description:
              'Joyin memastikan setiap pesan dibalas cepat tanpa terlihat kaku. Kamu cukup atur skenario sekali, chatbot kami menjaga ritme dan meneruskan ke tim jika perlu.',
          background: const Color(0xFFF1FFF8),
          accent: AppColors.grad1,
          image: 'assets/images/joy-ngintip.png',
          imageHeight: 110,
        ),
        const SizedBox(height: 16),
        _JourneyCard(
          title: 'Dukungan onboarding penuh',
          description:
              'Tim Joyin siap menemani setup bot, impor kontak, sampai optimasi pesan broadcast supaya pelanggan makin betah.',
          background: Colors.white,
          accent: AppColors.grad2,
          image: 'assets/images/joycemerlang.png',
          imageHeight: 180,
        ),
        const SizedBox(height: 16),
        _JourneyCard(
          title: 'Selalu ada ruang untuk berkembang',
          description:
              'Kami terus menambah insight otomatis, integrasi channel, dan automasi supaya bisnismu bisa fokus ke hal yang paling penting: pelanggan.',
          background: const Color(0xFFF8FBF4),
          accent: AppColors.grad3,
          image: 'assets/images/Bintang.png',
          imageHeight: 44,
          trailingOverlay: Image.asset(
            'assets/images/bintang2.png',
            height: 26,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final String title;
  final String description;
  final Color background;
  final Color accent;
  final String image;
  final double imageHeight;
  final Widget? trailingOverlay;

  const _JourneyCard({
    required this.title,
    required this.description,
    required this.background,
    required this.accent,
    required this.image,
    required this.imageHeight,
    this.trailingOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              Image.asset(
                image,
                height: imageHeight,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              if (trailingOverlay != null)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: trailingOverlay!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Highlight {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _Highlight({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}
