import 'dart:convert'; // Tambahan untuk decode base64 foto
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// IMPORT FILE PROJECT
import '../core/user_model.dart';
import '../auth/login_page.dart';
import '../profile/settings_page.dart';
import 'package:joyin/gen_l10n/app_localizations.dart';

// IMPORT PROVIDERS
import '../providers/dashboard_provider.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider untuk logout

class AppDrawer extends StatelessWidget {
  final User? user;
  final VoidCallback onEditProfile;
  final Function(int) onItemTap;

  const AppDrawer({
    super.key,
    required this.user,
    required this.onEditProfile,
    required this.onItemTap,
  });

  // Helper untuk menampilkan gambar (Base64 atau Network)
  ImageProvider? _getProfileImage(String? photoData) {
    if (photoData == null || photoData.isEmpty) return null;
    try {
      // Jika data berupa Base64 (biasanya panjang dan tidak ada http)
      if (!photoData.startsWith('http')) {
        return MemoryImage(base64Decode(photoData));
      }
      // Jika URL biasa (https://...)
      return NetworkImage(photoData);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildDrawerHeader(),
            _buildProfileSection(context, user),
            const SizedBox(height: 20),
            
            // --- MENU ITEMS ---
            _buildDrawerItem(
              context: context,
              dashboardProvider: dashboardProvider,
              icon: Icons.home_outlined,
              text: AppLocalizations.of(context)!.home,
              index: 0,
              onTap: () => onItemTap(0),
            ),
            _buildDrawerItem(
              context: context,
              dashboardProvider: dashboardProvider,
              icon: Icons.chat_outlined,
              text: AppLocalizations.of(context)!.chat,
              index: 1,
              onTap: () => onItemTap(1),
            ),
            _buildDrawerItem(
              context: context,
              dashboardProvider: dashboardProvider,
              icon: Icons.article_outlined,
              text: AppLocalizations.of(context)!.report,
              index: 2,
              onTap: () => onItemTap(2),
            ),
            _buildDrawerItem(
              context: context,
              dashboardProvider: dashboardProvider,
              icon: Icons.smart_toy_outlined,
              text: AppLocalizations.of(context)!.botSettings,
              index: 3,
              onTap: () => onItemTap(3),
            ),
            _buildDrawerItem(
              context: context,
              dashboardProvider: dashboardProvider,
              icon: Icons.inventory_2_outlined,
              text: AppLocalizations.of(context)!.myPackage,
              index: 4,
              onTap: () => onItemTap(4),
            ),
            _buildDrawerItem(
              context: context,
              dashboardProvider: dashboardProvider,
              icon: Icons.person_outline,
              text: AppLocalizations.of(context)!.profile,
              index: 5,
              onTap: () => onItemTap(5),
            ),
            
            // SETTINGS (Navigasi Push)
            _buildDrawerItem(
              context: context,
              dashboardProvider: dashboardProvider,
              icon: Icons.settings_outlined,
              text: AppLocalizations.of(context)!.settings,
              index: 6,
              onTap: () {
                Navigator.of(context).pop(); // Tutup drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(color: Colors.grey[300]),
            ),
            
            // --- LOGOUT ---
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(
                AppLocalizations.of(context)!.logout,
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        AppLocalizations.of(context)!.confirmLogout,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.areYouSureYouWantToLogout,
                        style: GoogleFonts.poppins(),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.no,
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); 
                          },
                        ),
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.yes,
                            style: GoogleFonts.poppins(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(); // Tutup Dialog
                            
                            // 1. Panggil Logout dari AuthProvider (PENTING)
                            await Provider.of<AuthProvider>(context, listen: false).logout();

                            // 2. Kembali ke Halaman Login
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Center(
        child: Image.asset('assets/images/logo_joyin.png', height: 40),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, User? user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF63D1BE), width: 1.5),
      ),
      child: Column(
        children: [
          // TAMPILKAN FOTO PROFIL
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: _getProfileImage(user?.photoUrl),
            child: (user?.photoUrl == null)
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          
          // TAMPILKAN NAMA (FIXED: displayName -> name)
          Text(
            user?.name ?? AppLocalizations.of(context)!.joyinUser,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'email@example.com',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          ElevatedButton(
            onPressed: onEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF63D1BE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30),
            ),
            child: Text(
              AppLocalizations.of(context)!.editProfile,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context, 
    required DashboardProvider dashboardProvider, 
    required IconData icon,
    required String text,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = dashboardProvider.selectedIndex == index;
    final color = isSelected ? Colors.white : Colors.black87;
    final bgColor = isSelected ? const Color(0xFF63D1BE) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          text,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: color),
        ),
        onTap: () {
          Navigator.of(context).pop(); // Tutup drawer saat item dipilih
          onTap();
        },
      ),
    );
  }
}