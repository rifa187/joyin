import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:joyin/profile/settings_page.dart';
import 'package:joyin/providers/dashboard_provider.dart';
import 'package:joyin/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../core/user_model.dart';
import '../package/package_status_page.dart';
import '../profile/edit_profile_page.dart';
import '../profile/about_page.dart';
import '../widgets/app_drawer.dart';
import '../chat/chat_page.dart'; // Import ChatPage

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<_MonthlyStat> _monthlyStats = const [
    _MonthlyStat('Jan', 1.0),
    _MonthlyStat('Feb', 3.0),
    _MonthlyStat('Mar', 4.0),
    _MonthlyStat('Apr', 3.0),
    _MonthlyStat('May', 2.0),
    _MonthlyStat('Jun', 5.0),
    _MonthlyStat('Jul', 4.0),
    _MonthlyStat('Aug', 2.0),
    _MonthlyStat('Sep', 1.0),
    _MonthlyStat('Oct', 3.0),
    _MonthlyStat('Nov', 2.0),
    _MonthlyStat('Dec', 5.0),
  ];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<int> _chartYears;
  late int _selectedChartYear;

  final List<_PieChartData> _pieChartData = const [
    _PieChartData('Dikirim', 40, Color(0xFF52C7A0)),
    _PieChartData('Dibaca', 30, Color(0xFFFFC857)),
    _PieChartData('Gagal', 15, Color(0xFFE96479)),
    _PieChartData('Terkirim', 15, Color(0xFF4A90E2)),
  ];

  // EDIT HERE: Initial values for mascot adjustment
  double _mascotHeight = 200; // Controls the size of the mascot
  double _mascotOffsetX = -50; // Controls the horizontal position of the mascot
  double _mascotOffsetY = 130; // Controls the vertical position of the mascot

  @override
  void initState() {
    super.initState();
    _chartYears = List<int>.generate(4, (index) => DateTime.now().year - index);
    _selectedChartYear = _chartYears.first;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final user = context.watch<UserProvider>().user;
    final selectedIndex = dashboardProvider.selectedIndex;

    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: selectedIndex == 0 || selectedIndex == 5, // Adjusted index for Profile
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
              ),
            )
          : selectedIndex == 5 // Adjusted index for Profile
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
            )
          : AppBar(
              title: Text(
                _getPageTitle(selectedIndex),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
      drawer: user == null
          ? null
          : AppDrawer(
              user: user,
              onEditProfile: () => _navigateToEditProfile(context, user),
              onItemTap: (index) {
                Navigator.of(context).pop(); // Close the drawer
                dashboardProvider.setSelectedIndex(index);
              },
            ),
      body: _buildBody(context, user, selectedIndex),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        dashboardProvider,
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Beranda';
      case 1:
        return 'Obrolan'; // New Chat page
      case 2:
        return 'Laporan';
      case 3:
        return 'Pengaturan bot';
      case 4:
        return 'Paket Saya';
      case 5:
        return 'Profil Saya';
      default:
        return '';
    }
  }

  Widget _buildBody(BuildContext context, User? user, int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return _buildHomeContent(context, user);
      case 1:
        return const ChatPage(); // New Chat page
      case 2:
        return _buildLaporanPage();
      case 3:
        return _buildPengaturanBotPage();
      case 4:
        return const PackageStatusPage();
      case 5:
        return _buildProfilePage(context, user);
      default:
        return Center(child: Text(_getPageTitle(selectedIndex)));
    }
  }

  void _navigateToEditProfile(BuildContext context, User user) {
    Navigator.of(context).pop();
    _navigateToEditProfilePage(context, user);
  }

  Future<void> _navigateToEditProfilePage(
    BuildContext context,
    User user,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final updatedUser = await Navigator.of(context).push<User>(
      MaterialPageRoute(builder: (context) => EditProfilePage(user: user)),
    );
    if (!mounted || updatedUser == null) {
      return;
    }
    userProvider.setUser(updatedUser);
  }

  Widget _buildHomeContent(BuildContext context, User? user) {
    final displayName = _resolveDisplayName(user);
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: const Color(0xFFF0F2F5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroBanner(displayName, topPadding),
            Transform.translate(
              offset: const Offset(0, -80),
              child: _buildHomeOverviewCard(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _resolveDisplayName(User? user) {
    final rawName = user?.displayName ?? '';
    if (rawName.trim().isEmpty) {
      return 'Enter Your Name';
    }
    return rawName.contains('@') ? rawName.split('@').first : rawName;
  }

  Widget _buildHeroBanner(String displayName, double topPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 52, 24, 132),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF5FCA84),
            Color(0xFFA8DE7B),
            Color(0xFFC7DE7B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      const TextSpan(text: 'Selamat datang, '),
                      TextSpan(
                        text: displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFD447),
                        ),
                      ),
                      const TextSpan(text: '\nJoyin siap nemenin bisnismu.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.bottomRight,
              child: _MascotFadeSlide(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _mascotOffsetX += details.delta.dx;
                      _mascotOffsetY += details.delta.dy;
                    });
                  },
                  child: Transform.translate(
                    offset: Offset(_mascotOffsetX, _mascotOffsetY),
                    child: Image.asset(
                      'assets/images/maskot_kiri.png',
                      height: _mascotHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeOverviewCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Chat Masuk',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 18),
          _buildChatStatRow(),
          const SizedBox(height: 24),
          Text(
            'Statistik Pengiriman Pesan',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF272D3B),
            ),
          ),
          const SizedBox(height: 8),
          _buildMessageLegend(),
          const SizedBox(height: 16),
          _buildChartPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildChatStatRow() {
    final stats = [
      _ChatStatCardData(
        value: '0',
        label: 'Chat Bulanan',
        accent: Color(0xFF63D1BE),
        background: Color(0xFFE9FFF8),
      ),
      _ChatStatCardData(
        value: '0',
        label: 'Chat Bulanan',
        accent: Color(0xFFB79CEF),
        background: Color(0xFFF3ECFF),
      ),
      _ChatStatCardData(
        value: '0',
        label: 'Chat Bulanan',
        accent: Color(0xFFF4B156),
        background: Color(0xFFFFF1DA),
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i != 0) const SizedBox(width: 8),
          Expanded(child: _buildChatStatCard(stats[i])),
        ],
      ],
    );
  }

  Widget _buildChatStatCard(_ChatStatCardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.accent.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: data.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: data.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageLegend() {
    final legendItems = [
      _LegendItem('Dikirim', Color(0xFF52C7A0)),
      _LegendItem('Dibaca', Color(0xFFFFC857)),
      _LegendItem('Gagal', Color(0xFFE96479)),
      _LegendItem('Terkirim', Color(0xFF4A90E2)),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: legendItems.map(_buildLegendChip).toList(),
    );
  }

  Widget _buildLegendChip(_LegendItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF4A4A4A),
          ),
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color accentColor,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageVolumeChart() {
    final stats = _monthlyStats;
    final double maxValue =
        stats.map((stat) => stat.value).reduce((a, b) => a > b ? a : b);
    final double chartTopValue = maxValue == 0 ? 2.0 : (maxValue / 2).ceil() * 2.0;
    final double average =
        stats.fold<double>(0, (sum, stat) => sum + stat.value) / stats.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik Pengiriman Pesan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${average.toStringAsFixed(1)} rata-rata/bulan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF3BB397),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E9E5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedChartYear,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.expand_more, color: Color(0xFF4C5C68)),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF4C5C68),
                    fontWeight: FontWeight.w600,
                  ),
                  items: _chartYears
                      .map(
                        (year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedChartYear = value);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 210,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double labelSpace = 36;
                    final double chartHeight =
                        constraints.maxHeight - labelSpace;
                    final double averageBottom =
                        labelSpace + chartHeight * (average / chartTopValue);

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ChartGridPainter(
                              maxValue: chartTopValue,
                              averageValue: average,
                              labelSpace: labelSpace,
                              horizontalDividers: 3,
                              leftPadding: 30, // Pass the left padding
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: labelSpace, left: 30), // Added left padding
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute space
                            children: stats.map((stat) {
                              final double barHeight =
                                  chartHeight * (stat.value / chartTopValue);
                              return Column( // Removed Expanded
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                    Flexible(
                                      child: FittedBox(
                                        child: Text(
                                          stat.value.toStringAsFixed(0),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF4F4F4F),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: barHeight,
                                      width: 24, // Now this width will be respected
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Color(0xFF8CE0C9), // Lighter green
                                            Color(0xFF63D1BE), // Darker green
                                          ],
                                        ),
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(8)), // Rounded top corners
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      stat.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFF8A97A1),
                                      ),
                                    ),
                                  ],
                                );
                            }).toList(),
                          ),
                        ),
                        Positioned(
                          right: 8, // Give it some space from the right edge
                          bottom: averageBottom - 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text(
                              'Rata-rata',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFF4C5C68),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Data di atas merupakan contoh. Integrasikan dengan API analitik Anda untuk angka aktual.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9AA6B2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageStatusChart() {
    // Calculate the total value for the center text.
    final double totalValue =
        _pieChartData.fold(0, (sum, item) => sum + item.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Pesan',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: _PieChartPainter(data: _pieChartData),
                    child: Center(
                      child: Text(
                        '${totalValue.toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4C5C68),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _pieChartData.map((data) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: _buildLegendChip(_LegendItem(
                        '${data.label} (${data.value.toInt()}%)',
                        data.color,
                      )),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLaporanPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildDateRangeSelector(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildReportSummaryStatistics(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildMessageVolumeChart(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildMessageStatusChart(),
          ),
          const SizedBox(height: 20.0), // Add some bottom padding
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Rentang Tanggal',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
                const Icon(Icons.calendar_today, color: Color(0xFF63D1BE)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportSummaryStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Statistik',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '245',
                'Pesan Masuk',
                const Color(0xFF63D1BE), // accentColor
                const Color(0xFFE9FFF8), // backgroundColor
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '198',
                'Pesan Terjawab',
                const Color(0xFFB79CEF), // accentColor
                const Color(0xFFF3ECFF), // backgroundColor
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPengaturanBotPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGeneralSettings(),
          const SizedBox(height: 24),
          _buildAutoReplySettings(),
          const SizedBox(height: 24),
          _buildBusinessHoursSettings(),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan Umum',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nama Bot',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Pesan Selamat Datang',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aktifkan Bot', style: GoogleFonts.poppins(fontSize: 16)),
                Switch(
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: const Color(0xFF63D1BE),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoReplySettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan Balasan Otomatis',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Pesan balasan saat bot tidak tahu jawabannya',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jeda balasan otomatis (detik)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHoursSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jam Kerja',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktifkan Jam Kerja',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                Switch(
                  value: false,
                  onChanged: (value) {},
                  activeThumbColor: const Color(0xFF63D1BE),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Pesan di luar jam kerja',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context, User? user) {
    return Column(
      children: [
        _buildProfileHeader(context, user),
        Expanded(
          child: Container(
            transform: Matrix4.translationValues(0.0, -30.0, 0.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              child: _buildProfileMenuList(context, user),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    final displayName =
        (user?.displayName?.contains('@') ?? false
            ? user?.displayName?.split('@').first
            : user?.displayName) ??
        'Enter Your Name';
    final email = user?.email ?? 'Enter Email Address';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF63D1BE), Color(0xFFD6F28F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Akun Saya',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: user == null
                  ? null
                  : () => _navigateToEditProfilePage(context, user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF63D1BE),
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Edit Profil',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF63D1BE),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuList(BuildContext context, User? user) {
    return Column(
      children: [
        _buildProfileMenuItem(
          icon: Icons.person_outline,
          text: 'Edit Profil',
          onTap: user == null
              ? null
              : () => _navigateToEditProfilePage(context, user),
        ),
        _buildProfileMenuItem(
          icon: Icons.settings_outlined,
          text: 'Pengaturan',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
        _buildProfileMenuItem(
          icon: Icons.help_outline,
          text: 'Bantuan',
          onTap: () {},
        ),
        _buildProfileMenuItem(
          icon: Icons.info_outline,
          text: 'Tentang',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(),
        ),
        _buildProfileMenuItem(
          icon: Icons.logout,
          text: 'Logout',
          isLogout: true,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Konfirmasi Logout',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'Apakah Anda yakin ingin keluar?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'Tidak',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text(
                        'Ya',
                        style: GoogleFonts.poppins(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        await GoogleSignIn().signOut(); // Sign out from Google
                        await FirebaseAuth.instance.signOut(); // Sign out from Firebase
                        Navigator.of(context).pop();
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
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            children: [
              Icon(icon, color: isLogout ? Colors.redAccent : Colors.black54),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: isLogout ? Colors.redAccent : Colors.black,
                    fontWeight: isLogout ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(
    BuildContext context,
    DashboardProvider dashboardProvider,
  ) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        _buildNavItem(context, Icons.home, 'Beranda', 0),
        _buildNavItem(context, Icons.chat_outlined, 'Obrolan', 1), // New Chat item
        _buildNavItem(context, Icons.article_outlined, 'Laporan', 2),
        _buildNavItem(context, Icons.smart_toy_outlined, 'Pengaturan bot', 3),
        _buildNavItem(context, Icons.inventory_2_outlined, 'Paket Saya', 4),
        _buildNavItem(context, Icons.person_outline, 'Saya', 5),
      ],
      currentIndex: dashboardProvider.selectedIndex,
      onTap: (index) => dashboardProvider.setSelectedIndex(index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: const Color(0xFF63D1BE),
      unselectedItemColor: Colors.grey[600],
    );
  }

  BottomNavigationBarItem _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final selectedIndex = dashboardProvider.selectedIndex;

    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 32,
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? const Color(0xFF63D1BE)
              : Colors.transparent,
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

class _ChartGridPainter extends CustomPainter {
  final double maxValue;
  final double averageValue;
  final double labelSpace; // This is for bottom labels
  final int horizontalDividers;
  final double leftPadding; // New parameter for left padding

  const _ChartGridPainter({
    required this.maxValue,
    required this.averageValue,
    required this.labelSpace,
    this.horizontalDividers = 3,
    this.leftPadding = 0, // Default to 0
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double chartHeight = size.height - labelSpace;
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE6F2EC)
      ..strokeWidth = 1;

    // Draw horizontal grid lines and Y-axis labels
    for (int i = 0; i <= horizontalDividers; i++) {
      final double y = (chartHeight / horizontalDividers) * i;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint); // Start from leftPadding

      // Draw Y-axis labels (0, 2, 4, 6)
      final textSpan = TextSpan(
        text: (maxValue / horizontalDividers * (horizontalDividers - i))
            .toStringAsFixed(0),
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFF8A97A1),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // Position to the left of the chart, with some padding
      textPainter.paint(canvas, Offset(leftPadding - textPainter.width - 8, y - textPainter.height / 2)); // Adjusted position
    }

    final double avgY = chartHeight - (averageValue / maxValue * chartHeight);
    final Paint averagePaint = Paint()
      ..color = const Color(0xFF5AC0AA)
      ..strokeWidth = 1.2;

    double dashX = 0;
    const double dashWidth = 6;
    const double dashSpace = 4;
    while (dashX < size.width) {
      final double endX = (dashX + dashWidth).clamp(0, size.width);
      canvas.drawLine(Offset(dashX, avgY), Offset(endX, avgY), averagePaint);
      dashX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PieChartData {
  final String label;
  final double value;
  final Color color;

  const _PieChartData(this.label, this.value, this.color);
}

class _PieChartPainter extends CustomPainter {
  final List<_PieChartData> data;
  final double strokeWidth;

  _PieChartPainter({required this.data, this.strokeWidth = 24});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;
    double startAngle = -math.pi / 2; // Start from the top

    for (final slice in data) {
      final sweepAngle = (slice.value / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round; // Rounded ends
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.03, // Small gap between slices
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthlyStat {
  final String label;
  final double value;

  const _MonthlyStat(this.label, this.value);
}

class _LegendItem {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);
}

class _ChatStatCardData {
  final String value;
  final String label;
  final Color accent;
  final Color background;
  const _ChatStatCardData({
    required this.value,
    required this.label,
    required this.accent,
    required this.background,
  });
}

class _MascotFadeSlide extends StatefulWidget {
  final Widget child;
  const _MascotFadeSlide({required this.child});
  @override
  State<_MascotFadeSlide> createState() => _MascotFadeSlideState();
}

class _MascotFadeSlideState extends State<_MascotFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: childWrapper()),
    );
  }

  Widget childWrapper() => widget.child;
}
