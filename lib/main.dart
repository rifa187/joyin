import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Pastikan install package ini

// --- IMPORT FILE ANDA (Pastikan file ini ada di folder project Anda) ---
import 'package:joyin/firebase_options.dart';
import 'package:joyin/onboarding/onboarding_page.dart';
import 'package:joyin/dashboard/dashboard_page.dart';
import 'package:joyin/gen_l10n/app_localizations.dart';

// IMPORT PROVIDER ANDA
import 'package:joyin/providers/locale_provider.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/providers/user_provider.dart';
import 'package:joyin/providers/dashboard_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase dengan Error Handling yang rapi
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Jika error duplicate app, biarkan saja (aman)
    debugPrint("Firebase initialization warning: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PackageProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(const Locale('id')),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Joyin App',
            locale: provider.locale,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true, // Rekomendasi Flutter terbaru
            ),
            // Konfigurasi Bahasa
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
            // INI BAGIAN KUNCI: Menggunakan StreamBuilder untuk cek Login
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

// --- AUTH WRAPPER YANG LEBIH STABIL ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder akan otomatis memantau perubahan status Login/Logout
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Saat sedang mengecek ke server (Loading...)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Jika ada Error koneksi
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Terjadi kesalahan koneksi!')),
          );
        }

        // 3. Jika User ADA datanya (Sudah Login) -> Masuk Dashboard
        if (snapshot.hasData) {
          return const DashboardPage();
        }

        // 4. Jika User KOSONG (Belum Login) -> Masuk Onboarding
        return const OnboardingPage();
      },
    );
  }
}