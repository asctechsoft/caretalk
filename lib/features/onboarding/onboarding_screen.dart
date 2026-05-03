import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:care_talk/core/services/storage_service.dart';

// ─── Model ──────────────────────────────────────────────────────────────────
class _SlideData {
  final String tag;
  final String title;
  final String description;
  final String detail;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradient;

  const _SlideData({
    required this.tag,
    required this.title,
    required this.description,
    required this.detail,
    required this.icon,
    required this.accentColor,
    required this.gradient,
  });
}

// ─── Slide Data (15 trang) ───────────────────────────────────────────────────
const List<_SlideData> _slides = [
  // 1. Welcome
  _SlideData(
    tag: 'GIỚI THIỆU ỨNG DỤNG CARETALK',
    title: 'Chào mừng đến với\nCareTalk!',
    description: 'CareTalk là ứng dụng tư vấn sức khỏe ban đầu, kết nối bệnh nhân với bác sĩ tình nguyện thông qua nền tảng chat thông minh. Được xây dựng với sứ mệnh giúp mọi người tiếp cận dịch vụ y tế một cách nhanh chóng, tiện lợi và không tốn chi phí.',
    detail: '✦ Kết nối   ✦ Lắng nghe   ✦ Chăm sóc',
    icon: Icons.favorite_rounded,
    accentColor: Color(0xFF2B6CB0),
    gradient: [Color(0xFF1A4971), Color(0xFF2B6CB0)],
  ),
  // 2. Problem statement
  _SlideData(
    tag: 'VẤN ĐỀ CẦN GIẢI QUYẾT TRONG Y TẾ',
    title: 'Rào cản tiếp cận\ndịch vụ y tế',
    description: 'Hàng triệu người không được tư vấn y tế kịp thời vì thiếu bác sĩ, chi phí cao hoặc khoảng cách địa lý. Đặc biệt ở vùng nông thôn và ngoài giờ hành chính, bệnh nhân không biết hỏi ai khi có triệu chứng bất thường.',
    detail: 'CareTalk ra đời để xóa bỏ rào cản này',
    icon: Icons.personal_injury_rounded,
    accentColor: Color(0xFFE53E3E),
    gradient: [Color(0xFFC53030), Color(0xFFE53E3E)],
  ),
  // 3. Solution
  _SlideData(
    tag: 'GIẢI PHÁP TƯ VẤN SỨC KHỎE TRỰC TUYẾN',
    title: 'Tư vấn sức khỏe\nmọi lúc, mọi nơi',
    description: 'CareTalk cho phép bệnh nhân gửi câu hỏi sức khỏe và nhận tư vấn từ bác sĩ tình nguyện ngay trên điện thoại. Không cần đặt lịch, không cần đến phòng khám — chỉ cần mở ứng dụng và bắt đầu.',
    detail: 'Hoạt động 24/7 · Miễn phí · Dễ sử dụng',
    icon: Icons.lightbulb_rounded,
    accentColor: Color(0xFFD69E2E),
    gradient: [Color(0xFFC05621), Color(0xFFD69E2E)],
  ),
  // 4. AI Chatbot
  _SlideData(
    tag: 'TRỢ LÝ AI CHUYÊN VỀ Y KHOA',
    title: 'Chatbot AI y khoa\nphản hồi tức thì',
    description: 'Trợ lý AI của CareTalk được tích hợp kiến thức y khoa chuyên sâu, giúp bệnh nhân nhận tư vấn sức khỏe sơ bộ ngay lập tức — ngay cả khi chưa có bác sĩ trực. AI hỗ trợ phân tích triệu chứng, gợi ý hướng xử lý và nhắc nhở khi cần đến cơ sở y tế.',
    detail: 'Phản hồi < 3 giây · Hoạt động 24/7 · Không cần internet tốc độ cao',
    icon: Icons.smart_toy_rounded,
    accentColor: Color(0xFF38B2AC),
    gradient: [Color(0xFF285E61), Color(0xFF38B2AC)],
  ),
  // 5. Symptom assessment
  _SlideData(
    tag: 'ĐÁNH GIÁ & PHÂN LOẠI TRIỆU CHỨNG',
    title: 'Phân tích và đánh giá\nmức độ triệu chứng',
    description: 'Sau khi mô tả triệu chứng, hệ thống CareTalk tự động phân loại mức độ: Nhẹ (có thể tự chăm sóc), Trung bình (cần theo dõi thêm) hoặc Nghiêm trọng (cần đến cơ sở y tế ngay). Từ đó đưa ra hướng dẫn cụ thể, phù hợp với từng trường hợp.',
    detail: 'Mức độ Nhẹ  ·  Trung bình  ·  Nghiêm trọng',
    icon: Icons.medical_information_rounded,
    accentColor: Color(0xFF805AD5),
    gradient: [Color(0xFF553C9A), Color(0xFF805AD5)],
  ),
  // 6. Doctor connection
  _SlideData(
    tag: 'KẾT NỐI VỚI BÁC SĨ TÌNH NGUYỆN',
    title: 'Kết nối trực tiếp\nvới bác sĩ tình nguyện',
    description: 'Khi AI đánh giá bệnh nhân cần tư vấn chuyên sâu hơn, CareTalk tự động chuyển yêu cầu đến đội ngũ bác sĩ tình nguyện đang trực. Bác sĩ sẽ xem xét thông tin và chủ động liên hệ để hỗ trợ bệnh nhân kịp thời.',
    detail: 'Bác sĩ được xác minh · Đa chuyên khoa · Phản hồi nhanh',
    icon: Icons.people_alt_rounded,
    accentColor: Color(0xFF2B6CB0),
    gradient: [Color(0xFF2C5282), Color(0xFF4299E1)],
  ),
  // 7. Patient registration
  _SlideData(
    tag: 'QUẢN LÝ HỒ SƠ THÔNG TIN BỆNH NHÂN',
    title: 'Hồ sơ bệnh nhân\nđầy đủ và chính xác',
    description: 'Bệnh nhân điền thông tin cá nhân như họ tên, ngày sinh, giới tính, địa chỉ cùng mô tả triệu chứng và tiền sử bệnh. Thông tin được lưu trữ an toàn và chia sẻ với bác sĩ để hỗ trợ tư vấn chính xác nhất có thể.',
    detail: 'Họ tên · Ngày sinh · Địa chỉ · Triệu chứng · Tiền sử bệnh · Ghi chú',
    icon: Icons.assignment_ind_rounded,
    accentColor: Color(0xFF38A169),
    gradient: [Color(0xFF276749), Color(0xFF48BB78)],
  ),
  // 8. Real-time chat
  _SlideData(
    tag: 'NHẮN TIN REAL-TIME VỚI BÁC SĨ',
    title: 'Trò chuyện trực tiếp\nvới bác sĩ theo thời gian thực',
    description: 'Khi được bác sĩ chấp nhận tư vấn, bệnh nhân và bác sĩ có thể trò chuyện trực tiếp qua màn hình chat. Tin nhắn được gửi và nhận theo thời gian thực nhờ Firebase — nhanh, rõ ràng và bảo mật hoàn toàn.',
    detail: 'Đồng bộ tức thì · Lịch sử chat được lưu · Bảo mật đầu cuối',
    icon: Icons.chat_bubble_rounded,
    accentColor: Color(0xFF2B6CB0),
    gradient: [Color(0xFF2B6CB0), Color(0xFF63B3ED)],
  ),
  // 9. Doctor dashboard
  _SlideData(
    tag: 'BẢNG ĐIỀU KHIỂN DÀNH RIÊNG CHO BÁC SĨ',
    title: 'Dashboard bác sĩ\ntheo dõi mọi ca tư vấn',
    description: 'Bác sĩ có giao diện quản lý riêng, hiển thị toàn bộ danh sách bệnh nhân theo từng trạng thái. Thống kê cập nhật theo thời gian thực giúp bác sĩ nắm bắt nhanh số ca đang chờ, đang xử lý và đã hoàn thành trong ngày.',
    detail: '⏳ Đang chờ   💬 Đang tư vấn   ✅ Hoàn thành',
    icon: Icons.dashboard_rounded,
    accentColor: Color(0xFF744210),
    gradient: [Color(0xFF744210), Color(0xFFD69E2E)],
  ),
  // 10. Consultation management
  _SlideData(
    tag: 'QUẢN LÝ QUY TRÌNH TƯ VẤN KHÉP KÍN',
    title: 'Quy trình tư vấn\nkhép kín từ A đến Z',
    description: 'Bác sĩ nhận yêu cầu → xem xét hồ sơ bệnh nhân → bắt đầu tư vấn qua chat → đánh dấu hoàn thành. Toàn bộ quy trình được quản lý tập trung, rõ ràng, giúp bác sĩ tình nguyện làm việc hiệu quả và không bỏ sót bất kỳ trường hợp nào.',
    detail: 'Nhận ca  →  Xem hồ sơ  →  Tư vấn  →  Hoàn thành',
    icon: Icons.task_alt_rounded,
    accentColor: Color(0xFF285E61),
    gradient: [Color(0xFF285E61), Color(0xFF38B2AC)],
  ),
  // 11. Firebase backend
  _SlideData(
    tag: 'CÔNG NGHỆ NỀN TẢNG FIREBASE & FLUTTER',
    title: 'Xây dựng trên nền\nFirebase & Flutter',
    description: 'CareTalk sử dụng Flutter để tạo giao diện đa nền tảng mượt mà, kết hợp Firebase Authentication để xác thực người dùng, Firestore để đồng bộ dữ liệu real-time và Firebase Hosting để triển khai ứng dụng web nhanh chóng, ổn định.',
    detail: 'Flutter · Firebase Auth · Firestore · Firebase Hosting · Cloud Functions',
    icon: Icons.cloud_done_rounded,
    accentColor: Color(0xFF2B6CB0),
    gradient: [Color(0xFF1A4971), Color(0xFF3182CE)],
  ),
  // 12. Cross-platform
  _SlideData(
    tag: 'HỖ TRỢ ĐA NỀN TẢNG – MỌI THIẾT BỊ',
    title: 'Một ứng dụng\nchạy trên mọi thiết bị',
    description: 'Nhờ Flutter, CareTalk hoạt động hoàn hảo trên cả điện thoại Android, iPhone và trình duyệt Web mà không cần phát triển riêng lẻ từng nền tảng. Người dùng có thể truy cập từ bất kỳ thiết bị nào mà không mất trải nghiệm sử dụng.',
    detail: '📱 Android  ·  🍎 iOS  ·  🌐 Web Browser',
    icon: Icons.devices_rounded,
    accentColor: Color(0xFF553C9A),
    gradient: [Color(0xFF44337A), Color(0xFF9F7AEA)],
  ),
  // 13. Security & privacy
  _SlideData(
    tag: 'BẢO MẬT & BẢO VỆ QUYỀN RIÊNG TƯ',
    title: 'Dữ liệu của bạn\nluôn được bảo vệ',
    description: 'CareTalk áp dụng xác thực bằng Firebase ID Token, truyền tải dữ liệu qua HTTPS và phân quyền chặt chẽ trong Firestore Security Rules. Thông tin sức khỏe cá nhân và nội dung cuộc trò chuyện chỉ được truy cập bởi đúng người có thẩm quyền.',
    detail: 'HTTPS · Firebase Auth Token · Firestore Rules · Mã hóa đầu cuối',
    icon: Icons.security_rounded,
    accentColor: Color(0xFF276749),
    gradient: [Color(0xFF1C4532), Color(0xFF38A169)],
  ),
  // 14. Impact
  _SlideData(
    tag: 'TÁC ĐỘNG TÍCH CỰC ĐẾN CỘNG ĐỒNG',
    title: 'Đóng góp tích cực\ncho cộng đồng y tế',
    description: 'CareTalk không chỉ là một ứng dụng — đây là cầu nối giữa người cần giúp đỡ và những bác sĩ tâm huyết muốn cống hiến. Chúng tôi hướng đến giảm tải bệnh viện, nâng cao nhận thức sức khỏe cộng đồng và lan tỏa tinh thần tình nguyện y tế.',
    detail: 'Giảm tải bệnh viện · Nâng cao nhận thức · Lan tỏa tình nguyện',
    icon: Icons.volunteer_activism_rounded,
    accentColor: Color(0xFFC53030),
    gradient: [Color(0xFF9B2C2C), Color(0xFFFC8181)],
  ),
  // 15. Call to action
  _SlideData(
    tag: 'SẴN SÀNG TRẢI NGHIỆM CARETALK NGAY',
    title: 'Bắt đầu hành trình\nchăm sóc sức khỏe cùng CareTalk!',
    description: 'Dù bạn là bệnh nhân cần tư vấn sức khỏe, hay bác sĩ tình nguyện muốn đóng góp cho cộng đồng — CareTalk chính là nền tảng dành cho bạn. Đăng ký hoàn toàn miễn phí, dễ sử dụng và luôn sẵn sàng phục vụ.',
    detail: '🎉 Miễn phí  ·  🚀 Dễ sử dụng  ·  ❤️ Có ích cho cộng đồng',
    icon: Icons.rocket_launch_rounded,
    accentColor: Color(0xFF2B6CB0),
    gradient: [Color(0xFF1A4971), Color(0xFF00A1FB)],
  ),
];

