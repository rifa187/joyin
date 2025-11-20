import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/auth/login_page.dart';
import 'package:joyin/package/package_info.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:provider/provider.dart';

class PilihPaketScreen extends StatelessWidget {
  const PilihPaketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _WaveBackground(),
          Positioned(
            bottom: 120,
            left: MediaQuery.of(context).size.width * 0.18,
            child: Transform.rotate(
              angle: -0.2,
              child: Image.asset(
                'assets/images/Bintang.png',
                width: 45,
                color: Colors.white.withAlpha(204),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Transform.rotate(
              angle: 0.1,
              child: Image.asset(
                'assets/images/Bintang.png',
                width: 30,
                color: Colors.white.withAlpha(204),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: MediaQuery.of(context).size.width * 0.06,
            child: Transform.rotate(
              angle: 0.3,
              child: Image.asset(
                'assets/images/Bintang.png',
                width: 25,
                color: Colors.white.withAlpha(204),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Image.asset('assets/images/Joy Kagum.png', height: 230),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Temukan Paket yang Paling Cocok untukmu',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00796B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: packageProvider.packages.length,
                    onPageChanged: (index) {
                      // No need to set state here, we can use the PageController's page property
                    },
                    itemBuilder: (context, index) {
                      return _buildPackageCard(
                        context,
                        index,
                        pageController,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Add dots indicator here if needed
                const SizedBox(height: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    int index,
    PageController pageController,
  ) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final packageInfo = packageProvider.packages[index];

    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double value = 1.0;
        if (pageController.position.haveDimensions) {
          value = pageController.page! - index;
          value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
        }
        return Transform.scale(scale: value, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF304), Color(0xFFF09EF1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(26.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF09EF1).withAlpha(128),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(gradient: packageInfo.gradient),
                  child: Column(
                    children: [
                      Text(
                        'Paket ${packageInfo.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        packageInfo.price,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlpha(230),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: packageInfo.features
                                        .map(
                                          (feature) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 9,
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check,
                                                  color: Color(0xFF56AB2F),
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    feature,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13.5,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _selectPackage(context, index),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.black.withAlpha(51),
                                      elevation: 6,
                                    ).copyWith(
                                      overlayColor: MaterialStateProperty.all(
                                        Colors.white.withAlpha(25),
                                      ),
                                      textStyle: MaterialStateProperty.all(
                                        GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF5FCA84),
                                            Color(0xFFA8DE7B),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        constraints: const BoxConstraints(
                                          minHeight: 48,
                                        ),
                                        child: Text(
                                          'Pilih ${packageInfo.name}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectPackage(BuildContext context, int index) {
    final packageProvider = Provider.of<PackageProvider>(
      context,
      listen: false,
    );
    final packageInfo = packageProvider.packages[index];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(selectedPackage: packageInfo),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double yOffset;
  final double curveHeight;

  _WaveClipper({required this.yOffset, required this.curveHeight});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * yOffset);
    path.quadraticBezierTo(
      size.width / 2,
      size.height * (yOffset + curveHeight),
      size.width,
      size.height * yOffset,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) =>
      yOffset != oldClipper.yOffset || curveHeight != oldClipper.curveHeight;
}

class _WaveBackground extends StatelessWidget {
  const _WaveBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFDAEC75), Color(0xFF5FCAAC)],
            ),
          ),
        ),
        ClipPath(
          clipper: _WaveClipper(yOffset: 0.31, curveHeight: 0.12),
          child: Container(color: Colors.white.withAlpha(77)),
        ),
        ClipPath(
          clipper: _WaveClipper(yOffset: 0.30, curveHeight: 0.10),
          child: Container(color: Colors.white),
        ),
      ],
    );
  }
}
