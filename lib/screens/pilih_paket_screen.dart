import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/core/app_colors.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/screens/payment_screen.dart';
import 'package:provider/provider.dart';
import '../package/package_theme.dart';
import '../package/package_info.dart';

class PilihPaketScreen extends StatelessWidget {
  const PilihPaketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final defaultTheme = PackageThemeResolver.resolve(
      packageProvider.packages.isNotEmpty ? packageProvider.packages.first.name : null,
    );
    if (packageProvider.packages.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text('Memuat paket...', style: GoogleFonts.poppins()),
            ],
          ),
        ),
      );
    }
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
                      color: defaultTheme.accent,
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
                AnimatedBuilder(
                  animation: pageController,
                  builder: (context, _) {
                    final double currentPage =
                        pageController.hasClients ? (pageController.page ?? 0.0) : 0.0;
                    return _buildPageIndicator(
                      packages: packageProvider.packages,
                      currentPage: currentPage,
                    );
                  },
                ),
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
    final packageTheme = PackageThemeResolver.resolve(packageInfo.name);
    final isActive = packageProvider.currentUserPackage?.toLowerCase() == packageInfo.name.toLowerCase();

    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double value = 1.0;
        if (pageController.position.haveDimensions) {
          value = pageController.page! - index;
          value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0).toDouble();
        }
        return Transform.scale(scale: value, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: packageTheme.cardGradient),
                borderRadius: BorderRadius.circular(26.0),
                boxShadow: [
                  BoxShadow(
                    color: packageTheme.cardGradient.last.withAlpha(128),
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: packageTheme.headerGradient),
                      ),
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
                                                    Icon(
                                                      Icons.check,
                                                      color: packageTheme.accent,
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
                                        onPressed: isActive ? null : () => _selectPackage(context, index),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.black.withValues(alpha: 0.2),
                                          elevation: 6,
                                          disabledBackgroundColor: Colors.grey.shade300,
                                          disabledForegroundColor: Colors.grey.shade700,
                                        ).copyWith(
                                          overlayColor: WidgetStateProperty.all(
                                            Colors.white.withValues(alpha: 0.1),
                                          ),
                                          textStyle: WidgetStateProperty.all(
                                            GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: packageTheme.cardGradient),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            constraints: const BoxConstraints(
                                              minHeight: 48,
                                            ),
                                            child: Text(
                                              isActive ? 'Paket Aktif' : 'Pilih ${packageInfo.name}',
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
            if (isActive)
              Positioned(
                top: 12,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: packageTheme.accent),
                  ),
                  child: Text(
                    'Aktif',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: packageTheme.accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator({required List<PackageInfo> packages, required double currentPage}) {
    if (packages.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: packages.asMap().entries.map((entry) {
        final idx = entry.key;
        final theme = PackageThemeResolver.resolve(entry.value.name);
        final isActive = (currentPage.round() == idx);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 22 : 8,
          decoration: BoxDecoration(
            color: isActive ? theme.accent : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }).toList(),
    );
  }

  void _selectPackage(BuildContext context, int index) {
    final packageProvider = Provider.of<PackageProvider>(
      context,
      listen: false,
    );
    final packageInfo = packageProvider.packages[index];
    final packageTheme = PackageThemeResolver.resolve(packageInfo.name);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Konfirmasi Paket',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Paket ${packageInfo.name} - ${packageInfo.price}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: packageTheme.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Fitur yang kamu dapat:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...packageInfo.features
                  .map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: packageTheme.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              packageName: packageInfo.name,
                              packagePrice: packageInfo.price,
                              packageFeatures: packageInfo.features,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.joyin,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Lanjutkan Pembayaran',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

