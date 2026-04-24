import 'package:care_talk/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/constants/app_strings.dart';
import 'package:care_talk/core/constants/pref_const.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/providers/auth_provider.dart';
import 'package:care_talk/core/services/firebase_service.dart';

/// Màn hình Home - Điều hướng chính
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Future<Map<String, dynamic>?>? _doctorInfoFuture;
  String? _cachedSpecialty; // read from local prefs

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

  // Removed mock data

  @override
  void initState() {
    super.initState();
    _msgController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    // Load doctor info
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = context.read<AuthProvider>().currentUser?.id;
      // 1. Đọc specialty từ local trước (nhanh)
      final prefs = await SharedPreferences.getInstance();
      final localSpecialty = prefs.getString(PrefConst.doctorSpecialty);
      if (mounted) setState(() => _cachedSpecialty = localSpecialty);
      // 2. Fetch isVerified từ Firestore (cần kết nối mạng)
      if (uid != null) {
        setState(() {
          _doctorInfoFuture = FirebaseService().getDocument(
            collection: 'doctors',
            documentId: uid,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPatientTab();
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('consultations')
            .snapshots(),
        builder: (context, snapshot) {
          final currentUserId = context.watch<AuthProvider>().currentUser?.id;
          final docs = snapshot.data?.docs ?? [];

          final waitingCount = docs
              .where(
                (d) =>
                    (d.data() as Map<String, dynamic>)['status'] == 'waiting',
              )
              .length;
          final inProgressCount = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['status'] == 'accepted' &&
                data['doctorId'] == currentUserId;
          }).length;
          final completedCount = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['status'] == 'completed' &&
                data['doctorId'] == currentUserId;
          }).length;

          return SingleChildScrollView(
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
                      Text(
                        'Bác sĩ ${context.watch<AuthProvider>().currentUser?.fullName ?? ''}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bạn có $waitingCount bệnh nhân đang chờ tư vấn',
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
                        value: '$waitingCount',
                        color: AppColors.statusWaiting,
                        icon: Icons.schedule_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        label: 'Đang tư vấn',
                        value: '$inProgressCount',
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
                        value: '$completedCount',
                        color: AppColors.statusCompleted,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FutureBuilder<AggregateQuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'patient')
                            .count()
                            .get(),
                        builder: (context, userSnap) {
                          final totalPatients = userSnap.data?.count ?? 0;
                          return _buildStatCard(
                            label: 'Tổng BN',
                            value: '$totalPatients',
                            color: AppColors.primary,
                            icon: Icons.people_rounded,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('consultations')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUserId = context.watch<AuthProvider>().currentUser?.id;
        final docs = snapshot.data?.docs ?? [];

        final waitingCount = docs
            .where(
              (d) => (d.data() as Map<String, dynamic>)['status'] == 'waiting',
            )
            .length;
        final inProgressCount = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return data['status'] == 'accepted' &&
              data['doctorId'] == currentUserId;
        }).length;
        final completedCount = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return data['status'] == 'completed' &&
              data['doctorId'] == currentUserId;
        }).length;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FB),
          appBar: AppBar(
            titleSpacing: 16,
            title: Row(
              children: [
                Image.asset(AppAssets.logo, width: 40, height: 40),
                const SizedBox(width: 8),
                const Text(
                  'Danh sách bệnh nhân',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            centerTitle: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Icon thông báo
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF3A3A5C),
                  size: 24,
                ),
                onPressed: () {},
              ),

              // Icon account + dropdown
              Builder(
                builder: (btnContext) {
                  final doctorName =
                      context.watch<AuthProvider>().currentUser?.fullName ??
                      'Bác sĩ';
                  final specialty = _cachedSpecialty ?? '';
                  return GestureDetector(
                    onTap: () => _showDoctorPopupMenu(
                      btnContext,
                      doctorName: 'Bác sĩ $doctorName',
                      specialty: specialty,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12, left: 4),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Stats summary bar ─────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _buildStatusStatCard(
                      index: 0,
                      label: 'Đang chờ',
                      count: waitingCount,
                      color: const Color(0xFFFF8F00),
                      bgColor: const Color(0xFFFFF8E1),
                      icon: Icons.hourglass_top_rounded,
                    ),
                    const SizedBox(width: 10),
                    _buildStatusStatCard(
                      index: 1,
                      label: 'Đang tư vấn',
                      count: inProgressCount,
                      color: AppColors.primary,
                      bgColor: AppColors.primarySurface,
                      icon: Icons.chat_bubble_outline_rounded,
                    ),
                    const SizedBox(width: 10),
                    _buildStatusStatCard(
                      index: 2,
                      label: 'Hoàn thành',
                      count: completedCount,
                      color: const Color(0xFF43A047),
                      bgColor: const Color(0xFFE8F5E9),
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ],
                ),
              ),

              // ── Tab indicator strip ───────────────────────────────
              // Container(
              //   color: Colors.white,
              //   child: TabBar(
              //     controller: _tabController,
              //     labelColor: AppColors.primary,
              //     unselectedLabelColor: const Color(0xFF9090AA),
              //     indicatorColor: AppColors.primary,
              //     indicatorWeight: 2.5,
              //     labelStyle: const TextStyle(
              //       fontFamily: 'Inter',
              //       fontSize: 13,
              //       fontWeight: FontWeight.w600,
              //     ),
              //     unselectedLabelStyle: const TextStyle(
              //       fontFamily: 'Inter',
              //       fontSize: 13,
              //       fontWeight: FontWeight.w400,
              //     ),
              //     tabs: [
              //       Tab(text: 'Chờ ($waitingCount)'),
              //       Tab(text: 'Tư vấn ($inProgressCount)'),
              //       Tab(text: 'Xong ($completedCount)'),
              //     ],
              //   ),
              // ),

              // ── List ─────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPatientListView('waiting', docs, currentUserId),
                    _buildPatientListView('in_progress', docs, currentUserId),
                    _buildPatientListView('completed', docs, currentUserId),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusStatCard({
    required int index,
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            final isSelected = _tabController.index == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.12) : bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.5)
                      : color.withValues(alpha: 0.15),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: color.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPatientListView(
    String status,
    List<QueryDocumentSnapshot> allDocs,
    String? currentUserId,
  ) {
    var filtered = allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final docStatus = data['status'] ?? 'waiting';
      final docDoctorId = data['doctorId'] ?? '';

      String filterStatus = status == 'in_progress' ? 'accepted' : status;

      if (filterStatus == 'waiting') {
        return docStatus == 'waiting';
      } else {
        return docStatus == filterStatus && docDoctorId == currentUserId;
      }
    }).toList();

    filtered.sort((a, b) {
      final aTime =
          (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
      final bTime =
          (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    if (filtered.isEmpty) {
      return const Center(child: Text('Không có bệnh nhân nào'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final data = filtered[index].data() as Map<String, dynamic>;
        data['docId'] = filtered[index].id;
        return _PatientListCardWidget(
          consultationData: data,
          searchQuery: _searchQuery,
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        title: const Text('Cá nhân'),
        backgroundColor: Colors.white,
        elevation: 0,
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
                        Text(
                          'Bác sĩ ${context.watch<AuthProvider>().currentUser?.fullName ?? ''}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<Map<String, dynamic>?>(
                          future: _doctorInfoFuture,
                          builder: (context, snap) {
                            // Specialty: đọc từ local prefs (không cần mạng)
                            final specialty =
                                _cachedSpecialty?.isNotEmpty == true
                                ? _cachedSpecialty
                                : snap.data?['specialty'] as String?;
                            final isVerified =
                                snap.data?['isVerified'] as bool? ?? false;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  specialty != null && specialty.isNotEmpty
                                      ? 'Chuyên khoa $specialty'
                                      : 'Chưa có chuyên khoa',
                                  style: const TextStyle(
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
                                    color: isVerified
                                        ? AppColors.statusCompleted.withOpacity(
                                            0.1,
                                          )
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.radiusSm,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isVerified
                                            ? Icons.check_circle
                                            : Icons.access_time_rounded,
                                        size: 14,
                                        color: isVerified
                                            ? AppColors.statusCompleted
                                            : Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isVerified
                                            ? 'Đã xác thực'
                                            : 'Chưa xác thực',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isVerified
                                              ? AppColors.statusCompleted
                                              : Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
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
                  onTap: () => context.push(
                    '${AppRouter.doctorSupplementInfoPath}?allowBack=true',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.md),

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
                  title: 'Map Bênh viện',
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
        decoration: BoxDecoration(),
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

  void _showDoctorPopupMenu(
    BuildContext btnContext, {
    required String doctorName,
    required String specialty,
  }) {
    final RenderBox renderBox = btnContext.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: btnContext,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: RelativeRect.fromLTRB(
        offset.dx - 180,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        0,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _buildDoctorMenuHeader(doctorName, specialty),
        ),
        // PopupMenuItem(
        //   enabled: false,
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        //   child: const Divider(height: 1, color: Color(0xFFF0F0F8)),
        // ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: () {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) {
                context.push(
                  '${AppRouter.doctorSupplementInfoPath}?allowBack=true',
                );
              }
            });
          },
          child: _buildMenuAction(
            icon: Icons.person_outline_rounded,
            label: 'Hồ sơ cá nhân',
            color: AppColors.primary,
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: () {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) _showLogoutDialog();
            });
          },
          child: _buildMenuAction(
            icon: Icons.logout_rounded,
            label: 'Đăng xuất',
            color: AppColors.error,
            isLast: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorMenuHeader(String name, String specialty) {
    return Container(
      width: 220,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (specialty.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    specialty,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuAction({
    required IconData icon,
    required String label,
    required Color color,
    bool isLast = false,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF5F5FA), width: 1),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => Navigator.of(ctx).pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
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
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.go(AppRouter.roleSelectionPath);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
  }
}

class _PatientListCardWidget extends StatelessWidget {
  final Map<String, dynamic> consultationData;
  final String searchQuery;

  const _PatientListCardWidget({
    required this.consultationData,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final patientId = consultationData['patientId'] ?? '';
    final symptom = consultationData['specialty'] ?? 'Triệu chứng chưa rõ';
    final status = consultationData['status'] ?? 'waiting';
    final createdAt = consultationData['createdAt'] as Timestamp?;

    final timeStr = createdAt != null
        ? '${createdAt.toDate().hour.toString().padLeft(2, '0')}h${createdAt.toDate().minute.toString().padLeft(2, '0')} hôm nay'
        : '--:--';

    return FutureBuilder<DocumentSnapshot?>(
      future: patientId.isNotEmpty
          ? FirebaseFirestore.instance.collection('users').doc(patientId).get()
          : Future.value(null),
      builder: (context, snapshot) {
        String name = 'Đang tải...';
        String phone = '---';
        String dobYear = '';
        String patientCode = '';

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          name = userData?['full_name'] ?? 'Bệnh nhân';
          phone = userData?['phone'] ?? 'Không có SĐT';
          final rawDob = userData?['dob'] ?? userData?['birthday'] ?? '';
          if (rawDob is String && rawDob.length >= 4) {
            dobYear = rawDob.substring(0, 4);
          }
          final rawCode = userData?['patientCode'] ?? '';
          patientCode = rawCode.isNotEmpty
              ? rawCode
              : 'P${patientId.substring(0, patientId.length >= 4 ? 4 : patientId.length).toUpperCase()}';
        }

        // Search logic
        if (searchQuery.isNotEmpty &&
            snapshot.connectionState == ConnectionState.done) {
          if (!name.toLowerCase().contains(searchQuery.toLowerCase()) &&
              !phone.contains(searchQuery)) {
            return const SizedBox.shrink();
          }
        }

        // --- Severity badge ---
        final severity = (consultationData['severity'] ?? '')
            .toString()
            .toLowerCase();
        Widget? severityBadge;
        if (severity.contains('nặng') || severity == 'nang') {
          severityBadge = const _SeverityBadge(
            label: 'NẶNG',
            color: Color(0xFFE53935),
          );
        } else if (severity.contains('trung')) {
          severityBadge = const _SeverityBadge(
            label: 'TB',
            color: Color(0xFFFB8C00),
          );
        } else if (severity.contains('nhẹ') || severity == 'nhe') {
          severityBadge = const _SeverityBadge(
            label: 'NHẸ',
            color: Color(0xFF43A047),
          );
        }

        // --- Footer status ---
        String footerLabel = 'Chờ tư vấn';
        Color footerDotColor = const Color(0xFFFFB347);
        if (status == 'accepted') {
          footerLabel = 'Đang tư vấn';
          footerDotColor = AppColors.primary;
        } else if (status == 'completed') {
          footerLabel = 'Đã hoàn thành';
          footerDotColor = const Color(0xFF43A047);
        }

        final subText = dobYear.isNotEmpty
            ? 'Năm sinh: $dobYear  •  ID: #$patientCode'
            : 'SĐT: $phone';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEEEEF5), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top info ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Tên + severity badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            snapshot.connectionState == ConnectionState.waiting
                                ? 'Đang tải...'
                                : name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (severityBadge != null) ...[
                          const SizedBox(width: 8),
                          severityBadge,
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Row 2: năm sinh / SĐT  |  clock + time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subText,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
                              color: Color(0xFF9090AA),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Color(0xFF9090AA),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            color: Color(0xFF9090AA),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 3: Symptom box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1.5),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Color(0xFFE0A800),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Triệu chứng: ',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3A3A5C),
                                    ),
                                  ),
                                  TextSpan(
                                    text: symptom,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF3A3A5C),
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Divider ───────────────────────────────────────────
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F8)),

              // ── Footer ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                child: Row(
                  children: [
                    // Status dot + label
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: footerDotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      footerLabel,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: footerDotColor,
                      ),
                    ),
                    const Spacer(),
                    // "Xem chi tiết" outlined
                    OutlinedButton(
                      onPressed: () {
                        final docId = consultationData['docId'];
                        if (docId != null && docId.toString().isNotEmpty) {
                          context.pushNamed(
                            AppRouter.consultationDetail,
                            queryParameters: {'id': docId.toString()},
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3A3A5C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // "Tư vấn" filled
                    ElevatedButton(
                      onPressed: () {
                        final docId = consultationData['docId'];
                        if (docId != null && docId.toString().isNotEmpty) {
                          context.push(
                            '${AppRouter.chatPath}?consultationId=$docId',
                          );
                        } else {
                          context.push(AppRouter.chatPath);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 7,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Tư vấn',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Badge mức độ bệnh (NẶNG / TB / NHẸ)
class _SeverityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SeverityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
