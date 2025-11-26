import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// PROVIDERS & COMPONENTS
import 'package:joyin/providers/dashboard_provider.dart';
import 'package:joyin/providers/user_provider.dart';
import '../core/app_colors.dart';
import '../widgets/app_drawer.dart';

// PAGES IMPORT
import 'home_content.dart';
import '../chat/chat_page.dart';
import '../package/package_status_page.dart';
import '../profile/profile_page.dart';
import '../profile/edit_profile_page.dart';
import '../report/report_page.dart';
import '../bot/bot_settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

 // ✅ DAFTAR HALAMAN (VERSI FINAL)
  // Semua halaman sekarang sudah terhubung ke file aslinya
  final List<Widget> _pages = [
    const HomeContent(),        // Index 0: Beranda
    const ChatPage(),           // Index 1: Obrolan
    const ReportPage(),         // Index 2: Laporan
    const BotSettingsPage(),    // Index 3: Pengaturan Bot (UPDATED ✅)
    const PackageStatusPage(),  // Index 4: Paket Saya
    const ProfilePage(),        // Index 5: Profil Saya
  ];

  // Judul Halaman di AppBar
  String _getPageTitle(int index) {
    switch (index) {
      case 0: return 'Beranda';
      case 1: return 'Obrolan';
      case 2: return 'Laporan';
      case 3: return 'Pengaturan Bot';
      case 4: return 'Paket Saya';
      case 5: return 'Profil Saya';
      default: return 'Joyin';
    }
  }

  // Logic Navigasi Edit Profil
  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).pop(); // Tutup Drawer
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final user = context.watch<UserProvider>().user;
    final selectedIndex = dashboardProvider.selectedIndex;

    return Scaffold(
      key: scaffoldKey,
      // Hanya Beranda & Profil yang body-nya sampai atas (di belakang AppBar)
      extendBodyBehindAppBar: selectedIndex == 0 || selectedIndex == 5,
      backgroundColor: const Color(0xFFF0F2F5),
      
      appBar: _buildAppBar(selectedIndex),
      
      drawer: user == null
          ? null
          : AppDrawer(
              user: user,
              onEditProfile: () => _navigateToEditProfile(context),
              onItemTap: (index) {
                Navigator.of(context).pop();
                dashboardProvider.setSelectedIndex(index);
              },
            ),
      
      // Menampilkan Halaman sesuai index
      body: _pages[selectedIndex],
      
      bottomNavigationBar: _buildBottomNavigationBar(context, dashboardProvider),
    );
  }

  // AppBar Logic dipisah biar rapi
  PreferredSizeWidget? _buildAppBar(int index) {
    // Beranda: AppBar Transparan + Menu Icon
    if (index == 0) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      );
    } 
    // Profil: AppBar Transparan + Tanpa Icon Back
    else if (index == 5) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      );
    } 
    // Halaman Lain: AppBar Putih Biasa
    else {
      return AppBar(
        title: Text(
          _getPageTitle(index),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      );
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context, DashboardProvider provider) {
    return BottomNavigationBar(
      items: [
        _buildNavItem(Icons.home_filled, 'Beranda', 0, provider.selectedIndex),
        _buildNavItem(Icons.chat_bubble_outline, 'Obrolan', 1, provider.selectedIndex),
        _buildNavItem(Icons.article_outlined, 'Laporan', 2, provider.selectedIndex),
        _buildNavItem(Icons.smart_toy_outlined, 'Bot', 3, provider.selectedIndex),
        _buildNavItem(Icons.inventory_2_outlined, 'Paket', 4, provider.selectedIndex),
        _buildNavItem(Icons.person_outline, 'Saya', 5, provider.selectedIndex),
      ],
      currentIndex: provider.selectedIndex,
      onTap: (index) => provider.setSelectedIndex(index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: AppColors.joyin, // Pastikan ada di AppColors
      unselectedItemColor: Colors.grey[600],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index, int selectedIndex) {
    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48, height: 32,
        decoration: BoxDecoration(
          color: selectedIndex == index ? AppColors.joyin : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: selectedIndex == index ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }
}