import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../widgets/gaps.dart';
import '../auth/login_page.dart';

enum _SlideLayout { hero, single, card }

// Custom physics to allow forward swiping but prevent backward swiping on first page
class _NoBackSwipePhysics extends ScrollPhysics {
  const _NoBackSwipePhysics({super.parent});

  @override
  _NoBackSwipePhysics applyTo(ScrollPhysics? ancestor) {
    return _NoBackSwipePhysics(parent: buildParent(ancestor));
  }

  @override
  bool get allowImplicitScrolling => false;

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Allow forward swiping (negative offset for RTL, positive for LTR in PageView)
    // but prevent backward swiping when at the first page
    if (position.pixels <= position.minScrollExtent && offset < 0) {
      // Prevent swiping back from the first page
      return 0.0;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    _OnboardingSlide.hero(
      title: 'Selamat datang di Joyin!',
      description:
          'Dengan chatbot Joyin, kamu nggak perlu nunggu lama lagi. Semua jawaban langsung tersedia dalam hitungan detik!',
      hero: _HeroConfig(
        leftAsset: 'assets/images/maskot_kiri.png',
        rightAsset: 'assets/images/maskot_kanan-crop.png',
        leftWidth: 360,
        rightWidth: 350, // Adjusted for cropped image
        leftAngleDeg: 50,
        rightAngleDeg: 0, // Horizontal orientation
        leftOffset: Offset(0, 0),
        rightOffset: Offset(0, 0),
      ),
    ),
    _OnboardingSlide.single(
      title: 'Siap membantumu 24/7',
      description:
          'Chatbot Joyin selalu siap sedia kapanpun kamu butuh. Tidak perlu menunggu lama, bantuan selalu ada disaat kamu butuh.',
      single: _SingleConfig(
        asset: 'assets/images/Joy_siaga.png',
        width: 250, // Adjusted width to fit layout
        angleDeg: 0,
        offset: Offset(0, -20), // Adjusted offset
      ),
    ),
    _OnboardingSlide.single(
      title: 'Lebih Hemat Waktu',
      description:
          'Fokus pada bisnismu, biarkan Joyin menghemat waktumu dengan respon cepat dan cerdas.',
      single: _SingleConfig(
        asset: 'assets/images/Joy Hemat Waktu.png',
        width: 250,
        angleDeg: 0,
        offset: Offset(0, -20),
      ),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_index >= _slides.length - 1) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    final pagePhysics = _index == 0
        ? const _NoBackSwipePhysics()
        : const BouncingScrollPhysics();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDAEC75), // Top gradient color
              Color(0xFF5FCAAC), // Bottom gradient color
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 10, 28, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset('assets/images/logo_joyin.png', width: 74),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  physics: pagePhysics,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, i) => _SlideBody(slide: _slides[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 10, 28, 20),
                child: Column(
                  children: [
                    _Indicators(length: _slides.length, current: _index),
                    gap(22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.joyin,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              slide.cta,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideBody extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SlideBody({required this.slide});

  @override
  Widget build(BuildContext context) {
    final Widget content;
    switch (slide.layout) {
      case _SlideLayout.hero:
        content = _HeroSlide(slide: slide);
        break;
      case _SlideLayout.single:
        content = _SingleSlide(slide: slide);
        break;
      case _SlideLayout.card:
        content = _CardSlide(slide: slide);
        break;
    }

    return Padding(
      padding: EdgeInsets.only(top: slide.topSpacing),
      child: content,
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final _OnboardingSlide slide;
  const _HeroSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    // Validasi bahwa konfigurasi hero tersedia
    if (slide.hero == null) {
      return const SizedBox.shrink(); // atau widget fallback
    }

    final cfg = slide.hero!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Builder(
            builder: (context) {
              final media = MediaQuery.of(context);
              final contentWidth = media.size.width;
              if (contentWidth <= 0) {
                return const SizedBox.shrink();
              }
              final baseMascot = (contentWidth * 0.86).clamp(260.0, 380.0);
              final leftWidth = math.min(cfg.leftWidth, baseMascot * 0.9);
              final rightWidth = math.min(cfg.rightWidth, baseMascot * 1.1);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Maskot kiri (mirror) - mentok ke kiri seperti di landing page
                  Positioned(
                    left: -100,
                    top: 20,
                    child: Transform.rotate(
                      angle: 50 * math.pi / 180,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
                        child: SizedBox(
                          width: leftWidth,
                          height: leftWidth,
                          child: Image.asset(
                            cfg.leftAsset,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Maskot kanan - positioned on the right side horizontally with increased size
                  Positioned(
                    right: -90, // Adjusted position for larger size
                    top: 20, // Adjusted vertical position for better alignment
                    child: Transform.rotate(
                      angle: 0, // Horizontal orientation (no rotation)
                      child: SizedBox(
                        width: rightWidth * 0.95, // Slightly larger width
                        height: rightWidth * 0.95, // Slightly larger height
                        child: Image.asset(cfg.rightAsset, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        gap(24),
        _SlideTexts(slide: slide),
      ],
    );
  }
}

class _SingleSlide extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SingleSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    // Validasi bahwa konfigurasi single tersedia
    if (slide.single == null) {
      return const SizedBox.shrink(); // atau widget fallback
    }

    final cfg = slide.single!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: cfg.offset,
              child: Transform.rotate(
                angle: cfg.angleDeg * math.pi / 180,
                child: Image.asset(
                  cfg.asset,
                  width: cfg.width,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        gap(12),
        _SlideTexts(slide: slide),
      ],
    );
  }
}

class _CardSlide extends StatelessWidget {
  final _OnboardingSlide slide;
  const _CardSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    // Validasi bahwa konfigurasi card tersedia
    if (slide.card == null) {
      return const SizedBox.shrink(); // atau widget fallback
    }

    final cfg = slide.card!;

    final imageSize = math.min(cfg.imageWidth, cfg.circleDiameter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: cfg.cardWidth,
              child: Image.asset(
                cfg.asset,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        gap(24),
        _SlideTexts(slide: slide),
      ],
    );
  }
}

class _SlideTexts extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SlideTexts({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          gap(12),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color.fromRGBO(255, 255, 255, 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Indicators extends StatelessWidget {
  final int length;
  final int current;
  const _Indicators({required this.length, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: i == current ? 18 : 6,
            decoration: BoxDecoration(
              color: i == current
                  ? Colors.white
                  : const Color.fromRGBO(255, 255, 255, 0.45),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _OnboardingSlide {
  final _SlideLayout layout;
  final String title;
  final String description;
  final String cta;
  final double topSpacing;
  final _HeroConfig? hero;
  final _SingleConfig? single;
  final _CardConfig? card;

  const _OnboardingSlide._({
    required this.layout,
    required this.title,
    required this.description,
    required this.cta,
    this.topSpacing = 0,
    this.hero,
    this.single,
    this.card,
  });

  const _OnboardingSlide.hero({
    required String title,
    required String description,
    required _HeroConfig hero,
    String cta = 'Selanjutnya',
    double topSpacing = 28,
  }) : this._(
         layout: _SlideLayout.hero,
         title: title,
         description: description,
         cta: cta,
         topSpacing: topSpacing,
         hero: hero,
       );

  const _OnboardingSlide.single({
    required String title,
    required String description,
    required _SingleConfig single,
    String cta = 'Selanjutnya',
    double topSpacing = 10,
  }) : this._(
         layout: _SlideLayout.single,
         title: title,
         description: description,
         cta: cta,
         topSpacing: topSpacing,
         single: single,
       );
}

class _HeroConfig {
  final String leftAsset;
  final String rightAsset;
  final double leftWidth;
  final double rightWidth;
  final double leftAngleDeg;
  final double rightAngleDeg;
  // Fine-tuning offsets applied after bottom-anchored mascot placement.
  final Offset leftOffset;
  final Offset rightOffset;
  const _HeroConfig({
    required this.leftAsset,
    required this.rightAsset,
    required this.leftWidth,
    required this.rightWidth,
    required this.leftAngleDeg,
    required this.rightAngleDeg,
    required this.leftOffset,
    required this.rightOffset,
  });
}

class _SingleConfig {
  final String asset;
  final double width;
  final double angleDeg;
  final Offset offset;
  const _SingleConfig({
    required this.asset,
    required this.width,
    required this.angleDeg,
    required this.offset,
  });
}

class _CardConfig {
  final String asset;
  final double cardWidth;
  final double circleDiameter;
  final double imageWidth;
  const _CardConfig({
    required this.asset,
    required this.cardWidth,
    required this.circleDiameter,
    required this.imageWidth,
  });
}
