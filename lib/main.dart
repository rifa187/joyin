import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. IMPORT DOTENV

// --- IMPORT CONFIG & PAGES ---
import 'package:joyin/firebase_options.dart';
import 'package:joyin/onboarding/onboarding_page.dart'; 
import 'package:joyin/dashboard/dashboard_page.dart';
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
  
  // 2. LOAD ENVIRONMENT VARIABLES (Wajib untuk SendGrid)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: File .env tidak ditemukan. Pastikan file ada di root project.");
  }
  
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
              primarySwatch: Colors.teal, 
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
            
            // LOGIC UTAMA: Cek status Auth di sini
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // 1. Sedang Memuat (Checking Auth...)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Jika User SUDAH LOGIN (Ada Data Auth)
        if (snapshot.hasData) {
          final user = snapshot.data!;
          
          // --- PENTING: LOAD DATA USER ---
          // Kita aktifkan baris ini agar data Nama & Role Admin terbaca saat Auto Login
          WidgetsBinding.instance.addPostFrameCallback((_) {
             Provider.of<UserProvider>(context, listen: false).loadUserData(user.uid);
          });

          return const DashboardPage();
        }

        // 3. Jika User BELUM LOGIN -> Masuk Onboarding
        return const OnboardingPage();
      },
    );
  }
}