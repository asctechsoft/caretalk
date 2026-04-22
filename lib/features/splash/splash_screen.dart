import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:care_talk/providers/auth_provider.dart';

/// Màn hình Splash - hiển thị khi mở app
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final storage = StorageService();
    final isFirstLaunch = await storage.isFirstLaunch();
    final isLoggedIn = await storage.isLoggedIn();

    if (!mounted) return;

    if (isFirstLaunch) {
      context.go(AppRouter.onboardingPath);
    } else if (isLoggedIn) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.init();
      final user = authProvider.currentUser;

      if (user?.role == 'doctor' && !user!.isProfileComplete) {
        context.go(AppRouter.doctorSupplementInfoPath);
      } else if (user?.role == 'patient') {
        context.go(AppRouter.patientHomePath);
      } else {
        context.go(AppRouter.homePath);
      }
    } else {
      context.go(AppRouter.roleSelectionPath);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.onboardingGradient),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Image
                    Image.asset(
                      'assets/images/img_logo.png',
                      fit: BoxFit.contain,
                      height: 120,
                      width: 120,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'CareTalk',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trợ lý sức khỏe thông minh',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
