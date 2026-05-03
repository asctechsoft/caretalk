import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:care_talk/core/theme/app_theme.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:care_talk/providers/auth_provider.dart';
import 'package:care_talk/providers/chat_provider.dart';
import 'package:care_talk/providers/patient_provider.dart';

/// Root widget của ứng dụng CareTalk
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hideNavBar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Ẩn navigation bar phía dưới, giữ status bar
  void _hideNavBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  /// Reapply khi app resume từ background (hệ thống có thể reset lại)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _hideNavBar();
    }
  }

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
              backgroundColor: const Color(0xFF0F172A),
              body: Center(
                child: Container(
                  width: 450,
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
