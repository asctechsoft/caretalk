import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/services/storage_service.dart';
import 'package:care_talk/core/widgets/app_button.dart';

/// Màn hình Onboarding được thiết kế lại theo mẫu Clinic AI
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _onStart(BuildContext context) async {
    await StorageService().setFirstLaunchComplete();
    if (context.mounted) {
      context.go(AppRouter.roleSelectionPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.xl,
              vertical: AppDimens.lg,
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Top Logo
                Image.asset(
                  'assets/images/img_logo.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),

                // App Name
                const Text(
                  AppStrings.appNameAlt,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B6CB0),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                const Text(
                  AppStrings.onboardingTitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  AppStrings.onboardingSubtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Main Illustration (Robot)
                Image.asset(
                  'assets/images/img_onboarding.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),

                const Spacer(),

                // Start Button
                AppGradientButton(
                  text: AppStrings.onboardingStart,
                  onPressed: () => _onStart(context),
                ),
                const SizedBox(height: 16),

                // Footer text
                GestureDetector(
                  onTap: () {
                    // TODO: Show terms and conditions
                  },
                  child: const Text(
                    AppStrings.onboardingFooter,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF718096),
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
