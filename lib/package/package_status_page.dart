import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/widgets/locked_feature_widget.dart';
import 'package:provider/provider.dart';
import '../screens/pilih_paket_screen.dart';

class PackageStatusPage extends StatelessWidget {
  const PackageStatusPage({super.key});

  static const Color primaryColor = Color(0xFF4ECDC4);

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage = packageProvider.currentUserPackage != null &&
        packageProvider.currentUserPackage!.isNotEmpty;
    final selectedName = packageProvider.currentUserPackage;
    final selectedDuration =
        selectedName != null ? packageProvider.selectedDurations[selectedName] : null;
    final selectedPackage = selectedName == null
        ? null
        : packageProvider.packages
            .firstWhere((p) => p.name == selectedName, orElse: () => packageProvider.packages.first);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // === LAYER 1: HEADER GRADIENT (SAMA SEPERTI HALAMAN PAKET) ===
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

          // === LAYER 2: APPBAR TRANSPARAN (TITLE "Paket Saya") ===
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

          // === LAYER 3: CONTAINER PUTIH BESAR DENGAN RADIUS ATAS ===
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
              child: hasPackage
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: selectedPackage == null
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  'Paket Aktif',
                                  Icons.inventory_2_outlined,
                                ),
                                const SizedBox(height: 12),
                                _buildActiveCard(
                                  context,
                                  selectedPackage.name,
                                  selectedPackage.price,
                                  selectedDuration,
                                ),
                                const SizedBox(height: 24),
                                _buildSectionTitle(
                                  'Fitur Paket',
                                  Icons.star_border_rounded,
                                ),
                                const SizedBox(height: 12),
                                _buildFeatureList(selectedPackage.features),
                                const SizedBox(height: 24),
                                _buildSectionTitle(
                                  'Kelola Paket',
                                  Icons.manage_accounts_outlined,
                                ),
                                const SizedBox(height: 12),
                                _buildManageButtons(context),
                                const SizedBox(height: 32),
                              ],
                            ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: LockedFeatureWidget(
                        title: 'Paket Terkunci',
                        message:
                            'Upgrade paketmu untuk mengaktifkan fitur paket dan statistik.',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF4DB6AC),
          size: 24,
        ),
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

  Widget _buildActiveCard(
    BuildContext context,
    String packageName,
    String price,
    int? selectedDuration,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4DB6AC), Color(0xFF81C784)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paket $packageName',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${selectedDuration ?? 1} bulan',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Aktif',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Paket aktif dan siap digunakan',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(List<String> features) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Color(0xFF4DB6AC)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check, size: 18, color: Color(0xFF4DB6AC)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
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
          ),
        ],
      ),
    );
  }

  Widget _buildManageButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PilihPaketScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.swap_horiz),
            label: Text(
              'Ubah Paket',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PilihPaketScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.credit_card, color: Colors.white),
            label: Text(
              'Perpanjang',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
