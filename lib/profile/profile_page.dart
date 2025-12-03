import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

// IMPORT FILE KAMU
import '../../core/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart'; 
import '../profile/widgets/profile_avatar.dart'; 
import '../profile/edit_profile_page.dart'; 
import '../profile/settings_page.dart'; 
import '../../auth/login_page.dart';

// IMPORT HALAMAN LAIN
import 'about_page.dart'; 
// Pastikan path ini benar. Jika merah, ganti path sesuai lokasi admin_orders_page.dart kamu
import '../../admin/admin_orders_page.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Fungsi Logout
  void _handleLogout(BuildContext context) {
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
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: Text("Keluar", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Memaksa refresh data saat halaman dibuka agar role terbaru terbaca
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).refreshUser();
    });

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // --- LOGIKA DATA USER ---
        final firestoreUser = userProvider.user;
        final authUser = FirebaseAuth.instance.currentUser;

        String displayName = "Pengguna Baru"; 
        String emailDisplay = "Belum ada email";
        String? displayPhoto;

        if (firestoreUser != null) {
          displayName = firestoreUser.name; 
          emailDisplay = firestoreUser.email;
          displayPhoto = firestoreUser.photoUrl;
        } else if (authUser != null) {
          emailDisplay = authUser.email ?? emailDisplay;
          if (authUser.displayName != null && authUser.displayName!.isNotEmpty) {
            displayName = authUser.displayName!;
          } else {
             displayName = emailDisplay.split('@')[0];
          }
          displayPhoto = authUser.photoURL; 
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // HEADER HIJAU
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
                      Text(
                        'Akun Saya',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ProfileAvatar(
                            photoUrl: displayPhoto, 
                            isLoading: false,
                            onEditTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())), 
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  emailDisplay, 
                                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Label Admin (Kecil)
                                if (firestoreUser?.role == 'admin')
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4)
                                    ),
                                    child: Text(
                                      "ADMINISTRATOR",
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // DAFTAR MENU
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        
                        // 🔥 LOGIKA TOMBOL ADMIN (INI YANG PENTING) 🔥
                        if (firestoreUser?.role == 'admin') ...[
                           _buildMenuItem(
                            context, 
                            icon: Icons.admin_panel_settings, // Icon Admin
                            text: 'Dashboard Admin', 
                            // Pastikan import admin_orders_page.dart benar di atas
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersPage())),
                          ),
                          const Divider(height: 1),
                        ],
                        // ------------------------------------------

                        _buildMenuItem(
                          context, 
                          icon: Icons.person_outline, 
                          text: 'Edit Profil', 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()))
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          context, 
                          icon: Icons.settings_outlined, 
                          text: 'Pengaturan', 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(context, icon: Icons.help_outline, text: 'Bantuan', onTap: () {}),
                        const Divider(height: 1),
                        
                        _buildMenuItem(
                          context, 
                          icon: Icons.info_outline, 
                          text: 'Tentang Aplikasi', 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()))
                        ),
                        
                        const Divider(height: 1),
                        _buildMenuItem(
                          context, 
                          icon: Icons.logout, 
                          text: 'Keluar', 
                          isDestructive: true, 
                          onTap: () => _handleLogout(context)
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                Text('Versi 1.0.0', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isDestructive ? Colors.red.withOpacity(0.1) : AppColors.joyin.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: isDestructive ? Colors.red : AppColors.joyin, size: 22),
      ),
      title: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15, color: isDestructive ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}