import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/router/app_router.dart';

class ConsultationDetailScreen extends StatefulWidget {
  final String consultationId;

  const ConsultationDetailScreen({super.key, required this.consultationId});

  @override
  State<ConsultationDetailScreen> createState() =>
      _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends State<ConsultationDetailScreen> {
  Map<String, dynamic>? _consultation;
  Map<String, dynamic>? _patient;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final consultDoc = await FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.consultationId)
          .get();

      if (!consultDoc.exists) {
        setState(() => _loading = false);
        return;
      }

      final data = consultDoc.data()!;
      final patientId = data['patientId'] as String? ?? '';

      Map<String, dynamic>? patientData;
      if (patientId.isNotEmpty) {
        final patientDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(patientId)
            .get();
        if (patientDoc.exists) {
          patientData = patientDoc.data();
        }
      }

      setState(() {
        _consultation = data;
        _patient = patientData;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_consultation == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          title: const Text('Chi tiết ca bệnh'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: const Center(child: Text('Không tìm thấy thông tin ca bệnh')),
      );
    }

    final c = _consultation!;
    final p = _patient ?? {};

    final status = c['status'] as String? ?? 'waiting';
    final specialty = c['specialty'] as String? ?? 'Chưa rõ';
    final symptoms = c['symptoms'] as String? ??
        c['symptomDescription'] as String? ??
        specialty;
    final severityRaw =
        (c['severity'] as String? ?? '').toLowerCase();
    final createdAt = c['createdAt'] as Timestamp?;
    final docId = widget.consultationId;

    // Patient info
    final name = p['full_name'] as String? ?? 'Bệnh nhân';
    final phone = p['phone'] as String? ?? '';
    final email = p['email'] as String? ?? '';
    final address = p['address'] as String? ?? '';
    final rawDob = p['dob'] ?? p['birthday'] ?? '';
    int? birthYear;
    if (rawDob is String && rawDob.length >= 4) {
      birthYear = int.tryParse(rawDob.substring(0, 4));
    }
    final age = birthYear != null ? DateTime.now().year - birthYear : null;
    final patientCode = (p['patientCode'] as String?)?.isNotEmpty == true
        ? p['patientCode']
        : docId.substring(0, docId.length >= 6 ? 6 : docId.length).toUpperCase();

    // Status UI
    String statusLabel;
    Color statusColor;
    Color statusBg;
    switch (status) {
      case 'accepted':
        statusLabel = 'ĐANG TƯ VẤN';
        statusColor = AppColors.primary;
        statusBg = AppColors.primarySurface;
        break;
      case 'completed':
        statusLabel = 'HOÀN THÀNH';
        statusColor = const Color(0xFF43A047);
        statusBg = const Color(0xFFE8F5E9);
        break;
      default:
        statusLabel = 'CHỜ TƯ VẤN';
        statusColor = const Color(0xFFFF8F00);
        statusBg = const Color(0xFFFFF8E1);
    }

    // Severity UI
    String severityLabel = '';
    Color severityColor = Colors.grey;
    Color severityBg = Colors.grey.shade100;
    if (severityRaw.contains('cao') || severityRaw.contains('nặng') || severityRaw == 'nang') {
      severityLabel = 'Cao';
      severityColor = const Color(0xFFE53935);
      severityBg = const Color(0xFFFFEBEE);
    } else if (severityRaw.contains('trung') || severityRaw.contains('tb')) {
      severityLabel = 'Trung bình';
      severityColor = const Color(0xFFFB8C00);
      severityBg = const Color(0xFFFFF3E0);
    } else if (severityRaw.contains('thấp') || severityRaw.contains('nhẹ') || severityRaw == 'nhe') {
      severityLabel = 'Thấp';
      severityColor = const Color(0xFF43A047);
      severityBg = const Color(0xFFE8F5E9);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: _buildAppBar(context, patientCode, statusLabel, statusColor, statusBg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Patient Info Card ──────────────────────────────────
            _buildPatientCard(
              name: name,
              patientCode: patientCode,
              birthYear: birthYear,
              age: age,
              phone: phone,
              email: email,
              address: address,
            ),
            const SizedBox(height: 16),

            // ── Trạng thái hiện tại ────────────────────────────────
            _buildStatusCard(context, status, docId),
            const SizedBox(height: 16),

            // ── Triệu chứng ────────────────────────────────────────
            _buildSymptomsCard(
              symptoms: symptoms,
              createdAt: createdAt,
              severityLabel: severityLabel,
              severityColor: severityColor,
              severityBg: severityBg,
            ),
          ],
        ),
      ),

