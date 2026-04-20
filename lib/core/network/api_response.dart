/// Response wrapper chung cho tất cả API calls
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });

  /// Tạo response thành công
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Tạo response lỗi
  factory ApiResponse.error({
    String? message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Kiểm tra có lỗi không
  bool get hasError => !isSuccess;

  /// Kiểm tra có dữ liệu không
  bool get hasData => data != null;

  @override
  String toString() {
    return 'ApiResponse(isSuccess: $isSuccess, statusCode: $statusCode, message: $message, data: $data)';
  }
}

/// Response wrapper cho danh sách có phân trang
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonItem,
  ) {
    final itemsList = (json['data'] as List)
        .map((item) => fromJsonItem(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: itemsList,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? itemsList.length,
      hasMore: json['has_more'] ?? false,
    );
  }
}
