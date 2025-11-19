import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:joyin/firebase_options.dart';
import 'package:joyin/onboarding/onboarding_page.dart';
import 'package:joyin/providers/locale_provider.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:joyin/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joyin/dashboard/dashboard_page.dart';

import 'package:joyin/providers/dashboard_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>(); // Global key

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
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
            navigatorKey: navigatorKey, // Assign key
            locale: provider.locale,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue),
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
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;

      if (user == null) {
        // User is signed out -> Go to Onboarding
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
          (route) => false,
        );
      } else {
        // User is signed in -> Go to Dashboard
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while the listener decides where to go
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
