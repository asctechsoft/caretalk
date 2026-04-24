import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:care_talk/core/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final Logger _logger = Logger();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://103.48.84.161:8888',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptor to automatically attach Firebase ID Token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Luôn lấy Firebase ID Token mới nhất
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final idToken = await user.getIdToken();
            if (idToken != null) {
              options.headers['Authorization'] = 'Bearer $idToken';
              _logger.i(
                '🔑 Đã đính kèm Token của user: ${user.uid} (Token bắt đầu bằng: ${idToken.substring(0, 15)}...)',
              );
            }
          } else {
            _logger.w(
              '⚠️ KHÔNG có user đăng nhập, không có token nào được đính kèm!',
            );
          }

          _logger.i('API Request: [${options.method}] ${options.uri}');

          // In ra cURL để copy test trên Terminal hoặc Postman
          String curl =
              'curl -X ${options.method} "${options.uri}" \\\n'
              '  -H "Authorization: ${options.headers['Authorization']}" \\\n'
              '  -H "Content-Type: application/json" \\\n'
              '  -d \'${jsonEncode(options.data)}\'';
          _logger.w(
            '🚀 Thử chạy lệnh cURL này để xem lỗi 500 có xuất hiện không:\n$curl',
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i(
            'API Response: [${response.statusCode}] ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          _logger.e(
            'API Error: [${e.response?.statusCode}] ${e.requestOptions.uri}\n${e.message}',
          );
          return handler.next(e);
        },
      ),
    );
  }

  /// Gửi tin nhắn cho Chatbot (dạng Stream)
  Stream<String> sendChatMessageStream(String message) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        '/api/v1/chatbot/chat',
        data: {'message': message},
        options: Options(responseType: ResponseType.stream),
      );

      if (response.data != null) {
        final stream = response.data!.stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (line.startsWith('data:')) {
            String text = line.substring(5);
            // CHÚ Ý: Không xóa dấu cách đầu tiên vì có vẻ backend dùng luôn dấu cách của chuẩn SSE làm dấu cách giữa các chữ!

            if (text.isEmpty) {
              yield '\n'; // Nếu dòng data trống, có thể backend muốn gửi xuống dòng
              continue;
            }

            if (text == '[DONE]' || text == '[DONE]\n') break;

            // Bỏ qua các object JSON rác (như sessionId hay messageId)
            if (text.startsWith('{') && text.endsWith('}')) {
              continue;
            }

            // Yield text từ bot
            yield text;
          }
        }
      }
    } catch (e) {
      _logger.e('Send Chat Stream Error: $e');

      // Fallback khi API lỗi để bạn vẫn test được UI
      final mockResponse =
          'Đây là phản hồi tự động (Do API đang báo lỗi 500). Hệ thống ghi nhận bạn có dấu hiệu cần theo dõi thêm. Vui lòng cung cấp chi tiết hơn.';
      final words = mockResponse.split(' ');
      for (var word in words) {
        await Future.delayed(const Duration(milliseconds: 100));
        yield '$word ';
      }
    }
  }

  /// Gửi tin nhắn cho Chatbot ẩn danh (dạng Stream)
  Stream<String> sendAnonymousChatMessageStream(String message) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        '/api/v1/public/chat',
        data: {'message': message},
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'X-API-Key': 'caretalk-dev-key-2026',
          },
        ),
      );

      if (response.data != null) {
        final stream = response.data!.stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (line.startsWith('data:')) {
            String text = line.substring(5);
            // CHÚ Ý: Không xóa dấu cách đầu tiên vì có vẻ backend dùng luôn dấu cách của chuẩn SSE làm dấu cách giữa các chữ!

            if (text.isEmpty) {
              yield '\n'; // Nếu dòng data trống, có thể backend muốn gửi xuống dòng
              continue;
            }

            if (text == '[DONE]' || text == '[DONE]\n') break;

            // Bỏ qua các object JSON rác (như sessionId hay messageId)
            if (text.startsWith('{') && text.endsWith('}')) {
              continue;
            }

            // Yield text từ bot
            yield text;
          }
        }
      }
    } catch (e) {
      _logger.e('Send Anonymous Chat Stream Error: $e');

      // Fallback khi API lỗi để bạn vẫn test được UI
      final mockResponse =
          'Đây là phản hồi ẩn danh tự động (Do API đang báo lỗi). Hệ thống ghi nhận bạn có dấu hiệu cần theo dõi thêm. Vui lòng đăng nhập để trao đổi chi tiết hơn.';
      final words = mockResponse.split(' ');
      for (var word in words) {
        await Future.delayed(const Duration(milliseconds: 100));
        yield '$word ';
      }
    }
  }

  Future<bool> registerFirebase({
    required String firebaseUid,
    required String email,
    required String phoneNumber,
    required String role,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/users/register-firebase',
        data: {
          "firebaseUid": firebaseUid,
          "email": email,
          "phoneNumber": phoneNumber,
          "role": role.toUpperCase(),
          "status": "ACTIVE",
          "authProvider": "password",
          "metadata": {
            "displayName": fullName,
            "dateOfBirth": "1990-01-15",
            "gender": "MALE",
            "address": "Hà Nội",
          },
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _logger.e('Register Firebase API Error: $e');
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await _dio.put('/api/v1/users/me', data: body);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _logger.e('Update Profile Error: $e');
      return false;
    }
  }
}
