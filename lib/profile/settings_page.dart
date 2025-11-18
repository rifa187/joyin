import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/core/app_colors.dart';
import 'package:joyin/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:joyin/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _notificationFrequency = 'Real-time';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pengaturan',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.joyin,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.joyin,
          tabs: [
            Tab(
              child: Text(
                'Privasi & Keamanan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Notifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Bahasa & Regional',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrivacySecurityTab(),
          _buildNotificationsTab(),
          _buildLanguageRegionTab(),
        ],
      ),
    );
  }

  Widget _buildPrivacySecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildSettingsItem(
                title: 'Nomor yang Diblokir',
                subtitle: 'Kelola daftar nomor yang anda blokir',
                trailing: TextButton(
                  onPressed: () {
                    // Handle "Lihat Daftar" action
                  },
                  child: Text(
                    'Lihat Daftar',
                    style: GoogleFonts.poppins(
                      color: AppColors.joyin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Divider(height: 20, thickness: 1),
              _buildSettingsItem(
                title: 'Izin Data',
                subtitle: 'Izinkan Chatbot menyimpan riwayat chat',
                trailing: Switch(
                  value: true, // Replace with actual state
                  onChanged: (value) {
                    // Handle switch toggle
                  },
                  activeThumbColor: AppColors.joyin,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              _buildSettingsItem(
                title: 'Sesi Aktif',
                subtitle: 'Lihat dan kelola perangkat yang sedang login',
                trailing: TextButton(
                  onPressed: () {
                    // Handle "Lihat Daftar" action
                  },
                  child: Text(
                    'Lihat Daftar',
                    style: GoogleFonts.poppins(
                      color: AppColors.joyin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Divider(height: 20, thickness: 1),
              _buildSettingsItem(
                title: 'Ubah Kata Sandi',
                subtitle:
                    'Untuk alasan keamanan, Anda dapat mengubah kata sandi akun Anda, terutama jika Anda melupakannya.',
                trailing: ElevatedButton(
                  onPressed: () {
                    // Handle "Ubah" action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.joyin,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ubah',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildSettingsItem(
                title: 'Notifikasi Email',
                subtitle: 'Terima notifikasi melalui email',
                trailing: Switch(
                  value: true, // Replace with actual state
                  onChanged: (value) {},
                  activeThumbColor: AppColors.joyin,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              _buildSettingsItem(
                title: 'Push Notifications',
                subtitle:
                    'Terima pemberitahuan langsung dari website, meskipun Anda tidak sedang membukanya',
                trailing: Switch(
                  value: true, // Replace with actual state
                  onChanged: (value) {},
                  activeThumbColor: AppColors.joyin,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              _buildSettingsItem(
                title: 'SMS Notifications',
                subtitle: 'Terima notifikasi penting via SMS',
                trailing: Switch(
                  value: false, // Replace with actual state
                  onChanged: (value) {},
                  activeThumbColor: AppColors.joyin,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              _buildSettingsItem(
                title: 'Frekuensi Notifikasi',
                subtitle: '',
                trailing: DropdownButton<String>(
                  value: _notificationFrequency,
                  onChanged: (String? newValue) {
                    setState(() {
                      _notificationFrequency = newValue!;
                    });
                  },
                  items:
                      <String>[
                        'Real-time',
                        'Sekali sehari',
                        'Sekali seminggu',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageRegionTab() {
    final provider = Provider.of<LocaleProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildSettingsItem(
                title: AppLocalizations.of(context)!.language,
                subtitle: AppLocalizations.of(context)!.chooseLanguage,
                trailing: DropdownButton<Locale>(
                  value: provider.locale,
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      provider.setLocale(newLocale);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: Locale('id'),
                      child: Text('Bahasa Indonesia'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
