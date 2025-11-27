import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORT CORE
import '../core/app_colors.dart';

// IMPORT TABS (Yang baru kita pisah)
import 'tabs/privacy_tab.dart';
import 'tabs/notification_tab.dart';
import 'tabs/language_tab.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
          onPressed: () => Navigator.pop(context),
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
            Tab(child: Text('Privasi & Keamanan', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500))),
            Tab(child: Text('Notifikasi', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500))),
            Tab(child: Text('Bahasa & Regional', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
      // Body sekarang SANGAT BERSIH, hanya memanggil class Tab
      body: TabBarView(
        controller: _tabController,
        children: const [
          PrivacyTab(),      
          NotificationTab(), 
          LanguageTab(),     
        ],
      ),
    );
  }
}