import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Pastikan import ini sesuai dengan struktur folder Anda
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/providers/user_provider.dart';
import 'package:joyin/screens/pilih_paket_screen.dart';
import '../core/user_model.dart';
import 'package:joyin/package/package_info.dart';

class PackageStatusPage extends StatelessWidget {
  const PackageStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[100], 
      body: Stack(
        children: [
          // === LAYER 1: Header Gradien Hijau ===
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4DB6AC), Color(0xFF81C784)],
              ),
            ),
          ),

          // === LAYER 2: Judul Halaman ===
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: Text(
                "Paket Saya",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false, 
            ),
          ),

          // === LAYER 3: Container Putih ===
          Container(
            margin: const EdgeInsets.only(top: 100),
            height: MediaQuery.of(context).size.height - 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    if (user != null && user.hasPurchasedPackage)
                      _buildPackageDetails(context, user, packageProvider)
                    else
                      _buildNoPackage(context, user),
                      
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET: Tampilan Jika BELUM Punya Paket ===
  Widget _buildNoPackage(BuildContext context, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.sentiment_dissatisfied_rounded,
          size: 100,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 24),
        
        Text(
          'Ups, kamu belum punya paket nih',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        Text(
          'Yuk pilih paket dulu biar bisa lanjut menikmati semua fitur chatbot dan bikin bisnismu makin lancar.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14, 
            color: Colors.grey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        
        _buildUpgradeButton(context, user),
      ],
    );
  }

  // === WIDGET: Tampilan Jika SUDAH Punya Paket ===
  Widget _buildPackageDetails(
    BuildContext context,
    User user,
    PackageProvider packageProvider,
  ) {
    // FIX: Cek jika kosong, return widget kosong agar tidak error
    if (packageProvider.packages.isEmpty) {
      return const SizedBox(); 
    }

    // Ambil paket user atau fallback ke paket pertama
    final selectedPackageInfo = packageProvider.packages.firstWhere(
      (pkg) => pkg.name == packageProvider.currentUserPackage,
      orElse: () => packageProvider.packages.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
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
      colors: [Color(0xFFFFF304), Color(0xFFF09EF1)], 
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final packageGradient = const LinearGradient(
      colors: [Color(0xFF63D1BE), Color(0xFF88E285)], 
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: const EdgeInsets.all(2.5), 
      decoration: BoxDecoration(
        gradient: outlineGradient,
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF09EF1).withOpacity(0.5),
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
                    'Paket ${currentPackage ?? 'Tidak Ada'}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (user.packageDurationMonths != null && user.packageDurationMonths! > 0)
                    Text(
                      'Durasi: ${user.packageDurationMonths} Bulan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Status: Aktif',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
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
                    const SizedBox(height: 10),
                    if (user.packageDurationMonths != null && user.packageDurationMonths! > 0)
                      Text(
                        '* Paket aktif selama ${user.packageDurationMonths} bulan.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context, User? user) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (user != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PilihPaketScreen()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4DB6AC), 
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
          shadowColor: const Color(0xFF4DB6AC).withOpacity(0.4),
        ),
        child: Text(
          'Upgrade Paket',
          style: GoogleFonts.poppins(
            fontSize: 16, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4DB6AC), size: 24),
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