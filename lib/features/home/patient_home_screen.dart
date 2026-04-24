import 'package:flutter/material.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/widgets/app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:care_talk/providers/auth_provider.dart';
import 'package:care_talk/core/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  List<Map<String, dynamic>> _historySessions = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    List<Map<String, dynamic>> history = [];
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('chat_sessions')
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final sessions = doc.data()!['sessions'];
          if (sessions != null) {
            history = List<Map<String, dynamic>>.from(
              (sessions as List).map((e) => Map<String, dynamic>.from(e)),
            );
          }
        } else {
          history = await StorageService().getChatHistory();
        }
      } catch (e) {
        debugPrint('❌ Lỗi load Firestore HomeScreen: $e');
        history = await StorageService().getChatHistory();
      }
    } else {
      history = await StorageService().getChatHistory();
    }

    if (mounted) {
      setState(() {
        _historySessions = history;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                onPressed: () => {},
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
                  Image.asset(
                    'assets/images/img_home_benh_nhan.png',
                    height: 80,
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

                  AppButton(
                    text: 'Bắt đầu chat ngay',
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary,
                    onPressed: () {
                      // Đi tới màn hình chat cho bệnh nhân
                      context.push('/patient-chat').then((_) => _loadHistory());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(AppDimens.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient1,
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
                  const SizedBox(height: 16),
                  const Text(
                    'Tạo yêu cầu tới Bác sĩ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Trao đổi trực tiếp với Bác sĩ chuyên khoa',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Yêu cầu Bác sĩ',
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary,
                    onPressed: () async {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final auth = context.read<AuthProvider>();
                        final patientId = auth.currentUser?.id;
                        if (patientId == null)
                          throw Exception('Chưa đăng nhập');

                        final requestId =
                            'CT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

                        // Lưu vào Firestore collection 'consultations'
                        await FirebaseFirestore.instance
                            .collection('consultations')
                            .add({
                              'requestId': requestId,
                              'patientId': patientId,
                              'doctorId': '', // Để trống vì chưa có bác sĩ nhận
                              'status': 'waiting',
                              'specialty':
                                  'Internal Medicine', // Có thể thêm UI chọn chuyên khoa sau
                              'createdAt': FieldValue.serverTimestamp(),
                              'updatedAt': FieldValue.serverTimestamp(),
                            });

                        // Đóng loading dialog
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          _showConsultationSuccessDialog(
                            context,
                            requestId,
                            'Internal Medicine',
                          );
                        }
                      } catch (e) {
                        // Đóng loading dialog
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            // Grid of other features
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
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.currentUser;
              final isLoggedIn = authProvider.isLoggedIn;

              debugPrint('--- USER LOG ---');
              debugPrint('isLoggedIn: $isLoggedIn');
              debugPrint('Name: ${user?.fullName}');
              debugPrint('Email: ${user?.email}');
              debugPrint('Role: ${user?.role}');
              debugPrint('----------------');

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (!isLoggedIn) {
                      context.pop();
                      context.push('${AppRouter.loginPath}?role=patient');
                    } else {
                      context.pop();
                      // context.push(AppRouter.settingsPath);
                      // Bấm vào đây tao muốn vào màn cập nhật profile của bệnh nhân
                      context.push(AppRouter.patientInfoPath);
                    }
                  },
                  child: Ink(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      bottom: 16,
                      left: 16,
                      right: 16,
                    ),
                    decoration: const BoxDecoration(color: AppColors.primary),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: isLoggedIn
                              ? Center(
                                  child: Text(
                                    user?.fullName.isNotEmpty == true
                                        ? user!.fullName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLoggedIn
                                    ? (user?.fullName ?? 'User')
                                    : 'Đăng nhập',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isLoggedIn
                                    ? (user?.email ?? '')
                                    : 'Đăng nhập để trao đổi với bác sĩ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          Center(
            child: InkWell(
              onTap: () {
                context.pop();
                context
                    .push(AppRouter.patientChatPath)
                    .then((_) => _loadHistory());
              },
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Tạo chat mới',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Divider(),
          ),

          SizedBox(height: 8),

          // Center(
          //   child: InkWell(
          //     onTap: () {
          //       context.pop();
          //       context.push(AppRouter.patientConsultationHistoryPath);
          //     },
          //     child: Ink(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 8,
          //       ),
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: Row(
          //         children: [
          //           const Icon(
          //             Icons.request_quote_rounded,
          //             color: AppColors.primary,
          //           ),
          //           const SizedBox(width: 16),
          //           const Text(
          //             'Yêu cầu với bác sĩ',
          //             style: TextStyle(
          //               color: AppColors.textPrimary,
          //               fontSize: 16,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          //   child: Divider(),
          // ),
          // const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.history, color: AppColors.textPrimary),
                  const SizedBox(width: 16),
                  const Text(
                    'Lịch sử tư vấn',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _historySessions.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có lịch sử',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _historySessions.length,
                    itemBuilder: (context, index) {
                      final session = _historySessions[index];
                      return _buildHistoryItem(
                        session['title'] ?? 'Cuộc hội thoại',
                        session['time'] ?? 'Gần đây',
                        Icons.history_rounded,
                        onTap: () {
                          debugPrint('--- BẤM VÀO LỊCH SỬ: Index $index ---');
                          context.pop(); // Đóng drawer
                          context
                              .pushNamed(
                                AppRouter.patientChat,
                                queryParameters: {
                                  'sessionIndex': index.toString(),
                                },
                              )
                              .then((_) => _loadHistory());
                        },
                      );
                    },
                  ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final auth = context.read<AuthProvider>();
              context.pop(); // Đóng drawer trước
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                  actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () => Navigator.pop(ctx, false),
                              borderRadius: BorderRadius.circular(8),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Hủy',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Material(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () => Navigator.pop(ctx, true),
                              borderRadius: BorderRadius.circular(8),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Đăng xuất',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await auth.logout();
                if (context.mounted) {
                  context.go(AppRouter.onboardingPath);
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String time,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
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

  void _showConsultationSuccessDialog(
    BuildContext context,
    String requestId,
    String specialty,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Success
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2FBD7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF34C759),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              // Tiêu đề
              const Text(
                'Yêu cầu đã được gửi!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Mô tả
              const Text(
                'Bác sĩ sẽ phản hồi bạn trong giây lát. Vui lòng giữ kết nối.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Khung thông tin
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'MÃ YÊU CẦU',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '#$requestId',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CHUYÊN KHOA',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFF34C759),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Yêu cầu của bạn đang được ưu tiên xử lý bởi đội ngũ chuyên gia trực ca.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Nút đóng
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
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
