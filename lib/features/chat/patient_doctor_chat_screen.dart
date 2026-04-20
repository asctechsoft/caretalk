import 'package:flutter/material.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:go_router/go_router.dart';

class PatientDoctorChatScreen extends StatefulWidget {
  const PatientDoctorChatScreen({super.key});

  @override
  State<PatientDoctorChatScreen> createState() => _PatientDoctorChatScreenState();
}

class _PatientDoctorChatScreenState extends State<PatientDoctorChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatusBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.lg),
              children: [
                _buildDateSeparator('Hôm nay, 14 tháng 10'),
                _buildDoctorMessage('Chào bạn, kết quả xét nghiệm máu của bạn cho thấy các chỉ số đường huyết đã ổn định hơn so với tháng trước.', '10:46 AM'),
                _buildPatientMessage('Cảm ơn bác sĩ. Tôi vẫn duy trì chế độ ăn kiêng và tập thể dục 30 phút mỗi ngày ạ.', '10:48 AM'),
                _buildDoctorMessage('Tốt lắm. Đây là phác đồ điều trị tiếp theo cho 2 tuần tới. Bạn hãy theo dõi sát sao nhé.', '10:49 AM', hasImage: true),
                const SizedBox(height: 16),
                _buildConsultationCompletedBox(),
              ],
            ),
          ),
          _buildClosedInputSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=BS+Minh&background=random'),
            radius: 18,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BS. Minh',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'CA TƯ VẤN #MS-8821',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            'CA TƯ VẤN ĐÃ KẾT THÚC',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          date,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorMessage(String text, String time, {bool hasImage = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=BS+Minh&background=random'),
            radius: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      if (hasImage) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=600&auto=format&fit=crop', // Stethoscope/medical image
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildPatientMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCompletedBox() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F9F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4EEDC)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFDDEEE3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bác sĩ đã hoàn thành tư vấn.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn vẫn có thể xem lại lịch sử tư vấn và đơn thuốc được kê khai.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Xem kết luận'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedInputSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Phần chat đã đóng',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded, color: Colors.grey.shade400, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'CA TƯ VẤN KẾT THÚC LÚC 09:45',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
