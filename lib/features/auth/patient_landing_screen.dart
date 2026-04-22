import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/widgets/app_button.dart';
import 'package:care_talk/core/constants/app_assets.dart';

class PatientLandingScreen extends StatelessWidget {
  const PatientLandingScreen({super.key});

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
        decoration: BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top Header/Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.logo, width: 50, height: 50),
                  const SizedBox(width: 8),
                  const Text(
                    'CareTalk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Content Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
                child: Column(
                  children: [
                    // Badge-like info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5FF78E).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF27AE60),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Sức khỏe của bạn là ưu tiên hàng đầu',
                            style: TextStyle(
                              color: Color(0xFF27AE60),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Main Title
                    const Text(
                      'Chăm sóc sức khỏe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1E1E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'thông minh &',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'tận tâm.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1E1E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    const Text(
                      'Chúng tôi cung cấp giải pháp tư vấn sức khỏe bảo mật ngay trên điện thoại của bạn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(AppDimens.xl),
                padding: const EdgeInsets.all(AppDimens.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AppButton(
                      text: 'Đăng nhập',
                      onPressed: () =>
                          context.push('${AppRouter.loginPath}?role=patient'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Đăng ký',
                      backgroundColor: const Color(0xFFECEFF1),
                      textColor: AppColors.textPrimary,
                      onPressed: () => context.push(AppRouter.registerPath),
                    ),
                    const SizedBox(height: 16),

                    // OR Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Hoặc',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Anonymous Chat Button
                    AppButton(
                      text: 'Chat ẩn danh',
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: () => context.push(AppRouter.patientChatPath),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tư vấn ngay mà không cần tài khoản',
                      style: TextStyle(color: AppColors.textHint, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Action Buttons Section

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSecurityInfo(Icons.security, 'DỮ LIỆU BẢO MẬT'),
                        const SizedBox(width: 12),
                        _buildSecurityInfo(
                          Icons.verified,
                          'ĐỘ CHÍNH XÁC LÂM SÀNG',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSecurityInfo(
                      Icons.lock,
                      'QUYỀN RIÊNG TƯ LÀ TRÊN HẾT',
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'CareTalk',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(' © 2026', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.primaryDark),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
