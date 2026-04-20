/// Chuỗi hiển thị trong ứng dụng CareTalk
class AppStrings {
  AppStrings._();

  // ─── App ───────────────────────────────────────────────────────────
  static const String appName = 'CareTalk';
  static const String appTagline = 'Trợ lý sức khỏe thông minh';
  static const String appDescription =
      'ChatBot tư vấn sức khỏe phòng khám, hỗ trợ bệnh nhân 24/7';

  // ─── Splash ────────────────────────────────────────────────────────
  static const String splashLoading = 'Đang khởi tạo...';

  // ─── Onboarding ────────────────────────────────────────────────────
  static const String onboardingTitle1 = 'Tư vấn sức khỏe';
  static const String onboardingDesc1 =
      'Trò chuyện với ChatBot thông minh để được tư vấn sức khỏe nhanh chóng và chính xác';
  static const String onboardingTitle2 = 'Đặt lịch khám bệnh';
  static const String onboardingDesc2 =
      'Dễ dàng đặt lịch hẹn khám bệnh tại phòng khám mà không cần chờ đợi';
  static const String onboardingTitle3 = 'Theo dõi sức khỏe';
  static const String onboardingDesc3 =
      'Quản lý hồ sơ sức khỏe cá nhân và theo dõi lịch sử khám bệnh một cách tiện lợi';
  static const String onboardingSkip = 'Bỏ qua';
  static const String onboardingNext = 'Tiếp theo';
  static const String onboardingStart = 'Bắt đầu';
  static const String onboardingTitle = 'Tư vấn sức khỏe ban đầu an toàn';
  static const String onboardingSubtitle = 'Kết nối bác sĩ tình nguyện khi cần';
  static const String onboardingFooter = 'Vui lòng đọc kỹ điều khoản trước khi sử dụng';
  static const String appNameAlt = 'Clinic AI';

  // ─── Auth ──────────────────────────────────────────────────────────
  static const String loginTitle = 'Đăng nhập';
  static const String loginSubtitle = 'Chào mừng bạn quay lại!';
  static const String loginEmail = 'Email';
  static const String loginPassword = 'Mật khẩu';
  static const String loginButton = 'Đăng nhập';
  static const String loginForgotPassword = 'Quên mật khẩu?';
  static const String loginNoAccount = 'Chưa có tài khoản? ';
  static const String loginRegister = 'Đăng ký ngay';
  static const String registerTitle = 'Đăng ký';
  static const String registerSubtitle = 'Tạo tài khoản mới';
  static const String registerFullName = 'Họ và tên';
  static const String registerPhone = 'Số điện thoại';
  static const String registerButton = 'Đăng ký';
  static const String registerHasAccount = 'Đã có tài khoản? ';
  static const String registerLogin = 'Đăng nhập';

  // ─── Chat ──────────────────────────────────────────────────────────
  static const String chatTitle = 'Trợ lý CareTalk';
  static const String chatInputHint = 'Nhập tin nhắn...';
  static const String chatWelcome =
      'Xin chào! Tôi là trợ lý sức khỏe CareTalk. Tôi có thể giúp gì cho bạn?';
  static const String chatTyping = 'Đang trả lời...';

  // ─── Patient Info ──────────────────────────────────────────────────
  static const String patientInfoTitle = 'Thông tin bệnh nhân';
  static const String patientName = 'Họ và tên';
  static const String patientPhone = 'Số điện thoại';
  static const String patientEmail = 'Email';
  static const String patientDob = 'Ngày sinh';
  static const String patientGender = 'Giới tính';
  static const String patientAddress = 'Địa chỉ';
  static const String patientSymptoms = 'Triệu chứng';
  static const String patientNote = 'Ghi chú';
  static const String patientSubmit = 'Gửi thông tin';

  // ─── Patient List ──────────────────────────────────────────────────
  static const String patientListTitle = 'Danh sách bệnh nhân';
  static const String patientListWaiting = 'Đang chờ tư vấn';
  static const String patientListInProgress = 'Đang tư vấn';
  static const String patientListCompleted = 'Đã hoàn thành';
  static const String patientListEmpty = 'Không có bệnh nhân nào';

  // ─── Common ────────────────────────────────────────────────────────
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String save = 'Lưu';
  static const String delete = 'Xóa';
  static const String edit = 'Sửa';
  static const String search = 'Tìm kiếm';
  static const String retry = 'Thử lại';
  static const String loading = 'Đang tải...';
  static const String noData = 'Không có dữ liệu';
  static const String errorGeneral = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  static const String errorNetwork =
      'Không có kết nối mạng. Vui lòng kiểm tra lại.';
  static const String errorTimeout =
      'Yêu cầu quá thời gian. Vui lòng thử lại.';

  // ─── Doctor Supplement Info ─────────────────────────────────────────
  static const String doctorSupplementTitle = 'Bổ sung thông tin';
  static const String doctorSupplementSubtitle = 'Vui lòng hoàn thiện hồ sơ để bắt đầu hỗ trợ bệnh nhân';
  static const String sectionPersonalInfo = 'Thông tin cá nhân';
  static const String sectionProfessionalInfo = 'Thông tin chuyên môn';
  static const String birthYear = 'Năm sinh';
  static const String gender = 'Giới tính';
  static const String permanentAddress = 'Nơi sinh sống';
  static const String specialty = 'Chuyên khoa';
  static const String currentWorkplace = 'Nơi công tác hiện tại';
  static const String jobTitle = 'Chức danh';
  static const String experienceYears = 'Kinh nghiệm (năm)';
  static const String saveAndContinue = 'Lưu và tiếp tục';
}
