/// Validators cho form fields
class Validators {
  Validators._();

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  /// Validate confirm password
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  /// Validate required field
  static String? required(String? value, [String fieldName = 'Trường này']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Validate phone number (VN)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  /// Validate full name
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (value.trim().length < 2) {
      return 'Họ và tên quá ngắn';
    }
    return null;
  }

  /// Validate min length
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'Trường này'} phải có ít nhất $min ký tự';
    }
    return null;
  }

  /// Validate max length
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'Trường này'} không được quá $max ký tự';
    }
    return null;
  }
}
