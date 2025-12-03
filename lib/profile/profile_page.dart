import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // Hide agar tidak bentrok

// IMPORT FILE KAMU
import '../../core/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart'; 
import '../profile/widgets/profile_avatar.dart'; 
import '../profile/edit_profile_page.dart'; 
import '../profile/settings_page.dart'; 
import '../../auth/login_page.dart'; 

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
              Navigator.pop(context); // Tutup dialog
              
              // Logout Provider
              // PERBAIKAN: Hapus 'await' jika method logout() di AuthProvider bertipe void
              Provider.of<AuthProvider>(context, listen: false).logout();

              // Kembali ke Login Page (Cek mounted agar aman)
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
    // Kita panggil refreshUser sekali saat build untuk memastikan data paling baru
    // (Opsional, tapi bagus agar data selalu sinkron)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).refreshUser();
    });

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // --- LOGIKA MENAMPILKAN DATA USER (PRIORITAS FIRESTORE) ---
        
        // 1. Ambil data dari UserProvider (Data Firestore yang lengkap)
        final firestoreUser = userProvider.user;
        
        // 2. Ambil data dari Firebase Auth (Cadangan/Fallback)
        final authUser = FirebaseAuth.instance.currentUser;

        // Default Values
        String displayName = "Pengguna Baru"; 
        String emailDisplay = "Belum ada email";
        String? displayPhoto;

        // LOGIKA PEMILIHAN DATA:
        // Prioritaskan data dari Firestore (karena ada nama, no hp, dll).
        // Jika Firestore kosong (null), baru ambil dari Auth.

        if (firestoreUser != null) {
          // --- SKENARIO A: DATA FIRESTORE ADA (Sudah Register/OTP Sukses) ---
          displayName = firestoreUser.name; // Mengambil dari field 'name' di user_model.dart
          emailDisplay = firestoreUser.email;
          displayPhoto = firestoreUser.photoUrl;
        } else if (authUser != null) {
          // --- SKENARIO B: DATA FIRESTORE BELUM LOAD (Pakai data Auth sementara) ---
          emailDisplay = authUser.email ?? emailDisplay;
          
          if (authUser.displayName != null && authUser.displayName!.isNotEmpty) {
            displayName = authUser.displayName!;
          } else {
             displayName = emailDisplay.split('@')[0];
          }
          
          // PERBAIKAN: Firebase Auth menggunakan .photoURL (bukan photoUrl)
          displayPhoto = authUser.photoURL; 
        }
        // -------------------------------------

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // HEADER
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
                            // Menggunakan variabel yang sudah dinormalisasi di atas
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
                                  displayName, // DATA NAMA SEKARANG PASTI TAMPIL
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  emailDisplay, 
                                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14),
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

                // MENU LIST
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildMenuItem(context, icon: Icons.person_outline, text: 'Edit Profil', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()))),
                        const Divider(height: 1),
                        _buildMenuItem(context, icon: Icons.settings_outlined, text: 'Pengaturan', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
                        const Divider(height: 1),
                        _buildMenuItem(context, icon: Icons.help_outline, text: 'Bantuan', onTap: () {}),
                        const Divider(height: 1),
                        _buildMenuItem(context, icon: Icons.info_outline, text: 'Tentang Aplikasi', onTap: () {}),
                        const Divider(height: 1),
                        _buildMenuItem(context, icon: Icons.logout, text: 'Keluar', isDestructive: true, onTap: () => _handleLogout(context)),
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