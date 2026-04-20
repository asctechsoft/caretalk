import 'package:care_talk/core/network/api_client.dart';
import 'package:care_talk/core/network/api_response.dart';

/// API Gateway - Tầng trung gian quản lý tất cả API calls (MOCKED for UI Testing)
class ApiGateway {
  final ApiClient _client;

  static ApiGateway? _instance;

  factory ApiGateway() {
    _instance ??= ApiGateway._internal(ApiClient());
    return _instance!;
  }

  ApiGateway._internal(this._client);

  // ═══════════════════════════════════════════════════════════════════
  // AUTH APIs - MOCKED
  // ═══════════════════════════════════════════════════════════════════

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return ApiResponse.success(
      data: {
        'token': 'mock_access_token_123',
        'user': {
          'id': 'user_123',
          'full_name': 'Nguyễn Văn Đức',
          'email': email,
        },
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return ApiResponse.success(data: {'message': 'Đăng ký thành công!'});
  }

  Future<ApiResponse> logout() async {
    return ApiResponse.success(data: {'message': 'Logged out'});
  }

  Future<ApiResponse> forgotPassword({required String email}) async {
    return ApiResponse.success(data: {'message': 'Reset link sent'});
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHAT APIs - MOCKED
  // ═══════════════════════════════════════════════════════════════════

  Future<ApiResponse<Map<String, dynamic>>> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse.success(
      data: {
        'reply':
            'Chào bạn, câu hỏi của bạn đã được ghi nhận. Tôi đang phân tích các triệu chứng này...',
        'session_id': sessionId ?? 'session_999',
      },
    );
  }

  Future<ApiResponse<List<dynamic>>> getChatHistory({
    required String sessionId,
    int page = 1,
    int limit = 50,
  }) async {
    return ApiResponse.success(data: []);
  }

  Future<ApiResponse<List<dynamic>>> getChatSessions({
    int page = 1,
    int limit = 20,
  }) async {
    return ApiResponse.success(
      data: [
        {
          'id': 'session_1',
          'title': 'Tư vấn đau đầu',
          'updated_at': '2024-04-19T10:00:00Z',
        },
        {
          'id': 'session_2',
          'title': 'Khám hậu COVID',
          'updated_at': '2024-04-18T15:30:00Z',
        },
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PATIENT APIs - MOCKED
  // ═══════════════════════════════════════════════════════════════════

  Future<ApiResponse<List<dynamic>>> getPatients({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    return ApiResponse.success(
      data: [
        {'id': 'p1', 'name': 'Lê Văn A', 'status': 'waiting', 'time': '10:30'},
        {
          'id': 'p2',
          'name': 'Trần Thị B',
          'status': 'completed',
          'time': '09:15',
        },
      ],
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getPatientDetail({
    required String patientId,
  }) async {
    return ApiResponse.success(
      data: {
        'id': patientId,
        'name': 'Bệnh nhân Demo',
        'age': 28,
        'symptoms': ['Ho', 'Sốt'],
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createPatient({
    required Map<String, dynamic> patientData,
  }) async {
    return ApiResponse.success(data: {'id': 'new_p_001'});
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePatient({
    required String patientId,
    required Map<String, dynamic> patientData,
  }) async {
    return ApiResponse.success(data: {'id': patientId});
  }

  Future<ApiResponse<List<dynamic>>> getWaitingPatients({
    int page = 1,
    int limit = 20,
  }) async {
    return ApiResponse.success(data: []);
  }

  // ═══════════════════════════════════════════════════════════════════
  // USER APIs - MOCKED
  // ═══════════════════════════════════════════════════════════════════

  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return ApiResponse.success(
      data: {
        'id': 'user_123',
        'full_name': 'Nguyễn Văn Đức',
        'email': 'ducnv@bachasoft.com',
        'role': 'patient',
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateUserProfile({
    required Map<String, dynamic> profileData,
  }) async {
    return ApiResponse.success(data: profileData);
  }
}
