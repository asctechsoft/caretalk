import 'package:flutter/material.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/widgets/app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/router/app_router.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/img_logo.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'CareTalk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                onPressed: () => _showNotifications(context),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildHistoryDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            const Text(
              'Xin chào!',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const Text(
              'Bạn cần hỗ trợ gì hôm nay?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Main Action Card
            Container(
              padding: const EdgeInsets.all(AppDimens.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chat với Trợ lý AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tư vấn trực tuyến về các triệu chứng và thông tin y khoa',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Bắt đầu chat ngay',
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary,
                    onPressed: () {
                      // Đi tới màn hình chat cho bệnh nhân
                      context.push('/patient-chat');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Grid of other features
            const Text(
              'Tiện ích khác',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // GridView.count(
            //   crossAxisCount: 2,
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   mainAxisSpacing: 16,
            //   crossAxisSpacing: 16,
            //   children: [
            //     _FeatureCard(
            //       icon: Icons.calendar_month_outlined,
            //       title: 'Đặt lịch khám',
            //       color: Colors.orange,
            //       onTap: () {},
            //     ),
            //     _FeatureCard(
            //       icon: Icons.history_rounded,
            //       title: 'Lịch sử khám',
            //       color: Colors.blue,
            //       onTap: () {},
            //     ),
            //     _FeatureCard(
            //       icon: Icons.medication_outlined,
            //       title: 'Đơn thuốc',
            //       color: Colors.green,
            //       onTap: () {},
            //     ),
            //     _FeatureCard(
            //       icon: Icons.info_outline_rounded,
            //       title: 'Kiến thức y khoa',
            //       color: Colors.purple,
            //       onTap: () {},
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Lịch sử tư vấn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildHistoryItem(
                  'Đau nửa đầu và chóng mặt',
                  '15 phút trước',
                  Icons.history_rounded,
                ),
                _buildHistoryItem(
                  'Sốt nhẹ và ho khan',
                  'Hôm qua',
                  Icons.history_rounded,
                ),
                _buildHistoryItem(
                  'Đau dạ dày cấp tính',
                  '3 ngày trước',
                  Icons.history_rounded,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
            title: const Text(
              'Tư vấn mới',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/patient-chat');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt'),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String time, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      onTap: () {},
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thông báo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildNotificationItem(
                    icon: Icons.chat_bubble_rounded,
                    color: Colors.blue,
                    title: 'Bác sĩ đã trả lời',
                    message:
                        'Bác sĩ Nguyễn Văn A vừa phản hồi tin nhắn của bạn.',
                    time: 'Vừa xong',
                    isUnread: true,
                    onTap: () {
                      Navigator.pop(context); // Đóng modal thông báo
                      context.push(
                        AppRouter.patientDoctorChatPath,
                      ); // Sang màn chat với bác sĩ
                    },
                  ),
                  // _buildNotificationItem(
                  //   icon: Icons.calendar_month_rounded,
                  //   color: Colors.orange,
                  //   title: 'Nhắc nhở lịch hẹn',
                  //   message: 'Bạn có lịch khám tổng quát vào 09:00 sáng mai.',
                  //   time: '2 giờ trước',
                  //   isUnread: false,
                  // ),
                  // _buildNotificationItem(
                  //   icon: Icons.medical_information_rounded,
                  //   color: Colors.green,
                  //   title: 'Bạn có đơn thuốc mới',
                  //   message:
                  //       'Đơn thuốc của bạn đã được cập nhật. Vui lòng kiểm tra.',
                  //   time: '1 ngày trước',
                  //   isUnread: false,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? color.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
