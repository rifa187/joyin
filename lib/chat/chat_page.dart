import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/widgets/locked_feature_widget.dart';
import 'package:provider/provider.dart';
import '../package/package_theme.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage =
        packageProvider.currentUserPackage != null && packageProvider.currentUserPackage!.isNotEmpty;
    final packageTheme = PackageThemeResolver.resolve(packageProvider.currentUserPackage);

    final double topPadding = MediaQuery.of(context).padding.top;
    const double headerHeight = 200;
    final double contentTop = topPadding + 100;
    final double contentHeight = MediaQuery.of(context).size.height - contentTop;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: packageTheme.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: packageTheme.headerGradient,
                ),
              ),
              padding: EdgeInsets.only(top: topPadding + 16, left: 20, right: 20),
              alignment: Alignment.topCenter,
              child: Text(
                'Obrolan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: contentTop),
              height: contentHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: hasPackage
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Chat Page',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Konten obrolan akan tampil di sini.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: packageTheme.accent,
                                    child: const Icon(Icons.chat, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tidak ada percakapan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Mulai obrolan untuk melihat percakapan pelanggan di sini.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: packageTheme.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 3,
                                  shadowColor: packageTheme.accent.withOpacity(0.4),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'Mulai Obrolan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: LockedFeatureWidget(
                        title: 'Fitur Terkunci',
                        message: 'Upgrade paketmu untuk membuka halaman Obrolan dan fitur terkait.',
                        icon: Icons.chat_bubble_outline,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
