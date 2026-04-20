import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/widgets/app_button.dart';

class RequestSuccessScreen extends StatelessWidget {
  const RequestSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Success Animation/Icon
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB9F6CA),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFB9F6CA), width: 3),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Yêu cầu đã được gửi!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bác sĩ sẽ phản hồi bạn trong giây lát. Vui lòng giữ kết nối.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 48),

              // Info Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('MÃ YÊU CẦU', '#CT-88294', isBold: true),
                    const SizedBox(height: 20),
                    _buildInfoRow('CHUYÊN KHOA', 'Internal Medicine', isBold: true),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Yêu cầu của bạn đang được ưu tiên xử lý bởi đội ngũ chuyên gia trực ca.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              AppButton(
                text: 'Quay lại đoạn chat',
                onPressed: () => context.go(AppRouter.patientChatPath),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Xem chi tiết lịch hẹn',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer Support
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text('Cần hỗ trợ? ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  GestureDetector(
                    child: const Text(
                      'Liên hệ tổng đài',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
