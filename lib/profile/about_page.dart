import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text(
          'Tentang Joyin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _AboutHero(),
              SizedBox(height: 26),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _AboutStory(),
              ),
              SizedBox(height: 28),
              _AboutJourney(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutHero extends StatefulWidget {
  const _AboutHero();

  @override
  State<_AboutHero> createState() => _AboutHeroState();
}

class _AboutHeroState extends State<_AboutHero> {
  double _mascotKiriOffsetX = 0;
  double _mascotKiriOffsetY = -6;
  double _mascotKiriHeight = 200;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 150),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF5FCA84),
                Color(0xFFA6DF7B),
                Color(0xFFC7E87B),
                Colors.white,
              ],
              stops: [0.0, 0.4, 0.7, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/images/Bintang.png',
                  height: 36,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kenalan Yuk dengan Joyin!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Selamat datang di Joyin - teman bisnismu dalam mengelola percakapan pelanggan dengan cara yang lebih cerdas dan efisien. Kami percaya, komunikasi yang cepat dan hangat bisa bikin pelanggan makin nyaman dan loyal pada brand-mu.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: _mascotKiriOffsetX,
          bottom: _mascotKiriOffsetY,
          child: Image.asset(
            'assets/images/maskot-kiri-crop.png',
            height: _mascotKiriHeight,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned(
          right: 32,
          bottom: -54,
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
          padding: const EdgeInsets.fromLTRB(28, 44, 28, 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Joyin hadir untuk bantu kamu merespons otomatis selama 24 jam penuh, jadi bisnis tetap berjalan walau kamu lagi santai. Dengan sistem pintar kami, setiap interaksi terasa lebih personal tanpa perlu repot balas satu per satu.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.8,
                  color: const Color(0xFF1F252A),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Kami ingin menciptakan pengalaman pelanggan yang lebih ringan dan menyenangkan. Setiap pesan dibalas dengan cepat, namun tetap punya sentuhan manusia yang membuat pelanggan merasa diperhatikan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.8,
                  color: const Color(0xFF1F252A),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 32,
          bottom: 30,
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

class _AboutJourney extends StatefulWidget {
  const _AboutJourney();

  @override
  State<_AboutJourney> createState() => _AboutJourneyState();
}

class _AboutJourneyState extends State<_AboutJourney> {
  // Peeking mascot positioning variables for easy tuning
  double _mascotHeight = 120;
  double _mascotOffsetX = 100;
  double _mascotOffsetY = -18;
  double _joyCemerlangOffsetX = 0;
  double _joyCemerlangOffsetY = 70;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 70),
              decoration: const BoxDecoration(
                color: Color(0xFF9B59B6),
              ),
              child: Column(
                children: [
                  Text(
                    'Buat Chat Lebih Hidup Tanpa Ribet',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Text(
                              'Nggak perlu lagi begadang atau terus mantengin layar hanya demi respon cepat. Joyin siap bantu kamu tetap terhubung kapan pun, di mana pun, tanpa kehilangan rasa hangat dalam percakapan.',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                height: 1.6,
                                color: const Color(0xFFEFE7FF),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Dengan Joyin, cukup atur sekali dan biarkan chatbot kami bekerja untukmu – menjawab otomatis dengan gaya ramah dan natural, membuat pelanggan tetap dekat, dan bisnismu makin berkembang tanpa ribet.',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                height: 1.6,
                                color: const Color(0xFFEFE7FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Transform.translate(
                          offset: Offset(_joyCemerlangOffsetX, _joyCemerlangOffsetY),
                          child: Image.asset(
                            'assets/images/joycemerlang.png',
                            height: 210,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -80,
              child: Transform.translate(
                offset: Offset(_mascotOffsetX, _mascotOffsetY),
                child: _PeekingMascot(height: _mascotHeight),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Text(
          'Selalu Ada Ruang untuk Berkembang',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F252A),
          ),
        ),
      ],
    );
  }
}

class _PeekingMascot extends StatelessWidget {
  final double height;

  const _PeekingMascot({required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/joy-ngintip.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
