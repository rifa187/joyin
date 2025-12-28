import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../package/package_detail_page.dart';
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
  int _points = 0;
  int _lifetimePoints = 0;

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
    final tier = _resolveTier(_lifetimePoints);
    final int currentXp = _lifetimePoints;
    final int? nextThreshold = tier.nextThreshold;
    final String? nextTierName = tier.nextTierName;
    final int remainingXp = nextThreshold == null
        ? 0
        : (nextThreshold - currentXp).clamp(0, nextThreshold);
    final double progress = nextThreshold == null || nextThreshold == 0
        ? 1
        : (currentXp / nextThreshold).clamp(0.0, 1.0);

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
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Image.asset(
                        'assets/images/medalicon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.emoji_events,
                          size: 40,
                          color: Color(0xFFF4B740),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier.label,
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
                              '${tier.multiplier}x Bonus',
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
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => JLoyaltyDetailPage(
                              accent: accent,
                              lifetimePoints: _lifetimePoints,
                            ),
                          ),
                        );
                      },
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
                          SizedBox(
                            height: 74,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: 0,
                                  right: 16,
                                  top: 26,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      minHeight: 8,
                                      value: progress,
                                      backgroundColor:
                                          const Color(0xFFE9F4EA),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF8ED57A)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -4,
                                  top: 2,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: Image.asset(
                                          'assets/images/milestonemedalicon.png',
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.emoji_events_outlined,
                                            size: 38,
                                            color: Color(0xFF5BA3E6),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 4,
                                        child: Text(
                                          nextThreshold?.toString() ?? 'MAX',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            nextTierName == null
                                ? 'Anda sudah di tier tertinggi.'
                                : '$remainingXp XP lagi untuk ${nextTierName}!',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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
        packageName: 'Basic',
        title: 'Paket Basic',
        price: 'Rp. 49.000,-',
        duration: 'Durasi 1 bulan',
        redeemCost: 25,
        cashback: 4,
      ),
      _PackageCardData(
        packageName: 'Pro',
        title: 'Paket Pro',
        price: 'Rp. 99.000,-',
        duration: 'Durasi 1 bulan',
        redeemCost: 65,
        cashback: 9,
      ),
      _PackageCardData(
        packageName: 'Bisnis',
        title: 'Paket Bisnis',
        price: 'Rp. 199.000,-',
        duration: 'Durasi 1 bulan',
        redeemCost: 125,
        cashback: 19,
      ),
      _PackageCardData(
        packageName: 'Enterprise',
        title: 'Paket Enterprise',
        price: 'Rp. 499.000,-',
        duration: 'Durasi 1 bulan',
        redeemCost: 200,
        cashback: 49,
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
                  '+${data.redeemCost}',
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
          const SizedBox(height: 6),
          Text(
            'Cashback +${data.cashback} poin',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accent,
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
                          'Tukar bintang butuh ${data.redeemCost} poin. Fitur segera hadir.',
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
                final packageProvider =
                    Provider.of<PackageProvider>(context, listen: false);
                final detailPackage = packageProvider.packages.firstWhere(
                  (p) => p.name.toLowerCase() ==
                      data.packageName.toLowerCase(),
                  orElse: () => packageProvider.packages.first,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PackageDetailPage(
                      packageInfo: detailPackage,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                minimumSize: const Size(88, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lihat Detail',
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
  final String packageName;
  final String title;
  final String price;
  final String duration;
  final int redeemCost;
  final int cashback;

  const _PackageCardData({
    required this.packageName,
    required this.title,
    required this.price,
    required this.duration,
    required this.redeemCost,
    required this.cashback,
  });
}

class _TierInfo {
  final String label;
  final int multiplier;
  final int minXp;
  final int? maxXp;
  final Color color;

  const _TierInfo({
    required this.label,
    required this.multiplier,
    required this.minXp,
    this.maxXp,
    required this.color,
  });

  int? get nextThreshold => maxXp == null ? null : maxXp! + 1;

  String? get nextTierName {
    if (label == 'Newbie') return 'Expert';
    if (label == 'Expert') return 'Master';
    if (label == 'Master') return 'Legend';
    return null;
  }
}

_TierInfo _resolveTier(int lifetimePoints) {
  if (lifetimePoints >= 200) {
    return const _TierInfo(
      label: 'Legend',
      multiplier: 4,
      minXp: 200,
      maxXp: null,
      color: Color(0xFFB0E57C),
    );
  }
  if (lifetimePoints >= 100) {
    return const _TierInfo(
      label: 'Master',
      multiplier: 3,
      minXp: 100,
      maxXp: 199,
      color: Color(0xFF9DD977),
    );
  }
  if (lifetimePoints >= 50) {
    return const _TierInfo(
      label: 'Expert',
      multiplier: 2,
      minXp: 50,
      maxXp: 99,
      color: Color(0xFF8ED57A),
    );
  }
  return const _TierInfo(
    label: 'Newbie',
    multiplier: 1,
    minXp: 0,
    maxXp: 49,
    color: Color(0xFF7ACC77),
  );
}

class JLoyaltyDetailPage extends StatelessWidget {
  final Color accent;
  final int lifetimePoints;

  const JLoyaltyDetailPage({
    super.key,
    required this.accent,
    required this.lifetimePoints,
  });

  static const List<_TierInfo> _tiers = [
    _TierInfo(
      label: 'Newbie',
      multiplier: 1,
      minXp: 0,
      maxXp: 49,
      color: Color(0xFF85D18A),
    ),
    _TierInfo(
      label: 'Expert',
      multiplier: 2,
      minXp: 50,
      maxXp: 99,
      color: Color(0xFF7ED68F),
    ),
    _TierInfo(
      label: 'Master',
      multiplier: 3,
      minXp: 100,
      maxXp: 199,
      color: Color(0xFF9DDD7F),
    ),
    _TierInfo(
      label: 'Legend',
      multiplier: 4,
      minXp: 200,
      maxXp: null,
      color: Color(0xFFB9E88A),
    ),
  ];

  static const Map<String, int> _baseRewards = {
    'Basic': 4,
    'Pro': 9,
    'Bisnis': 19,
    'Enterprise': 49,
  };

  @override
  Widget build(BuildContext context) {
    final currentTier = _resolveTier(lifetimePoints);
    final int? nextThreshold = currentTier.nextThreshold;
    final String? nextTier = currentTier.nextTierName;
    final int remaining = nextThreshold == null
        ? 0
        : (nextThreshold - lifetimePoints).clamp(0, nextThreshold);
    final double progress = nextThreshold == null || nextThreshold == 0
        ? 1
        : (lifetimePoints / nextThreshold).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Sistem Tier & Multiplier',
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
                  colors: [accent.withValues(alpha: 0.9), const Color(0xFFBEEA86)],
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
                  _buildProgressCard(
                    currentTier: currentTier,
                    progress: progress,
                    remaining: remaining,
                    nextTier: nextTier,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  ..._tiers.map((tier) => _buildTierCard(tier)).toList(),
                  const SizedBox(height: 18),
                  _buildComparisonTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required _TierInfo currentTier,
    required double progress,
    required int remaining,
    required String? nextTier,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: currentTier.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.emoji_events, color: currentTier.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTier.label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: currentTier.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${currentTier.multiplier}x Bonus',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: currentTier.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Progress ke tier berikutnya',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
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
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor: AlwaysStoppedAnimation<Color>(currentTier.color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextTier == null
                ? 'Anda sudah di tier tertinggi.'
                : '$remaining XP lagi untuk $nextTier.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE4A3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF0B33F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Semakin tinggi Lifetime XP, semakin besar multiplier poin. '
              'Poin didapat dari transaksi paket dan referral.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.4,
                color: const Color(0xFF8D6A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(_TierInfo tier) {
    final rewards = _baseRewards.entries.map((entry) {
      final value = entry.value * tier.multiplier;
      return _RewardChip(label: entry.key, value: value);
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tier.color.withValues(alpha: 0.35)),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: tier.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tier.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tier.color,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${tier.multiplier}x',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: tier.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Reward per transaksi',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: rewards,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final columns =
        _tiers.map((tier) => DataColumn(label: Text(tier.label))).toList();
    final rows = _baseRewards.entries.map((entry) {
      final values = _tiers
          .map((tier) => DataCell(Text('+${entry.value * tier.multiplier}')))
          .toList();
      return DataRow(
        cells: [
          DataCell(Text(entry.key)),
          ...values,
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Perbandingan Benefit Antar Tier',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Paket')),
                ...columns,
              ],
              rows: rows,
              headingRowHeight: 32,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 36,
              headingTextStyle: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              dataTextStyle: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              columnSpacing: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final String label;
  final int value;

  const _RewardChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7EFD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+$value',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5DAE6F),
            ),
          ),
        ],
      ),
    );
  }
}

