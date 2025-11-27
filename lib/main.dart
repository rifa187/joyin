import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

// --- IMPORT CONFIG & PAGES ---
import 'package:joyin/firebase_options.dart';
import 'package:joyin/onboarding/onboarding_page.dart'; // Pastikan path ini benar
import 'package:joyin/dashboard/dashboard_page.dart';
import 'package:joyin/auth/login_page.dart';
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
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PackageProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
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
            locale: provider.locale,
            debugShowCheckedModeBanner: false,
            
            theme: ThemeData(
              primarySwatch: Colors.teal, // Sesuaikan dengan warna Joyin
              useMaterial3: true,
            ),
            
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('id'),
            ],
            
            // === PERBAIKAN UTAMA DI SINI ===
            // Kita gunakan AuthWrapper untuk mengecek status login.
            // TAPI, logika di dalam AuthWrapper juga harus benar.
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Sedang Memuat
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Jika User SUDAH LOGIN -> Masuk Dashboard
        if (snapshot.hasData) {
          // PENTING: Update UserProvider di sini agar data user tersedia di seluruh aplikasi
          // Kita lakukan di post-frame callback agar tidak error saat build
          WidgetsBinding.instance.addPostFrameCallback((_) {
             // Simpan data user ke provider agar Drawer bisa baca
             // Pastikan UserProvider punya method setUserFromFirebase
             // Jika belum ada, buat dulu di file user_provider.dart
             // Provider.of<UserProvider>(context, listen: false).setUserFromFirebase(snapshot.data!);
          });
          return const DashboardPage();
        }

        // 3. Jika User BELUM LOGIN -> Masuk Onboarding
        return const OnboardingPage();
      },
    );
  }
}