import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

const double _kMaxContentWidth = 920;

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              _SectionHero(),
              SizedBox(height: 18),
              _SectionPurple(),
              SizedBox(height: 18),
              _SectionGrowth(),
              SizedBox(height: 18),
              _SectionCta(),
              SizedBox(height: 24),
              _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHero extends StatelessWidget {
  const _SectionHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 74),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6FDE94), Color(0xFFF3FFCC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Kenalan Yuk dengan Joyin!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selamat datang di Joyin - teman bisnismu dalam mengelola percakapan pelanggan dengan cara yang lebih cerdas dan efisien. Kami percaya, komunikasi yang cepat dan hangat bisa bikin pelanggan makin nyaman dan loyal pada brand-mu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Joyin hadir untuk bantu kamu merespons otomatis selama 24 jam penuh, jadi bisnis tetap berjalan walau kamu lagi santai. Dengan sistem pintar kami, setiap interaksi terasa lebih personal tanpa perlu repot balas satu per satu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 13.5,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Kami ingin menciptakan pengalaman pelanggan yang lebih ringan dan menyenangkan. Setiap pesan dibalas dengan cepat, namun tetap punya sentuhan manusia yang membuat pelanggan merasa diperhatikan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 13.5,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: -10,
          bottom: -14,
          child: Image.asset(
            'assets/images/maskot-kiri-crop.png',
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned(
          right: 20,
          bottom: -50,
          child: Image.asset(
            'assets/images/joy-ngintip.png',
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned(
          top: 10,
          left: 16,
          child: Image.asset(
            'assets/images/Bintang.png',
            height: 28,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned(
          top: 18,
          right: 28,
          child: Image.asset(
            'assets/images/bintang2.png',
            height: 18,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: SafeArea(child: _BackButton()),
        ),
      ],
    );
  }
}

class _SectionPurple extends StatelessWidget {
  const _SectionPurple();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 34, 20, 34),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8C5CF6), Color(0xFF6ACCC2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
              child: Column(
                children: [
                  Text(
                    'Buat Chat Lebih Hidup Tanpa Ribet',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 760;
                      final leftCopy = Text(
                        'Nggak perlu lagi begadang atau terus mantengin layar hanya demi respon cepat. Joyin siap bantu kamu tetap terhubung kapan pun, di mana pun, tanpa kehilangan rasa hangat dalam percakapan.',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      );
                      final rightCopy = Text(
                        'Dengan Joyin, cukup atur sekali dan biarkan chatbot kami bekerja untukmu - menjawab otomatis dengan gaya ramah dan natural, membuat pelanggan tetap dekat, dan bisnismu makin berkembang tanpa ribet.',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      );
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            leftCopy,
                            const SizedBox(height: 16),
                            rightCopy,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: leftCopy),
                          const SizedBox(width: 16),
                          Expanded(child: rightCopy),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/joycemerlang.png',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -30,
          left: 12,
          child: Image.asset(
            'assets/images/bintang2.png',
            height: 22,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _SectionGrowth extends StatelessWidget {
  const _SectionGrowth();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 38, 24, 42),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF0EBFF), Color(0xFFFDFDFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 12),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxContentWidth * 0.8),
            child: Column(
              children: [
                Text(
                  'Selalu Ada Ruang untuk Berkembang',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Kami percaya setiap bisnis punya cara unik buat terhubung dengan pelanggan. Karena itu, Joyin terus berkembang biar bisa menyesuaikan diri dengan gaya komunikasi bisnismu - dari obrolan santai sampai layanan profesional, semua bisa kamu atur dengan mudah.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCta extends StatelessWidget {
  const _SectionCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8C5CF6), Color(0xFF63D1BE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
          child: Column(
            children: [
              Text(
                'Yuk, Tumbuh Bareng Joyin!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Gabung bareng kami dan biarkan Joyin bantu bisnismu tumbuh lebih cepat dan lebih dekat dengan pelanggan.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CtaIconButton(assetPath: 'assets/images/mail.png'),
                  const SizedBox(width: 16),
                  _CtaIconButton(assetPath: 'assets/images/whatsapp.png'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 720;
                  final brand = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logo_joyin.png',
                        height: 38,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ],
                  );
                  final quickLinks = _FooterColumn(
                    title: 'Quick Links',
                    items: const ['Fitur', 'Reseller', 'Tentang Kami'],
                  );
                  final support = _FooterColumn(
                    title: 'Support',
                    items: const ['FAQ', 'Kebijakan Privasi', 'Syarat dan Ketentuan'],
                  );
                  final contact = _FooterColumn(
                    title: 'Contact Us',
                    children: [
                      _FooterIconRow(
                        icon: Icons.email_outlined,
                        label: 'joyin.id@gmail.com',
                      ),
                      _FooterIconRow(
                        icon: Icons.phone_outlined,
                        label: '+62 812-5472-9898',
                      ),
                      _FooterIconRow(
                        icon: Icons.access_time,
                        label: 'Senin - Jumat, 09:00 - 17:00 WITA',
                      ),
                    ],
                  );

                  final contentChildren = [
                    Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: brand)),
                    Expanded(child: quickLinks),
                    Expanded(child: support),
                    Expanded(child: contact),
                  ];

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brand,
                        const SizedBox(height: 18),
                        quickLinks,
                        const SizedBox(height: 16),
                        support,
                        const SizedBox(height: 16),
                        contact,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: contentChildren,
                  );
                },
              ),
              const SizedBox(height: 22),
              Text(
                '© 2025 Joyin.id. All rights reserved.',
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.52),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String>? items;
  final List<Widget>? children;

  const _FooterColumn({
    required this.title,
    this.items,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final bodyChildren = <Widget>[
      Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 10),
      if (items != null)
        ...items!.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              item,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      if (children != null) ...children!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bodyChildren,
    );
  }
}

class _FooterIconRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterIconRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textPrimary.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaIconButton extends StatelessWidget {
  final String assetPath;
  const _CtaIconButton({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Image.asset(
        assetPath,
        height: 36,
        width: 36,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).maybePop(),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
