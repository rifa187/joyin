import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// IMPORT FILE KAMU
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/providers/dashboard_provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import 'widgets/profile_avatar.dart'; // Widget Avatar Canggih
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'referral_page.dart';
import '../tutorial/tutorial_page.dart';
import '../auth/login_page.dart'; // Untuk navigasi setelah logout
import '../screens/pilih_paket_screen.dart';
import 'about_page.dart';
import '../package/package_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<Offset> _headerSlide;
  late final AnimationController _gradientController;
  late final AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutCubic,
      ),
    );
    _headerController.forward();

    _gradientController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _gradientController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Fungsi Logout (Tambahan - Bisa diaktifkan nanti)
  void _handleLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Konfirmasi Keluar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah kamu yakin ingin keluar dari akun?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child:
                  Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Text(
                'Keluar',
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer agar halaman selalu update saat data berubah
    return Consumer2<AuthProvider, PackageProvider>(
      builder: (context, authProvider, packageProvider, _) {
        final user = authProvider.user;
        final String? packageName = packageProvider.currentUserPackage;
        final PackageTheme packageTheme =
            PackageThemeResolver.resolve(packageName);
        final bool hasPackage = packageName != null && packageName.isNotEmpty;
        final bool animateGradient =
            packageTheme.headerGradient.toSet().length > 1;
        final Animation<double> subscriptionFade = CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
        );
        final Animation<Offset> subscriptionSlide = Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
          ),
        );

        final Animation<double> quickFade = CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
        );
        final Animation<Offset> quickSlide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
          ),
        );

        final Animation<double> menuFade = CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.4, 0.95, curve: Curves.easeOut),
        );
        final Animation<Offset> menuSlide = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.4, 0.95, curve: Curves.easeOutCubic),
          ),
        );

        if (animateGradient && !_gradientController.isAnimating) {
          _gradientController.repeat(reverse: true);
        } else if (!animateGradient && _gradientController.isAnimating) {
          _gradientController.stop();
        }

        return Scaffold(
          backgroundColor: packageTheme.backgroundGradient.first,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER (GRADIENT) ---
                SlideTransition(
                  position: _headerSlide,
                  child: AnimatedBuilder(
                    animation: _gradientController,
                    builder: (context, child) {
                      final double shift = animateGradient
                          ? lerpDouble(-0.6, 0.6, _gradientController.value) ??
                              0
                          : 0;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: packageTheme.headerGradient,
                            begin: Alignment(-1 + shift, 0),
                            end: Alignment(1 + shift, 0),
                          ),
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(30)),
                        ),
                        child: child,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul Halaman & Logout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Akun Saya',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Ikon Logout
                            Material(
                              color: Colors.white.withOpacity(0.12),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _handleLogout(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child:
                                      Icon(Icons.logout, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Info User (Foto & Nama)
                        Row(
                          children: [
                            // FOTO PROFIL (Base64 Ready)
                            // Menggunakan Widget ProfileAvatar yang sudah kita buat
                            ProfileAvatar(
                              photoUrl: user?.photoUrl,
                              isLoading:
                                  false, // Tidak ada loading upload di sini
                              onEditTap: () {
                                // Shortcut ke Edit Profil saat foto diklik
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const EditProfilePage()),
                                );
                              },
                            ),

                            const SizedBox(width: 16),

                            // Teks Nama & Email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.displayName ?? 'Nama Pengguna',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user?.email ?? 'email@contoh.com',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white
                                          .withAlpha((255 * 0.9).round()),
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- Subscription Status Card ---
                FadeTransition(
                  opacity: subscriptionFade,
                  child: SlideTransition(
                    position: subscriptionSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        shadowColor: packageTheme.accent.withOpacity(0.12),
                        child: hasPackage
                            ? _buildSubscriptionInfo(
                                context, packageProvider.currentUserPackage!)
                            : _buildNoSubscription(context),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- Quick Actions ---
                FadeTransition(
                  opacity: quickFade,
                  child: SlideTransition(
                    position: quickSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildQuickActions(context, packageTheme),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- MENU LIST ---
                FadeTransition(
                  opacity: menuFade,
                  child: SlideTransition(
                    position: menuSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            _buildAnimatedMenuItem(
                              context,
                              index: 0,
                              icon: Icons.card_giftcard_outlined,
                              text: 'Kode Referral',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ReferralPage()),
                              ),
                              accent: packageTheme.accent,
                            ),
                            const Divider(height: 1),
                            _buildAnimatedMenuItem(
                              context,
                              index: 1,
                              icon: Icons.person_outline,
                              text: 'Edit Profil',
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const EditProfilePage())),
                              accent: packageTheme.accent,
                            ),
                            const Divider(height: 1),
                            _buildAnimatedMenuItem(
                              context,
                              index: 2,
                              icon: Icons.settings_outlined,
                              text: 'Pengaturan',
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SettingsPage())),
                              accent: packageTheme.accent,
                            ),
                            const Divider(height: 1),
                            _buildAnimatedMenuItem(
                              context,
                              index: 3,
                              icon: Icons.help_outline,
                              text: 'Bantuan',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TutorialPage()),
                              ),
                              accent: packageTheme.accent,
                            ),
                            const Divider(height: 1),
                            _buildAnimatedMenuItem(
                              context,
                              index: 4,
                              icon: Icons.info_outline,
                              text: 'Tentang Aplikasi',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AboutPage()),
                              ),
                              accent: packageTheme.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Versi Aplikasi
                Text(
                  'Versi 1.0.0',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionInfo(BuildContext context, String currentPackage) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.star, color: Colors.amber),
      ),
      title: Text('Paket Aktif: $currentPackage',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      subtitle:
          Text('Lihat detail dan perpanjang', style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Provider.of<DashboardProvider>(context, listen: false)
            .setSelectedIndex(4);
      },
    );
  }

  Widget _buildNoSubscription(BuildContext context) {
    final PackageTheme theme = PackageThemeResolver.resolve(
      Provider.of<PackageProvider>(context, listen: false).currentUserPackage,
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star_border, color: theme.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belum Berlangganan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aktifkan paket untuk buka fitur laporan, bot, dan obrolan tanpa batas.',
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PilihPaketScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Lihat Paket',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk Menu Item
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: accent, size: 22),
      ),
      title: Text(text,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildAnimatedMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color accent,
  }) {
    final double start = 0.45 + (index * 0.06);
    final double end = (start + 0.35).clamp(0, 1);
    final Animation<double> fade = CurvedAnimation(
      parent: _contentController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: _buildMenuItem(
          context,
          icon: icon,
          text: text,
          onTap: onTap,
          accent: accent,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, PackageTheme theme) {
    final navigator = Navigator.of(context);
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.person_outline,
            label: 'Edit Profil',
            accent: theme.accent,
            onTap: () {
              navigator.push(
                  MaterialPageRoute(builder: (_) => const EditProfilePage()));
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.card_giftcard_outlined,
            label: 'Referral',
            accent: theme.accent,
            onTap: () {
              navigator.push(
                  MaterialPageRoute(builder: (_) => const ReferralPage()));
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.lock_outline,
            label: 'Keamanan',
            accent: theme.accent,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
