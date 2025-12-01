import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/user_model.dart';
import '../auth/login_page.dart';
import 'package:joyin/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:joyin/providers/dashboard_provider.dart'; // Import DashboardProvider

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

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context); // Get DashboardProvider here

    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildDrawerHeader(),
            _buildProfileSection(context, user),
            const SizedBox(height: 20),
            _buildDrawerItem(
              context: context, // Pass context
              dashboardProvider: dashboardProvider, // Pass dashboardProvider
              icon: Icons.home_outlined,
              text: AppLocalizations.of(context)!.home,
              index: 0,
              onTap: () => onItemTap(0),
            ),
            _buildDrawerItem(
              context: context, // Pass context
              dashboardProvider: dashboardProvider, // Pass dashboardProvider
              icon: Icons.chat_outlined,
              text: AppLocalizations.of(context)!.chat,
              index: 1,
              onTap: () => onItemTap(1),
            ),
            _buildDrawerItem(
              context: context, // Pass context
              dashboardProvider: dashboardProvider, // Pass dashboardProvider
              icon: Icons.article_outlined,
              text: AppLocalizations.of(context)!.report,
              index: 2,
              onTap: () => onItemTap(2),
            ),
            _buildDrawerItem(
              context: context, // Pass context
              dashboardProvider: dashboardProvider, // Pass dashboardProvider
              icon: Icons.smart_toy_outlined,
              text: AppLocalizations.of(context)!.botSettings,
              index: 3,
              onTap: () => onItemTap(3),
            ),
            _buildDrawerItem(
              context: context, // Pass context
              dashboardProvider: dashboardProvider, // Pass dashboardProvider
              icon: Icons.person_outline,
              text: AppLocalizations.of(context)!.profile,
              index: 5,
              onTap: () => onItemTap(5),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(color: Colors.grey[300]),
            ),
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
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.no,
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
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
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
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
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            (user?.displayName?.contains('@') ?? false
                    ? user?.displayName?.split('@').first
                    : user?.displayName) ??
                AppLocalizations.of(context)!.joyinUser,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'email@example.com',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
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
    required BuildContext context, // Add context
    required DashboardProvider dashboardProvider, // Add dashboardProvider
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
        onTap: onTap,
      ),
    );
  }
}
