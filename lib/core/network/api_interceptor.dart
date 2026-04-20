import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:care_talk/core/services/storage_service.dart';

/// Interceptor xử lý authentication token
class AuthInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Đọc token từ local storage
    final token = await StorageService().getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _logger.w('Token expired, attempting to refresh...');

      // TODO: Thêm logic refresh token ở đây
      // try {
      //   final newToken = await _refreshToken();
      //   if (newToken != null) {
      //     err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      //     final response = await Dio().fetch(err.requestOptions);
      //     return handler.resolve(response);
      //   }
      // } catch (e) {
      //   _logger.e('Refresh token failed: $e');
      // }
    }
    handler.next(err);
  }
}

/// Interceptor logging request/response cho debug
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '┌─ REQUEST ─────────────────────────────────────\n'
      '│ ${options.method} ${options.uri}\n'
      '│ Headers: ${options.headers}\n'
      '│ Data: ${options.data}\n'
      '└──────────────────────────────────────────────',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '┌─ RESPONSE ────────────────────────────────────\n'
      '│ ${response.statusCode} ${response.requestOptions.uri}\n'
      '│ Data: ${response.data}\n'
      '└──────────────────────────────────────────────',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '┌─ ERROR ───────────────────────────────────────\n'
      '│ ${err.type} ${err.requestOptions.uri}\n'
      '│ Message: ${err.message}\n'
      '│ Response: ${err.response?.data}\n'
      '└──────────────────────────────────────────────',
    );
    handler.next(err);
  }
}
