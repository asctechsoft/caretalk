import 'package:flutter/material.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/widgets/app_button.dart';
import 'package:provider/provider.dart';
import 'package:care_talk/providers/auth_provider.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:go_router/go_router.dart';

enum AssessmentSeverity {
  emergency, // Khẩn cấp
  moderate, // Mức độ nặng/vừa
  low, // Nguy cơ thấp
}

class SymptomAssessmentScreen extends StatelessWidget {
  final AssessmentSeverity severity;

  const SymptomAssessmentScreen({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    switch (severity) {
      case AssessmentSeverity.emergency:
        return _buildEmergencyUI(context);
      case AssessmentSeverity.moderate:
        return _buildModerateUI(context);
      case AssessmentSeverity.low:
        return _buildLowRiskUI(context);
    }
  }

  // ─── Emergency UI (Image 1) ──────────────────────────────────────────
  Widget _buildEmergencyUI(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Warning Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFD32F2F),
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'CẢNH BÁO KHẨN CẤP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB71C1C),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Triệu chứng của bạn đang ở mức rủi ro cao. Xin đừng chủ quan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 32),

              // Instruction Box
              Container(
                padding: const EdgeInsets.all(AppDimens.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFEBEE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFEBEE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: Color(0xFFD32F2F),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hướng dẫn quan trọng',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Cần thực hiện các bước sau ngay bây giờ:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Vui lòng đến bệnh viện\ngần nhất ngay lập tức!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMinorInstruction(
                      Icons.person_pin_circle_outlined,
                      'Giữ bình tĩnh, hít thở sâu',
                    ),
                    const SizedBox(height: 8),
                    _buildMinorInstruction(
                      Icons.no_crash_outlined,
                      'Không tự lái xe đi cấp cứu',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              AppButton(
                text: 'Gọi Hotline Cấp Cứu (115)',
                backgroundColor: const Color(0xFFB71C1C),
                icon: Icons.phone_in_talk,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Bản đồ bệnh viện gần đây',
                backgroundColor: const Color(0xFFECEFF1),
                textColor: Colors.black87,
                icon: Icons.map_outlined,
                onPressed: () {},
              ),

              const SizedBox(height: 24),

              // Map Preview / Location
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://static.vecteezy.com/system/resources/previews/000/664/110/original/abstract-city-map-with-pins-vector.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 10,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ĐANG XÁC ĐỊNH VỊ TRÍ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'XEM CHI TIẾT',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildMinorInstruction(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Moderate UI (Image 2) ───────────────────────────────────────────
  Widget _buildModerateUI(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD32F2F),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Color(0xFFB71C1C), size: 8),
                      SizedBox(width: 8),
                      Text(
                        'MỨC ĐỘ NẶNG',
                        style: TextStyle(
                          color: Color(0xFFB71C1C),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kết quả phân tích',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sức khỏe của bạn là ưu tiên hàng đầu. Chúng tôi khuyên bạn nên tham khảo ý kiến chuyên gia ngay bây giờ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD0E0FF)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.volunteer_activism_outlined,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Chúng tôi luôn ở đây cùng bạn',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Đừng lo lắng, chúng tôi sẽ hỗ trợ bạn kết nối với bác sĩ nhanh nhất có thể. Trong khi chờ đợi, hãy giữ bình tĩnh và nghỉ ngơi. Nếu tình trạng không cải thiện sau 15 phút, bạn nên đến cơ sở y tế gần nhất để được chăm sóc trực tiếp nhé.',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Liên hệ với bác sĩ ngay',
                  icon: Icons.medical_services_outlined,
                  onPressed: () => _handleContactDoctor(context),
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Tiếp tục trò chuyện',
                  backgroundColor: const Color(0xFFECEFF1),
                  textColor: Colors.black87,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Low Risk UI (Image 3) ───────────────────────────────────────────
  Widget _buildLowRiskUI(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0E0FF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFF81C784),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nguy cơ thấp',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Dựa trên thông tin cung cấp, tình trạng của bạn hiện tại không có dấu hiệu nguy hiểm',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.lg),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FBE7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE6EE9C)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Khả năng cao là: Cảm lạnh thông thường',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF827717),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Gợi ý xử lý tại nhà:',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            _buildStep('Nghỉ ngơi uống nhiều nước ấm'),
                            _buildStep('Súc họng bằng nước muối'),
                            _buildStep('Có thể dùng thuốc hạ sốt nếu cần'),
                            _buildStep('Theo dõi triệu chứng 2-3 ngày'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 12),
                                Text(
                                  'Khi nào cần đi khám ngay?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildWarningPoint(
                              'Nếu triệu chứng nặng hơn, sốt cao trên 39°C',
                            ),
                            _buildWarningPoint(
                              'Đau ngực hoặc không cải thiện sau 3 ngày',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Tôi đã hiểu',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF81C784), size: 18),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildWarningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, color: Colors.orange, size: 24),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _handleContactDoctor(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoggedIn) {
      context.push(AppRouter.requestSuccessPath);
    } else {
      _showAuthRequiredDialog(context);
    }
  }

  void _showAuthRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/img_logo.png',
                  fit: BoxFit.contain,
                  width: 60,
                  height: 60,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kết nối với Bác sĩ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Để được liên hệ và tư vấn trực tiếp với bác sĩ chuyên khoa, vui lòng Đăng ký hoặc Đăng nhập tài khoản của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Đăng ký ngay',
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRouter.registerPath);
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Đăng nhập',
                backgroundColor: const Color(0xFFECEFF1),
                textColor: AppColors.textPrimary,
                onPressed: () {
                  Navigator.pop(context);
                  context.push('${AppRouter.loginPath}?role=patient');
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Để sau',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
