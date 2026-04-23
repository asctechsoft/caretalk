import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/constants/app_assets.dart';
import 'package:care_talk/core/constants/pref_const.dart';
import 'package:care_talk/core/router/app_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.onboardingPath);
            }
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Icon/Logo
                Image.asset(
                  AppAssets.logo,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Chào mừng bạn đến với CareTalk',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vui lòng chọn vai trò của bạn để tiếp tục',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Patient Option
                _RoleCard(
                  title: 'Bệnh nhân',
                  description: 'Tìm kiếm tư vấn và theo dõi sức khỏe',
                  icon: Icons.person_outline_rounded,
                  color: AppColors.primary,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(PrefConst.roleAccount, 'patient');
                    if (context.mounted) {
                      context.push(AppRouter.patientLandingPath);
                    }
                  },
                ),
                const SizedBox(height: 20),

                _RoleCard(
                  title: 'Bác sĩ / Nhân viên',
                  description: 'Quản lý và tư vấn cho bệnh nhân',
                  icon: Icons.medical_services_outlined,
                  color: AppColors.error,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(PrefConst.roleAccount, 'doctor');
                    if (context.mounted) {
                      context.push('${AppRouter.loginPath}?role=staff');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
