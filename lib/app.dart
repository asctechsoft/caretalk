import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:care_talk/core/theme/app_theme.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:care_talk/providers/auth_provider.dart';
import 'package:care_talk/providers/chat_provider.dart';
import 'package:care_talk/providers/patient_provider.dart';

/// Root widget của ứng dụng CareTalk
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
      ],
      child: MaterialApp.router(
        // ─── App Info ──────────────────────────────────────────────────
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // ─── Theme ─────────────────────────────────────────────────────
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // ─── Localizations ─────────────────────────────────────────────
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi', ''),
          Locale('en', ''),
        ],

        // ─── Router ────────────────────────────────────────────────────
        routerConfig: AppRouter.router,

        // ─── Web Mobile Wrapper ───────────────────────────────────────
        builder: (context, child) {
          if (kIsWeb) {
            return Scaffold(
              backgroundColor: const Color(0xFF0F172A), // Dark slate background
              body: Center(
                child: Container(
                  width: 450, // Mobile width
                  height: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          }
          return child!;
        },
      ),
    );
  }
}
