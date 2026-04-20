import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/widgets/app_button.dart';

class PatientLandingScreen extends StatelessWidget {
  const PatientLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header/Logo
            Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
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
            ),

            const Spacer(),

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
                  const SizedBox(height: 24),

                  // Main Title
                  const Text(
                    'Chăm sóc sức khỏe',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'thông minh &',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'tận tâm.',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Subtitle
                  const Text(
                    'Kết nối tức thì với các chuyên gia y tế hàng đầu. Chúng tôi cung cấp giải pháp tư vấn sức khỏe bảo mật ngay trên điện thoại của bạn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Action Buttons Section
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

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
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
                  _buildSecurityInfo(Icons.lock, 'QUYỀN RIÊNG TƯ LÀ TRÊN HẾT'),
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
    );
  }

  Widget _buildSecurityInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
