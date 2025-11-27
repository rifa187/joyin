import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// IMPORT FILE KAMU
import '../core/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart'; 
import 'widgets/profile_avatar.dart'; 
import 'edit_profile_page.dart';
import 'settings_page.dart';
import '../auth/login_page.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Fungsi Logout
  void _handleLogout(BuildContext context) {
    // Tampilkan Dialog Konfirmasi Dulu (UX yang baik)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Keluar Akun?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Anda harus login kembali untuk mengakses akun ini.", style: GoogleFonts.poppins()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              
              // Lakukan Navigasi ke Login Page dan Hapus Route Sebelumnya
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text("Keluar", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      // Judul Halaman (Tombol Logout DIHAPUS dari sini agar tidak dobel)
                      Text(
                        'Akun Saya',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Info User (Foto & Nama)
                      Row(
                        children: [
                          // FOTO PROFIL
                          ProfileAvatar(
                            photoUrl: user?.photoUrl,
                            isLoading: false,
                            onEditTap: () {
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
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          context, 
                          icon: Icons.info_outline, 
                          text: 'Tentang Aplikasi',
                          onTap: () {},
                        ),
                        
                        // --- TOMBOL KELUAR (Dipindah ke sini) ---
                        const Divider(height: 1),
                        _buildMenuItem(
                          context, 
                          icon: Icons.logout, 
                          text: 'Keluar',
                          isDestructive: true, // Warna Merah
                          onTap: () => _handleLogout(context),
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
  Widget _buildMenuItem(BuildContext context, {
    required IconData icon, 
    required String text, 
    required VoidCallback onTap,
    bool isDestructive = false, // Opsi untuk warna merah (Logout)
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // Jika Destructive (Logout) warnanya merah muda, jika tidak hijau muda
          color: isDestructive 
              ? Colors.red.withOpacity(0.1) 
              : AppColors.joyin.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        // Icon Merah jika logout
        child: Icon(icon, color: isDestructive ? Colors.red : AppColors.joyin, size: 22),
      ),
      title: Text(
        text, 
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          // Teks Merah jika logout
          color: isDestructive ? Colors.red : Colors.black87
        )
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}