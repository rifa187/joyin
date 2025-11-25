import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// IMPORT FILE KAMU
import '../core/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart'; // Untuk Logout (opsional)
import 'widgets/profile_avatar.dart'; // Widget Avatar Canggih
import 'edit_profile_page.dart';
import 'settings_page.dart';
import '../auth/login_page.dart'; // Untuk navigasi setelah logout

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Fungsi Logout (Tambahan)
  void _handleLogout(BuildContext context) {
    // Disini bisa panggil authProvider.logout() jika sudah ada
    // Untuk sementara kita pakai navigasi manual ke Login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer agar halaman selalu update saat data berubah
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER (GRADIENT) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF63D1BE), Color(0xFFD6F28F)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Halaman
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
                          // Ikon Logout (Opsional)
                          IconButton(
                            onPressed: () => _handleLogout(context),
                            icon: const Icon(Icons.logout, color: Colors.white),
                            tooltip: 'Keluar',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Info User (Foto & Nama)
                      Row(
                        children: [
                          // FOTO PROFIL (Base64 Ready)
                          ProfileAvatar(
                            photoUrl: user?.photoUrl,
                            isLoading: false, // Tidak ada loading di sini
                            onEditTap: () {
                              // Shortcut ke Edit Profil
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EditProfilePage()),
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
                                    color: Colors.white.withOpacity(0.9),
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

                const SizedBox(height: 20),

                // --- MENU LIST ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context, 
                          icon: Icons.person_outline, 
                          text: 'Edit Profil',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          context, 
                          icon: Icons.settings_outlined, 
                          text: 'Pengaturan',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          context, 
                          icon: Icons.help_outline, 
                          text: 'Bantuan',
                          onTap: () {
                            // Navigasi ke Bantuan (jika ada)
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          context, 
                          icon: Icons.info_outline, 
                          text: 'Tentang Aplikasi',
                          onTap: () {
                            // Navigasi ke Tentang (jika ada)
                          },
                        ),
                      ],
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

  // Helper Widget untuk Menu Item
  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.joyin.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.joyin, size: 22),
      ),
      title: Text(
        text, 
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Colors.black87
        )
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}