      // ── Bottom action buttons ─────────────────────────────────────
      bottomNavigationBar: _buildBottomBar(context, status, docId),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    String patientCode,
    String statusLabel,
    Color statusColor,
    Color statusBg,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết ca bệnh',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Mã số: APK-${patientCode.toUpperCase()}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textHint,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: statusColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Patient Info Card ──────────────────────────────────────────────
  Widget _buildPatientCard({
    required String name,
    required String patientCode,
    required int? birthYear,
    required int? age,
    required String phone,
    required String email,
    required String address,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 38,
              color: Color(0xFFB0BEC5),
            ),
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${patientCode.toUpperCase()}-VN',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF0F0F8)),
          const SizedBox(height: 12),

          // Info rows
          if (birthYear != null)
            _infoRow(
              icon: Icons.cake_outlined,
              text: 'Năm sinh: $birthYear${age != null ? ' ($age tuổi)' : ''}',
            ),
          if (phone.isNotEmpty)
            _infoRow(icon: Icons.phone_outlined, text: phone),
          if (email.isNotEmpty)
            _infoRow(icon: Icons.email_outlined, text: email),
          if (address.isNotEmpty)
            _infoRow(icon: Icons.location_on_outlined, text: address),

          // Fallback nếu không có thông tin gì
          if (birthYear == null && phone.isEmpty && email.isEmpty && address.isEmpty)
            _infoRow(
              icon: Icons.info_outline,
              text: 'Chưa có thông tin bổ sung',
              color: AppColors.textHint,
            ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status Card ────────────────────────────────────────────────────
  Widget _buildStatusCard(
      BuildContext context, String status, String docId) {
    String description;
    IconData icon;
    Color accentColor;

    switch (status) {
      case 'accepted':
        description =
            'Bạn đang trong phiên tư vấn với bệnh nhân này. Tiếp tục cuộc trò chuyện để hoàn tất ca bệnh.';
        icon = Icons.chat_bubble_outline_rounded;
        accentColor = AppColors.primary;
        break;
      case 'completed':
        description =
            'Ca tư vấn này đã kết thúc. Bạn có thể xem lại lịch sử hội thoại bên dưới.';
        icon = Icons.check_circle_outline_rounded;
        accentColor = const Color(0xFF43A047);
        break;
      default:
        description =
            'Bệnh nhân đang chờ được tư vấn trực tuyến. Vui lòng xem kỹ triệu chứng trước khi bắt đầu.';
        icon = Icons.hourglass_top_rounded;
        accentColor = const Color(0xFFFF8F00);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.85),
            accentColor.withValues(alpha: 0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Trạng thái hiện tại',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          // Nút hành động
          if (status != 'completed')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (status == 'waiting') {
                    // Nhận ca + chuyển sang chat
                    await FirebaseFirestore.instance
                        .collection('consultations')
                        .doc(docId)
                        .update({'status': 'accepted'});
                  }
                  if (context.mounted) {
                    context.push(
                      '${AppRouter.chatPath}?consultationId=$docId',
                    );
                  }
                },
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: Text(
                  status == 'waiting' ? 'Bắt đầu tư vấn' : 'Tiếp tục tư vấn',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: accentColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Symptoms Card ──────────────────────────────────────────────────
  Widget _buildSymptomsCard({
    required String symptoms,
    required Timestamp? createdAt,
    required String severityLabel,
    required Color severityColor,
    required Color severityBg,
  }) {
    final timeStr = createdAt != null
        ? _formatDate(createdAt.toDate())
        : 'Không rõ';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE0A800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'TRIỆU CHỨNG HIỆN TẠI',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3A3A5C),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Symptom text box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFE0B2),
                width: 1,
              ),
            ),
            child: Text(
              symptoms,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF3A3A5C),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Thời gian ghi nhận
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 15, color: AppColors.textHint),
              const SizedBox(width: 5),
              Text(
                'Ghi nhận: $timeStr',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),

          // Severity
          if (severityLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF0F0F8)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.trending_up_rounded,
                    size: 18, color: severityColor),
                const SizedBox(width: 8),
                const Text(
                  'Mức độ ưu tiên: ',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A3A5C),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: severityColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    severityLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Bottom Bar ─────────────────────────────────────────────────────
  Widget _buildBottomBar(
      BuildContext context, String status, String docId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nút phụ
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 15),
              label: const Text('Quay lại'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: BorderSide(color: Colors.grey.shade300),
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút chính
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (status == 'waiting') {
                  await FirebaseFirestore.instance
                      .collection('consultations')
                      .doc(docId)
                      .update({'status': 'accepted'});
                }
                if (context.mounted) {
                  context.push(
                    '${AppRouter.chatPath}?consultationId=$docId',
                  );
                }
              },
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: Text(
                status == 'completed'
                    ? 'Xem hội thoại'
                    : status == 'accepted'
                        ? 'Tiếp tục tư vấn'
                        : 'Bắt đầu tư vấn',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m - ${dt.day}/${dt.month}/${dt.year}';
  }
}
