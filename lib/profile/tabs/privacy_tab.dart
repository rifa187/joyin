import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORT CORE
import '../../../core/app_colors.dart';

// IMPORT WIDGETS GLOBAL (Settings Item yang kamu buat di lib/widgets)
import '../../../widgets/settings_item.dart'; 

// IMPORT WIDGET LOKAL (Dialog Password yang BARU saja kita buat)
import '../widgets/change_password_dialog.dart'; 

class PrivacyTab extends StatelessWidget {
  const PrivacyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SettingsItem(
                title: 'Nomor yang Diblokir',
                subtitle: 'Kelola daftar nomor yang anda blokir',
                trailing: TextButton(
                  onPressed: () {},
                  child: Text('Lihat Daftar', style: GoogleFonts.poppins(color: AppColors.joyin, fontWeight: FontWeight.w500)),
                ),
              ),
              const Divider(height: 20, thickness: 1),
              SettingsItem(
                title: 'Izin Data',
                subtitle: 'Izinkan Chatbot menyimpan riwayat chat',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: AppColors.joyin,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              SettingsItem(
                title: 'Sesi Aktif',
                subtitle: 'Lihat dan kelola perangkat yang sedang login',
                trailing: TextButton(
                  onPressed: () {},
                  child: Text('Lihat Daftar', style: GoogleFonts.poppins(color: AppColors.joyin, fontWeight: FontWeight.w500)),
                ),
              ),
              const Divider(height: 20, thickness: 1),
              
              // --- BAGIAN TOMBOL UBAH PASSWORD ---
              SettingsItem(
                title: 'Ubah Kata Sandi',
                subtitle: 'Untuk alasan keamanan, Anda dapat mengubah kata sandi akun Anda.',
                trailing: ElevatedButton(
                  onPressed: () {
                    // Panggil Dialog dari file terpisah
                    showDialog(
                      context: context,
                      builder: (context) => const ChangePasswordDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.joyin,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Ubah', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}