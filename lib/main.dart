import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- IMPORT CONFIG & PAGES ---
import 'package:joyin/onboarding/onboarding_page.dart';
import 'package:joyin/dashboard/dashboard_gate.dart';
import 'package:joyin/gen_l10n/app_localizations.dart';

// --- IMPORT PROVIDERS ---
import 'package:joyin/providers/locale_provider.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/providers/chat_provider.dart';

import 'package:joyin/providers/dashboard_provider.dart';
import 'package:joyin/providers/auth_provider.dart';
import 'package:joyin/services/payment_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom backend initialization (if any).

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // --- PENDAFTARAN SEMUA PROVIDER ---
      providers: [
        ChangeNotifierProvider(
            create: (_) => PackageProvider()..hydrateFromPrefs()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),

        // ✅ Provider Otentikasi (Penting untuk Login/Regis)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, auth, chat) {
            chat ??= ChatProvider();
            chat.bindAuth(auth);
            return chat;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => LocaleProvider(const Locale('id')),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Joyin App',
            locale: provider.locale, // Mengikuti settingan provider
            debugShowCheckedModeBanner: false,

            // Konfigurasi Tema
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),

            // Konfigurasi Bahasa (Localization)
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('id'), // Indonesian
            ],

            // ✅ AuthWrapper: Pintu gerbang utama aplikasi
            // Mengecek apakah user sudah login atau belum
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

// --- AUTH WRAPPER ---
// Widget ini bertugas memantau status login via Token API.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _authCheck;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    // Cek status auth saat aplikasi dimulai
    _authCheck = Provider.of<AuthProvider>(context, listen: false)
        .checkAuthStatus(context);
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (_) {},
    );
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      _handleDeepLink(initial);
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme != 'joyin' || uri.host != 'payment-finish') {
      return;
    }

    final orderId = uri.queryParameters['order_id'] ??
        uri.queryParameters['orderId'] ??
        await _loadLastSnapOrderId();

    if (orderId != null && orderId.isNotEmpty) {
      try {
        await PaymentApiService().syncSnapPayment(orderId: orderId);
      } catch (_) {}
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshProfile();

    final user = authProvider.user;
    if (user?.plan != null) {
      final packageProvider =
          Provider.of<PackageProvider>(context, listen: false);
      final mapped = _mapPlanToPackageName(user!.plan!);
      if (mapped != null) {
        packageProvider.loadCurrentUserPackage(mapped);
      }
    }

    if (!mounted) return;

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardGate()),
      (route) => false,
    );

    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran selesai. Status paket diperbarui.'),
        ),
      );
    }
  }

  String? _mapPlanToPackageName(String plan) {
    final normalized = plan.trim().toUpperCase();
    if (normalized == 'BASIC') return 'Basic';
    if (normalized == 'PRO') return 'Pro';
    if (normalized == 'BUSINESS') return 'Bisnis';
    if (normalized == 'ENTERPRISE') return 'Enterprise';
    return null;
  }

  Future<String?> _loadLastSnapOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_snap_order_id');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authCheck,
      builder: (context, snapshot) {
        // 1. Sedang Memuat
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Cek Hasil Login
        final isLoggedIn = snapshot.data ?? false;

        // 3. User Sudah Login -> Masuk Dashboard
        if (isLoggedIn) {
          return const DashboardGate();
        }

        // 4. User Belum Login -> Masuk ke Onboarding (atau Login)
        return const OnboardingPage();
      },
    );
  }
}


