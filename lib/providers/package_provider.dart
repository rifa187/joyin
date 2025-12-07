import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../package/package_info.dart';

class PackageProvider with ChangeNotifier {
  final List<PackageInfo> _packages = [
    PackageInfo(
      name: 'Basic',
      price: 'Rp 49.000 / Bulan',
      features: [
        '300 percakapan/bulan',
        'Balasan otomatis 24/7',
        'Integrasi WhatsApp mudah',
        'Template balasan standar',
        'FAQ dasar bawaan',
      ],
      gradient: const LinearGradient(
        colors: [Color(0xFF9B51E0), Color(0xFF5FCAAC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      durationMonths: 1,
    ),
    PackageInfo(
      name: 'Pro',
      price: 'Rp 99.000 / Bulan',
      features: [
        '1000 percakapan/bulan',
        'Balasan otomatis 24/7',
        'Template balasan custom',
        'Auto-update FAQ produk',
        'Statistik & insight pelanggan',
        'Notifikasi chat masuk',
        'Pesan sambutan personal',
      ],
      gradient: const LinearGradient(
        colors: [Color(0xFFA8E063), Color(0xFF5FCAAC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      durationMonths: 1,
    ),
    PackageInfo(
      name: 'Bisnis',
      price: 'Rp 199.000 / Bulan',
      features: [
        '5000 percakapan/bulan',
        'Multi-admin WhatsApp',
        'Balasan otomatis 24/7',
        'Template balasan premium',
        'FAQ otomatis & terjadwal',
        'Pesan terjadwal promosi',
        'Laporan mingguan lengkap',
        'Prioritas dukungan teknis',
      ],
      gradient: const LinearGradient(
        colors: [Color(0xFF9C63F7), Color(0xFF60C8AC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      durationMonths: 1,
    ),
    PackageInfo(
      name: 'Enterprise',
      price: 'Rp 499.000 / Bulan',
      features: [
        'Chat tanpa batas',
        'Integrasi WhatsApp API penuh',
        'Balasan otomatis 24/7',
        'Template balasan standar',
        'Statistik bulanan sederhana',
        'Laporan custom & konsultasi setup',
        'Prioritas dukungan & SLA support',
        'Integrasi sistem internal (CRM/API)',
      ],
      gradient: const LinearGradient(
        colors: [Color(0xFF9C64F7), Color(0xFF5FCAAC), Color(0xFFD7EB76)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      durationMonths: 1,
    ),
  ];

  List<PackageInfo> get packages => _packages;

  String? _currentUserPackage;
  String? get currentUserPackage => _currentUserPackage;

  final Map<String, int> _selectedDurations = {};
  Map<String, int> get selectedDurations => _selectedDurations;
  bool _hydrated = false;

  void loadCurrentUserPackage(String? package) {
    _currentUserPackage = package;
    notifyListeners();
  }

  void selectDuration(String packageName, int duration) {
    _selectedDurations[packageName] = duration;
    notifyListeners();
  }

  /// Load persisted package selection so users aren't asked to buy again after restart.
  Future<void> hydrateFromPrefs() async {
    if (_hydrated) return;
    final prefs = await SharedPreferences.getInstance();
    final savedPackage = prefs.getString('selected_package');
    final savedDuration = prefs.getInt('selected_package_duration_months');
    if (savedPackage != null && savedPackage.isNotEmpty) {
      _currentUserPackage = savedPackage;
      if (savedDuration != null) {
        _selectedDurations[savedPackage] = savedDuration;
      }
      notifyListeners();
    }
    _hydrated = true;
  }
}
