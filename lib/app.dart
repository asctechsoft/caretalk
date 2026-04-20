import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:care_talk/core/theme/app_theme.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/constants/app_strings.dart';
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

        // ─── Router ────────────────────────────────────────────────────
        routerConfig: AppRouter.router,
      ),
    );
  }
}
