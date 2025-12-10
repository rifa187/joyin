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
import 'package:joyin/providers/user_provider.dart';
import 'package:joyin/providers/dashboard_provider.dart';
import 'package:joyin/providers/auth_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom Backend Initialization (if any)
  // Firebase initialization removed.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // --- PENDAFTARAN SEMUA PROVIDER ---
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
            create: (_) => PackageProvider()..hydrateFromPrefs()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),

        // ✅ Provider Otentikasi (Penting untuk Login/Regis)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

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

  @override
  void initState() {
    super.initState();
    // Cek status auth saat aplikasi dimulai
    _authCheck = Provider.of<AuthProvider>(context, listen: false)
        .checkAuthStatus(context);
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
