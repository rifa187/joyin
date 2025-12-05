import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

// --- IMPORT CONFIG & PAGES ---
import 'package:joyin/firebase_options.dart';
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
  
  // Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization warning: $e");
  }

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
        ChangeNotifierProvider(create: (_) => PackageProvider()..hydrateFromPrefs()),
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
// Widget ini bertugas memantau status login Firebase secara real-time.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Sedang Memuat (Cek koneksi ke server)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Terjadi Error
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Terjadi kesalahan koneksi!')),
          );
        }

        // 3. User Sudah Login (Ada Data) -> Masuk ke Dashboard
        if (snapshot.hasData) {
          return const DashboardGate();
        }

        // 4. User Belum Login -> Masuk ke Onboarding
        return const OnboardingPage();
      },
    );
  }
}
