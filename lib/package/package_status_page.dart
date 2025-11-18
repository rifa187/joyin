import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/providers/user_provider.dart';
import 'package:joyin/screens/pilih_paket_screen.dart';
import 'package:provider/provider.dart';

import '../core/user_model.dart';
import 'package:joyin/package/package_info.dart';

class PackageStatusPage extends StatelessWidget {
  const PackageStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: user != null && user.hasPurchasedPackage
          ? _buildPackageDetails(context, user, packageProvider)
          : _buildNoPackage(context, user),
    );
  }

  Widget _buildPackageDetails(
    BuildContext context,
    User user,
    PackageProvider packageProvider,
  ) {
    final selectedPackageInfo = packageProvider.packages.firstWhere(
      (pkg) => pkg.name == packageProvider.currentUserPackage,
      orElse: () => packageProvider.packages.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Paket Anda Saat Ini', Icons.workspace_premium),
        const SizedBox(height: 20),
        _buildCurrentPackageCard(
          user,
          selectedPackageInfo,
          packageProvider.currentUserPackage,
        ),
        const SizedBox(height: 30),
        _buildUpgradeButton(context, user),
      ],
    );
  }

  Widget _buildCurrentPackageCard(
    User user,
    PackageInfo selectedPackageInfo,
    String? currentPackage,
  ) {
    const outlineGradient = LinearGradient(
      colors: [Color(0xFFFFF304), Color(0xFFF09EF1)], // Yellow to Pink
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final packageGradient = const LinearGradient(
      colors: [Color(0xFF63D1BE), Color(0xFF88E285)], // Green gradient
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(2.5), // Outline thickness
        decoration: BoxDecoration(
          gradient: outlineGradient,
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
                decoration: BoxDecoration(gradient: packageGradient),
                child: Column(
                  children: [
                    Text(
                      'Paket ${currentPackage ?? 'Tidak Ada'}', // Handle null case
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (user.packageDurationMonths != null &&
                        user.packageDurationMonths! > 0)
                      Text(
                        'Durasi: ${user.packageDurationMonths} Bulan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlpha(230),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      'Aktif',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keuntungan Paket:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...selectedPackageInfo.features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
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
                      ),
                      const SizedBox(height: 20),
                      if (user.packageDurationMonths != null &&
                          user.packageDurationMonths! > 0)
                        Text(
                          'Anda membeli paket ini selama ${user.packageDurationMonths} bulan.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context, User? user) {
    return ElevatedButton(
      onPressed: () {
        if (user != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PilihPaketScreen()),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5FCAAC),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: const Color(0xFF5FCAAC).withAlpha(102),
      ),
      child: Text(
        'Upgrade Paket',
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNoPackage(BuildContext context, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Image.asset(
          'assets/images/maskot_kanan.png', // Or another relevant image
          height: 150,
        ),
        const SizedBox(height: 30),
        Text(
          'Anda Belum Memiliki Paket',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Pilih paket untuk mulai menggunakan fitur Joyin.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 40),
        _buildUpgradeButton(context, user),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5FCAAC), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
