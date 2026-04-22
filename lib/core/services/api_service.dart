import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

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
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Lấy idToken từ Firebase (tự động làm mới nếu hết hạn)
            final idToken = await user.getIdToken();
            if (idToken != null) {
              options.headers['Authorization'] = 'Bearer $idToken';
            }
          }
          _logger.i('API Request: [${options.method}] ${options.uri}');
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
      yield 'Lỗi kết nối máy chủ.';
    }
  }
}
