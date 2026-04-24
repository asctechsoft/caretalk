import 'package:flutter/material.dart';

/// Bảng màu chủ đạo cho ứng dụng CareTalk
class AppColors {
  AppColors._();

  // ─── Primary Colors ────────────────────────────────────────────────
  static const Color primary = Color(0xFF2B6CB0);
  static const Color primaryLight = Color(0xFF4A9BD9);
  static const Color primaryDark = Color(0xFF1A4971);
  static const Color primarySurface = Color(0xFFE8F4FD);
  static const Color primaryWhite = Color(0xFFF9F9FE);

  // ─── Secondary / Accent ────────────────────────────────────────────
  static const Color accent = Color(0xFF38B2AC);
  static const Color accentLight = Color(0xFF81E6D9);
  static const Color accentDark = Color(0xFF285E61);

  // ─── Semantic Colors ───────────────────────────────────────────────
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFECC94B);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF3182CE);

  // ─── Neutral / Gray ────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E0);
  static const Color disabled = Color(0xFFA0AEC0);
  static const Color placeholder = Color(0xFFA0AEC0);

  // ─── Text Colors ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textHint = Color(0xFFA0AEC0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ─── Chat Colors ───────────────────────────────────────────────────
  static const Color chatBubbleSent = Color(0xFF2B6CB0);
  static const Color chatBubbleReceived = Color(0xFFF0F4F8);
  static const Color chatBubbleBot = Color(0xFFEDF2F7);
  static const Color chatInputBackground = Color(0xFFF7FAFC);

  // ─── Status Colors (Bệnh nhân) ────────────────────────────────────
  static const Color statusWaiting = Color(0xFFFBD38D);
  static const Color statusInProgress = Color(0xFF63B3ED);
  static const Color statusCompleted = Color(0xFF68D391);
  static const Color statusCancelled = Color(0xFFFC8181);

  // ─── Gradient ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF005BBC), Color(0xFF00A1FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient1 = LinearGradient(
    colors: [Color.fromARGB(199, 174, 196, 161), Color(0xFF00A1FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF1A4971), Color(0xFF2B6CB0), Color(0xFF38B2AC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final LinearGradient onboardingGradient = LinearGradient(
    colors: [
      const Color(0xFF81ADFF).withValues(alpha: 0.2),
      const Color(0xFF81ADFF).withValues(alpha: 0.7),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Dark Theme Colors ─────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF1A202C);
  static const Color darkSurface = Color(0xFF2D3748);
  static const Color darkCard = Color(0xFF2D3748);
  static const Color darkDivider = Color(0xFF4A5568);
  static const Color darkTextPrimary = Color(0xFFF7FAFC);
  static const Color darkTextSecondary = Color(0xFFA0AEC0);
}
