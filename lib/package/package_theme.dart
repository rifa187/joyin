import 'package:flutter/material.dart';

class PackageTheme {
  final List<Color> headerGradient;
  final List<Color> cardGradient;
  final List<Color> backgroundGradient;
  final Color accent;

  const PackageTheme({
    required this.headerGradient,
    required this.cardGradient,
    required this.backgroundGradient,
    required this.accent,
  });
}

class PackageThemeResolver {
  static final PackageTheme _fallback = PackageTheme(
    headerGradient: const [Color(0xFF4DB6AC), Color(0xFF81C784)],
    cardGradient: const [Color(0xFF4DB6AC), Color(0xFF81C784)],
    backgroundGradient: const [Color(0xFFEFF5F3), Color(0xFFF7FAF8)],
    accent: const Color(0xFF4DB6AC),
  );

  static final Map<String, PackageTheme> _map = {
    'Basic': PackageTheme(
      headerGradient: const [Color(0xFF5FCAAC), Color(0xFF5FCAAC)],
      cardGradient: const [Color(0xFF5FCAAC), Color(0xFF5FCAAC)],
      backgroundGradient: const [Color(0xFFE7F7F1), Color(0xFFF3FBF8)],
      accent: const Color(0xFF5FCAAC),
    ),
    'Pro': PackageTheme(
      headerGradient: const [Color(0xFF5FCAAC), Color(0xFFD5EA77)],
      cardGradient: const [Color(0xFF5FCAAC), Color(0xFFD5EA77)],
      backgroundGradient: const [Color(0xFFF0F8EA), Color(0xFFF8FCEB)],
      accent: const Color(0xFF5FCAAC),
    ),
    'Bisnis': PackageTheme(
      headerGradient: const [Color(0xFF9C64F7), Color(0xFF5FCAAC), Color(0xFFD7EB76)],
      cardGradient: const [Color(0xFF9C64F7), Color(0xFF5FCAAC), Color(0xFFD7EB76)],
      backgroundGradient: const [Color(0xFFF3EEFF), Color(0xFFE8F7F2)],
      accent: const Color(0xFF9C64F7),
    ),
    'Enterprise': PackageTheme(
      headerGradient: const [Color(0xFF9C63F7), Color(0xFF60C8AC)],
      cardGradient: const [Color(0xFF9C63F7), Color(0xFF60C8AC)],
      backgroundGradient: const [Color(0xFFF2EEFF), Color(0xFFE8F7F3)],
      accent: const Color(0xFF9C63F7),
    ),
  };

  static PackageTheme resolve(String? packageName) {
    if (packageName == null) return _fallback;
    for (final entry in _map.entries) {
      if (packageName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return _fallback;
  }
}
