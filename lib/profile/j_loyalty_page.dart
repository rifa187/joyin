import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../package/package_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/package_provider.dart';
import '../screens/pilih_paket_screen.dart';
import '../services/referral_api_service.dart';

class JLoyaltyPage extends StatefulWidget {
  const JLoyaltyPage({super.key});

  @override
  State<JLoyaltyPage> createState() => _JLoyaltyPageState();
}

class _JLoyaltyPageState extends State<JLoyaltyPage>
    with TickerProviderStateMixin {
  final ReferralApiService _referralApi = ReferralApiService();
  late final AnimationController _heroController;
  late final AnimationController _packageController;
  String? _lastAccessToken;
  bool _isLoading = false;
  String? _error;
  int _points = 60;
  int _lifetimePoints = 60;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _packageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.accessToken;
      if (token != null && token.isNotEmpty) {
        _fetchPoints(token);
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _packageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final packageTheme =
        PackageThemeResolver.resolve(packageProvider.currentUserPackage);
    final accent = packageTheme.accent;
    final accessToken = context.watch<AuthProvider>().accessToken;
    if (accessToken != null &&
        accessToken.isNotEmpty &&
        _lastAccessToken != accessToken) {
      _lastAccessToken = accessToken;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchPoints(accessToken);
      });
    }

    final heroFade = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOut,
    );
    final heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    ));
    final packageFade = CurvedAnimation(
      parent: _packageController,
      curve: Curves.easeOut,
    );
    final packageSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _packageController,
      curve: Curves.easeOutCubic,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'J-Loyalty Rewards Center',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: packageTheme.headerGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: heroFade,
                    child: SlideTransition(
                      position: heroSlide,
                      child: _buildHeroCard(accent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: packageFade,
                    child: SlideTransition(
                      position: packageSlide,
                      child: _buildPackagesSection(accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildFloatingStars(),
          if (_isLoading)
            Positioned(
              right: 20,
              top: 72,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Memuat...',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_error != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Color accent) {
    final int targetXp = 100;
    final int currentXp = _lifetimePoints;
    final int remainingXp = (targetXp - currentXp).clamp(0, targetXp);
    final double progress =
        targetXp == 0 ? 0 : (currentXp / targetXp).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dompet Bintang Anda',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome, color: accent),
              ),
              const SizedBox(width: 10),
              Text(
                _points.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'bintang',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6A8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events,
                          color: Color(0xFFF4B740)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expert',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1C8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '2x Bonus',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB67200),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: BorderSide(color: accent.withValues(alpha: 0.6)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        'Lihat Detail',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lifetime XP: $currentXp',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: progress,
                              backgroundColor:
                                  const Color(0xFFE8E8E8),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF8ED57A)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$remainingXp XP lagi untuk Master!',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F5FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events_outlined,
                          color: Color(0xFF5BA3E6)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '50',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesSection(Color accent) {
    final cards = [
      _PackageCardData(
        title: 'Paket Basic',
        price: 'Rp. 49.000,-',
        duration: 'Durasi 1 bulan',
        bonus: '+25',
      ),
      _PackageCardData(
        title: 'Paket Pro',
        price: 'Rp. 99.000,-',
        duration: 'Durasi 1 bulan',
        bonus: '+65',
      ),
      _PackageCardData(
        title: 'Paket Bisnis',
        price: 'Rp. 199.000,-',
        duration: 'Durasi 1 bulan',
        bonus: '+125',
      ),
      _PackageCardData(
        title: 'Paket Enterprise',
        price: 'Rp. 499.000,-',
        duration: 'Durasi 1 bulan',
        bonus: '+200',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Paket Langganan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dapatkan bintang dari setiap transaksi dan referral. '
            'Gunakan untuk menukar paket langganan.',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Column(
            children: cards
                .map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPackageCard(card, accent),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(_PackageCardData data, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data.bonus,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.price,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.duration,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PilihPaketScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Beli Paket',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Fitur tukar bintang segera hadir.',
                          style: GoogleFonts.poppins(),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: accent.withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Tukar Bintang',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Detail paket segera tersedia.',
                      style: GoogleFonts.poppins(),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lihat Detail →',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingStars() {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned(
            top: 70,
            left: 22,
            child: Icon(Icons.star, color: Color(0xFFFFF2B3), size: 18),
          ),
          Positioned(
            top: 110,
            right: 40,
            child: Icon(Icons.star, color: Color(0xFFFFF2B3), size: 14),
          ),
          Positioned(
            top: 160,
            right: 80,
            child: Icon(Icons.star, color: Color(0xFFFFF2B3), size: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchPoints(String accessToken) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _referralApi.getMyReferralDetails(accessToken);
      final payload = response['data'];
      if (payload is Map<String, dynamic>) {
        final points = payload['pointBalance'];
        final lifetime = payload['lifetimePoints'];
        setState(() {
          _points = (points is num) ? points.round() : _points;
          _lifetimePoints =
              (lifetime is num) ? lifetime.round() : _lifetimePoints;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _PackageCardData {
  final String title;
  final String price;
  final String duration;
  final String bonus;

  const _PackageCardData({
    required this.title,
    required this.price,
    required this.duration,
    required this.bonus,
  });
}
