import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_colors.dart';
import '../core/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/package_provider.dart';
import '../package/package_theme.dart';
import '../services/referral_api_service.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  String? _referralCode;
  String? _lastUserId;
  final ReferralApiService _referralApi = ReferralApiService();
  final List<_ReferralEntry> _referralEntries = [];
  bool _isLoadingReferrals = false;
  String? _referralError;
  String? _lastAccessToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      _loadReferralCode(authProvider.user);
      final token = authProvider.accessToken;
      if (token != null && token.isNotEmpty) {
        _fetchReferralDetails(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final accessToken = context.watch<AuthProvider>().accessToken;
    final packageProvider = context.watch<PackageProvider>();
    final packageTheme =
        PackageThemeResolver.resolve(packageProvider.currentUserPackage);
    final accent = packageTheme.accent;
    if (_lastUserId != user?.id) {
      _lastUserId = user?.id;
      _loadReferralCode(user);
    }
    final referralCode = _referralCode ?? _buildReferralCode(user);
    if (accessToken != null &&
        accessToken.isNotEmpty &&
        _lastAccessToken != accessToken) {
      _lastAccessToken = accessToken;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchReferralDetails(accessToken);
      });
    }

    final navColor = packageTheme.headerGradient.last;
    final navIconBrightness =
        navColor.computeLuminance() > 0.6 ? Brightness.dark : Brightness.light;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: navColor,
        systemNavigationBarIconBrightness: navIconBrightness,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          title: const SizedBox.shrink(),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          fit: StackFit.expand,
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _buildHeroSection(referralCode, accent),
                    const SizedBox(height: 18),
                    _buildReferralListCard(accent),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(String referralCode, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Ajak Teman, Dapatkan Komisi',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Ajak temanmu pakai Joyin dan nikmati hadiahnya bareng-bareng. '
          'Makin banyak yang gabung, makin besar keuntungannya.',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kode Referral Anda :',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        referralCode,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _copyCode(referralCode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(
                      'Salin',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralListCard(Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Referral',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: accent.withValues(alpha: 0.18),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                      accent.withValues(alpha: 0.85)),
                  headingRowHeight: 38,
                  dataRowMinHeight: 38,
                  dataRowMaxHeight: 42,
                  dividerThickness: 0.6,
                  headingTextStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  dataTextStyle: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  columnSpacing: 16,
                  horizontalMargin: 12,
                  columns: const [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Waktu')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: _referralEntries
                      .map(
                        (entry) => DataRow(
                          cells: [
                            DataCell(Text(entry.no)),
                            DataCell(Text(entry.name)),
                            DataCell(Text(entry.email)),
                            DataCell(Text(entry.time)),
                            DataCell(Text(
                              entry.status,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: entry.status == 'Aktif'
                                    ? const Color(0xFF2CA76F)
                                    : const Color(0xFFF4A340),
                              ),
                            )),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          if (_isLoadingReferrals) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Memuat data referral...',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ] else if (_referralError != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                _referralError!,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.error),
              ),
            ),
          ] else if (_referralEntries.isEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Belum ada referral yang terdaftar.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _loadReferralCode(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'referral_code_${user?.id ?? 'guest'}';
    final existing = prefs.getString(key);
    if (mounted && existing != null && existing.isNotEmpty) {
      setState(() => _referralCode = existing);
      return;
    }
    final generated = _buildReferralCode(user);
    await prefs.setString(key, generated);
    if (mounted) {
      setState(() => _referralCode = generated);
    }
  }

  Future<void> _fetchReferralDetails(String accessToken) async {
    if (_isLoadingReferrals) return;
    setState(() {
      _isLoadingReferrals = true;
      _referralError = null;
    });

    try {
      final response = await _referralApi.getMyReferralDetails(accessToken);
      final payload = response['data'];
      if (payload is Map<String, dynamic>) {
        final backendCode = payload['myReferralCode']?.toString();
        if (backendCode != null && backendCode.isNotEmpty) {
          _referralCode = backendCode;
          final prefs = await SharedPreferences.getInstance();
          final key = 'referral_code_${_lastUserId ?? 'guest'}';
          await prefs.setString(key, backendCode);
        }

        final list = payload['referrals'];
        if (list is List) {
          _referralEntries
            ..clear()
            ..addAll(
              list.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                if (value is Map<String, dynamic>) {
                  final status = value['isVerified'] == true
                      ? 'Aktif'
                      : 'Pending';
                  return _ReferralEntry(
                    no: '${index + 1}',
                    name: (value['name'] ?? '-').toString(),
                    email: (value['email'] ?? '-').toString(),
                    time: _formatDateTime(value['createdAt']?.toString()),
                    status: status,
                  );
                }
                return _ReferralEntry(
                  no: '${index + 1}',
                  name: '-',
                  email: '-',
                  time: '-',
                  status: 'Pending',
                );
              }),
            );
        } else {
          _referralEntries.clear();
        }
      } else {
        _referralEntries.clear();
      }
    } catch (e) {
      _referralError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() => _isLoadingReferrals = false);
      }
    }
  }

  String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value).toLocal();
      final year = parsed.year.toString().padLeft(4, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      final day = parsed.day.toString().padLeft(2, '0');
      final hour = parsed.hour.toString().padLeft(2, '0');
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute';
    } catch (_) {
      return value;
    }
  }

  String _buildReferralCode(User? user) {
    final normalizedName = (user?.displayName ?? '').trim().toUpperCase();
    if (normalizedName.isNotEmpty) {
      final words = normalizedName.split(' ');
      final initials =
          words.map((w) => w.isNotEmpty ? w[0] : '').take(2).join();
      return 'JYN-$initials${DateTime.now().year % 100}';
    }
    final uid = user?.id ?? '';
    if (uid.length >= 5) {
      return 'JYN-${uid.substring(0, 5).toUpperCase()}';
    }
    return 'JYN-INVITE';
  }

  Future<void> _copyCode(String referralCode) async {
    await Clipboard.setData(ClipboardData(text: referralCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kode $referralCode disalin. Bagikan ke teman sekarang!',
            style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.joyin,
      ),
    );
  }
}

class _ReferralEntry {
  final String no;
  final String name;
  final String email;
  final String time;
  final String status;

  const _ReferralEntry({
    required this.no,
    required this.name,
    required this.email,
    required this.time,
    required this.status,
  });
}
