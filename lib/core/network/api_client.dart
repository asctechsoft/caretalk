import 'package:dio/dio.dart';
import 'package:care_talk/core/constants/api_constants.dart';
import 'package:care_talk/core/network/api_interceptor.dart';
import 'package:care_talk/core/network/api_response.dart';
import 'package:logger/logger.dart';

/// API Client sử dụng Dio để gọi API Gateway
class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  static ApiClient? _instance;

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
          ApiConstants.headerAccept: ApiConstants.contentTypeJson,
        },
      ),
    );

    // Thêm interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  /// Cập nhật base URL (cho staging/production)
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Cập nhật token
  void updateToken(String token) {
    _dio.options.headers[ApiConstants.headerAuthorization] =
        '${ApiConstants.bearerPrefix}$token';
  }

  /// Xóa token (logout)
  void clearToken() {
    _dio.options.headers.remove(ApiConstants.headerAuthorization);
  }

  // ═══════════════════════════════════════════════════════════════════
  // HTTP METHODS
  // ═══════════════════════════════════════════════════════════════════

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        statusCode: response.statusCode,
        message: 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('GET Error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        statusCode: response.statusCode,
        message: 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('POST Error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        statusCode: response.statusCode,
        message: 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('PUT Error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        statusCode: response.statusCode,
        message: 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('DELETE Error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Upload file
  Future<ApiResponse<T>> upload<T>(
    String path, {
    required FormData formData,
    T Function(dynamic json)? fromJson,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        statusCode: response.statusCode,
        message: 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      _logger.e('Upload Error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Error Handling ────────────────────────────────────────────────
  ApiResponse<T> _handleError<T>(DioException e) {
    _logger.e('DioException: ${e.type} - ${e.message}');

    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Kết nối quá thời gian. Vui lòng thử lại.';
        break;
      case DioExceptionType.connectionError:
        message = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.';
        break;
      case DioExceptionType.badResponse:
        message = _handleStatusCode(statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Yêu cầu đã bị hủy.';
        break;
      default:
        message = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }

    return ApiResponse.error(
      message: message,
      statusCode: statusCode,
    );
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Yêu cầu không hợp lệ.';
      case 401:
        return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn không có quyền truy cập.';
      case 404:
        return 'Không tìm thấy dữ liệu.';
      case 500:
        return 'Lỗi máy chủ. Vui lòng thử lại sau.';
      default:
        return 'Đã có lỗi xảy ra (${statusCode ?? "unknown"}).';
    }
  }
}
