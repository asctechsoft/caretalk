import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/router/app_router.dart';

/// Màn hình Home - Điều hướng chính
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // Biến cho tab Chat AI
  late TextEditingController _msgController;
  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text':
          'Chào Bác sĩ, tôi là trợ lý AI chuyên về y khoa. Tôi có thể hỗ trợ gì cho bác sĩ hôm nay?',
      'type': 'text',
    },
  ];
  bool _isBotTyping = false;

  // Biến cho tab Bệnh nhân
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data cho danh sách bệnh nhân
  final List<Map<String, dynamic>> _patients = [
    {
      'id': '1',
      'name': 'Nguyễn Văn An',
      'phone': '0912345678',
      'symptom': 'Đau đầu, chóng mặt',
      'status': 'waiting',
      'time': '10:30',
    },
    {
      'id': '2',
      'name': 'Trần Thị Bình',
      'phone': '0987654321',
      'symptom': 'Ho kéo dài, sốt nhẹ',
      'status': 'waiting',
      'time': '10:45',
    },
    {
      'id': '3',
      'name': 'Lê Hoàng Cường',
      'phone': '0909090909',
      'symptom': 'Đau bụng, buồn nôn',
      'status': 'in_progress',
      'time': '09:15',
    },
    {
      'id': '4',
      'name': 'Phạm Minh Đức',
      'phone': '0933333333',
      'symptom': 'Mất ngủ, stress',
      'status': 'completed',
      'time': '08:00',
    },
    {
      'id': '5',
      'name': 'Hoàng Thị Em',
      'phone': '0944444444',
      'symptom': 'Đau răng, sưng nướu',
      'status': 'waiting',
      'time': '11:00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _msgController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _msgController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterPatients(String status) {
    return _patients
        .where(
          (p) =>
              p['status'] == status &&
              (_searchQuery.isEmpty ||
                  p['name'].toLowerCase().contains(_searchQuery.toLowerCase())),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          _buildChatTab(),
          _buildPatientTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Bệnh nhân',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dashboard Tab ─────────────────────────────────────────────────
  Widget _buildDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareTalk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào! 👋',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bác sĩ Nguyễn Văn A',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bạn có 5 bệnh nhân đang chờ tư vấn',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick actions
            const Text(
              'Thao tác nhanh',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.chat_rounded,
                    label: 'Chat mới',
                    color: AppColors.primary,
                    onTap: () => context.push(AppRouter.chatPath),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.person_add_rounded,
                    label: 'Thêm BN',
                    color: AppColors.accent,
                    onTap: () => context.push(AppRouter.patientInfoPath),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.list_alt_rounded,
                    label: 'DS chờ',
                    color: AppColors.warning,
                    onTap: () => context.push(AppRouter.patientListPath),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats
            const Text(
              'Thống kê hôm nay',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Đang chờ',
                    value: '5',
                    color: AppColors.statusWaiting,
                    icon: Icons.schedule_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: 'Đang tư vấn',
                    value: '2',
                    color: AppColors.statusInProgress,
                    icon: Icons.chat_bubble_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Hoàn thành',
                    value: '12',
                    color: AppColors.statusCompleted,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: 'Tổng BN',
                    value: '19',
                    color: AppColors.primary,
                    icon: Icons.people_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md,
          vertical: AppDimens.lg,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Placeholder Tabs ──────────────────────────────────────────────
  Widget _buildChatTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        title: const Text('Trợ lý AI cho Bác sĩ'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.length <= 1
                ? _buildDoctorWelcomeScene()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isBotTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isBotTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildDoctorWelcomeScene() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Trợ lý chuyên môn AI',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tôi có thể giúp bác sĩ tra cứu thông tin thuốc, phân tích triệu chứng hoặc tóm tắt bệnh án.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildDoctorTipCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.orange, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Mẹo: Thử hỏi "Liều dùng của thuốc Paracetamol cho trẻ 10kg" hoặc "Dấu hiệu của suy tim cấp".',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isBot = msg['isBot'] ?? false;
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isBot ? 4 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 4),
          ),
          boxShadow: isBot
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          msg['text'] ?? '',
          style: TextStyle(
            color: isBot ? Colors.black87 : Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'AI đang phản hồi...',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 24),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _msgController,
                decoration: const InputDecoration(
                  hintText: 'Nhập câu hỏi chuyên môn...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendDoctorMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendDoctorMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isBot': false, 'text': text});
      _msgController.clear();
      _isBotTyping = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isBotTyping = false;
        _messages.add({
          'isBot': true,
          'text':
              'Theo cơ sở dữ liệu y khoa, về vấn đề "$text", bác sĩ có thể tham khảo phác đồ điều trị của Bộ Y Tế hoặc các nghiên cứu lâm sàng mới nhất. Tôi có thể tìm thêm thông tin chi tiết nếu bác sĩ cần.',
        });
      });
    });
  }

  Widget _buildPatientTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        title: const Text('Danh sách bệnh nhân'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add_rounded,
              color: AppColors.primary,
            ),
            onPressed: () => context.push(AppRouter.patientInfoPath),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Đang chờ (${_filterPatients('waiting').length})'),
            Tab(text: 'Đang tư vấn (${_filterPatients('in_progress').length})'),
            Tab(text: 'Hoàn thành (${_filterPatients('completed').length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm bệnh nhân...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientListView('waiting'),
                _buildPatientListView('in_progress'),
                _buildPatientListView('completed'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.patientInfoPath),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildPatientListView(String status) {
    final list = _filterPatients(status);
    if (list.isEmpty) {
      return const Center(child: Text('Không có bệnh nhân nào'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildPatientListCard(list[index]),
    );
  }

  Widget _buildPatientListCard(Map<String, dynamic> patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              patient['name'].substring(0, 2).toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      patient['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _buildStatusStepBadge(patient['status']),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  patient['symptom'],
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient['phone'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
            ),
            onPressed: () => context.push(AppRouter.chatPath),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepBadge(String status) {
    String text = '';
    Color color = Colors.grey;
    switch (status) {
      case 'waiting':
        text = 'Đang chờ';
        color = Colors.orange;
        break;
      case 'in_progress':
        text = 'Đang tư vấn';
        color = Colors.blue;
        break;
      case 'completed':
        text = 'Đã hoàn thành';
        color = Colors.green;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        title: const Text('Cá nhân'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          children: [
            // Thông tin Bác sĩ
            Container(
              padding: const EdgeInsets.all(AppDimens.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: const NetworkImage(
                      'https://ui-avatars.com/api/?name=Doctor&background=random',
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bác sĩ Nguyễn Văn A',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Chuyên khoa Tim Mạch',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.statusCompleted.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSm,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: AppColors.statusCompleted,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Đã xác thực',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.statusCompleted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.xl),

            // Nhóm Cài đặt
            _buildProfileSection(
              title: 'Cài đặt chung',
              items: [
                _buildProfileItem(
                  icon: Icons.person_outline,
                  title: 'Hồ sơ cá nhân',
                  onTap: () {},
                ),
                _buildProfileItem(
                  icon: Icons.notifications_none,
                  title: 'Thông báo',
                  onTap: () {},
                ),
                _buildProfileItem(
                  icon: Icons.lock_outline,
                  title: 'Đổi mật khẩu',
                  showBorder: false,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppDimens.lg),

            // Nhóm Hỗ trợ
            _buildProfileSection(
              title: 'Hỗ trợ',
              items: [
                _buildProfileItem(
                  icon: Icons.help_outline,
                  title: 'Trung tâm trợ giúp',
                  onTap: () {},
                ),
                _buildProfileItem(
                  icon: Icons.article_outlined,
                  title: 'Điều khoản sử dụng',
                  onTap: () {},
                ),
                _buildProfileItem(
                  icon: Icons.info_outline,
                  title: 'Về ứng dụng',
                  showBorder: false,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xl),

            // Nút Đăng xuất
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showBorder = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRouter.roleSelectionPath);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