// ─── Screen ─────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _iconAnimController;
  late Animation<double> _iconScaleAnim;
  late Animation<double> _iconFadeAnim;

  late AnimationController _textAnimController;
  late Animation<double> _textSlideAnim;
  late Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();

    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScaleAnim = CurvedAnimation(
      parent: _iconAnimController,
      curve: Curves.elasticOut,
    );
    _iconFadeAnim = CurvedAnimation(
      parent: _iconAnimController,
      curve: Curves.easeIn,
    );

    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textSlideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _textAnimController, curve: Curves.easeOut),
    );
    _textFadeAnim = CurvedAnimation(
      parent: _textAnimController,
      curve: Curves.easeIn,
    );

    _playAnimations();
  }

  void _playAnimations() {
    _iconAnimController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _textAnimController.forward(from: 0);
    });
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _iconAnimController.reset();
    _textAnimController.reset();
    _playAnimations();
  }

  Future<void> _finish() async {
    await StorageService().setFirstLaunchComplete();
    if (mounted) context.go(AppRouter.roleSelectionPath);
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconAnimController.dispose();
    _textAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: slide.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicator text
                    Text(
                      '${_currentPage + 1} / ${_slides.length}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Skip button
                    if (!isLast)
                      GestureDetector(
                        onTap: _finish,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Bỏ qua',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── PageView ─────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _buildSlide(_slides[index]);
                  },
                ),
              ),

              // ── Bottom Controls ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  children: [
                    // Dot indicators
                    _buildDotIndicators(),
                    const SizedBox(height: 28),
                    // Next / Start button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: slide.gradient.last,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            key: ValueKey(isLast),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast ? 'Bắt đầu ngay' : 'Tiếp theo',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: slide.gradient.last,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLast
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                                color: slide.gradient.last,
                                size: 20,
                              ),
                            ],
                          ),
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

  Widget _buildSlide(_SlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tag chip
          AnimatedBuilder(
            animation: _textFadeAnim,
            builder: (context, child) => Opacity(
              opacity: _textFadeAnim.value.clamp(0.0, 1.0),
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                slide.tag,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Icon circle
          ScaleTransition(
            scale: _iconScaleAnim,
            child: FadeTransition(
              opacity: _iconFadeAnim,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  slide.icon,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Title
          AnimatedBuilder(
            animation: _textAnimController,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _textSlideAnim.value),
              child: Opacity(
                opacity: _textFadeAnim.value.clamp(0.0, 1.0),
                child: child,
              ),
            ),
            child: Text(
              slide.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          AnimatedBuilder(
            animation: _textAnimController,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _textSlideAnim.value * 1.2),
              child: Opacity(
                opacity: _textFadeAnim.value.clamp(0.0, 1.0),
                child: child,
              ),
            ),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Detail pill
          AnimatedBuilder(
            animation: _textAnimController,
            builder: (context, child) => Opacity(
              opacity: _textFadeAnim.value.clamp(0.0, 1.0),
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                slide.detail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
