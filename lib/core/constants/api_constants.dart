/// Cấu hình API endpoints
class ApiConstants {
  ApiConstants._();

  // ─── Base URL ──────────────────────────────────────────────────────
  static const String baseUrl = 'https://api.caretalk.com/v1';
  static const String stagingUrl = 'https://staging-api.caretalk.com/v1';

  // ─── Timeout ───────────────────────────────────────────────────────
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // ─── Auth Endpoints ────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';

  // ─── Chat Endpoints ────────────────────────────────────────────────
  static const String chatSendMessage = '/chat/send';
  static const String chatHistory = '/chat/history';
  static const String chatSessions = '/chat/sessions';

  // ─── Patient Endpoints ─────────────────────────────────────────────
  static const String patients = '/patients';
  static const String patientDetail = '/patients/{id}';
  static const String patientCreate = '/patients/create';
  static const String patientUpdate = '/patients/{id}/update';
  static const String patientWaitingList = '/patients/waiting';

  // ─── User Endpoints ────────────────────────────────────────────────
  static const String userProfile = '/user/profile';
  static const String userUpdate = '/user/update';

  // ─── Headers ───────────────────────────────────────────────────────
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';
}
