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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          // _buildChatTab(),
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
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.chat_rounded),
            //   label: 'Chat',
            // ),
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
                Tab(text: 'Đang chờ ($waitingCount)'),
                Tab(text: 'Đang tư vấn ($inProgressCount)'),
                Tab(text: 'Hoàn thành ($completedCount)'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.grey.shade200),
              //     ),
              //     child: TextField(
              //       controller: _searchController,
              //       onChanged: (value) => setState(() => _searchQuery = value),
              //       decoration: const InputDecoration(
              //         hintText: 'Tìm kiếm bệnh nhân...',
              //         border: InputBorder.none,
              //         icon: Icon(Icons.search, size: 20),
              //       ),
              //     ),
              //   ),
              // ),
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
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(AppRouter.patientInfoPath),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        );
      },
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

  Widget _buildStatusStepBadge(String status) {
    String text = '';
    Color color = Colors.grey;
    switch (status) {
      case 'waiting':
        text = 'Đang chờ';
        color = Colors.orange;
        break;
      case 'accepted':
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientId = consultationData['patientId'] ?? '';
    final symptom = consultationData['specialty'] ?? 'Triệu chứng chưa rõ';
    final status = consultationData['status'] ?? 'waiting';
    final createdAt = consultationData['createdAt'] as Timestamp?;

    // Import package intl để dùng nếu chưa có, tạm dùng string cơ bản
    final timeStr = createdAt != null
        ? '${createdAt.toDate().hour.toString().padLeft(2, '0')}:${createdAt.toDate().minute.toString().padLeft(2, '0')} ${createdAt.toDate().day}/${createdAt.toDate().month}'
        : '--:--';

    return FutureBuilder<DocumentSnapshot?>(
      future: patientId.isNotEmpty
          ? FirebaseFirestore.instance.collection('users').doc(patientId).get()
          : Future.value(null),
      builder: (context, snapshot) {
        String name = 'Đang tải...';
        String phone = '---';
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          name = userData?['full_name'] ?? 'Bệnh nhân';
          phone = userData?['phone'] ?? 'Không có SĐT';
        }

        // Search logic
        if (searchQuery.isNotEmpty &&
            snapshot.connectionState == ConnectionState.done) {
          if (!name.toLowerCase().contains(searchQuery.toLowerCase()) &&
              !phone.contains(searchQuery)) {
            return const SizedBox.shrink();
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(
            left: 16,
            right: 0,
            top: 16,
            bottom: 16,
          ),
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
                  name.isNotEmpty
                      ? name
                            .substring(0, name.length >= 2 ? 2 : 1)
                            .toUpperCase()
                      : 'BN',
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
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusStepBadge(status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      symptom,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                          phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () => context.push(AppRouter.chatPath),
                iconSize: 16,
              ),
              // if (status == 'waiting')
              //   IconButton(
              //     icon: const Icon(
              //       Icons.check_circle_outline,
              //       color: Colors.green,
              //     ),
              //     tooltip: 'Nhận tư vấn',
              //     onPressed: () {
              //       final docId = consultationData['docId'];
              //       if (docId != null) {
              //         final currentUserId = context
              //             .read<AuthProvider>()
              //             .currentUser
              //             ?.id;
              //         FirebaseFirestore.instance
              //             .collection('consultations')
              //             .doc(docId)
              //             .update({
              //               'status': 'accepted',
              //               'doctorId': currentUserId,
              //             });
              //       }
              //     },
              //   )
              // else
              //   IconButton(
              //     icon: const Icon(
              //       Icons.chat_bubble_outline,
              //       color: AppColors.primary,
              //     ),
              //     onPressed: () => context.push(AppRouter.chatPath),
              //   ),
            ],
          ),
        );
      },
    );
  }
}
