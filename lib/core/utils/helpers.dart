import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Các hàm tiện ích dùng chung
class Helpers {
  Helpers._();

  // ─── Date & Time ───────────────────────────────────────────────────

  /// Format ngày tháng
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  /// Format ngày giờ
  static String formatDateTime(DateTime date,
      {String pattern = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(pattern).format(date);
  }

  /// Format thời gian chat (hiển thị "Hôm nay", "Hôm qua", hoặc ngày cụ thể)
  static String formatChatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (messageDate == yesterday) {
      return 'Hôm qua ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM HH:mm').format(date);
    }
  }

  /// Tính tuổi từ ngày sinh
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // ─── String Helpers ────────────────────────────────────────────────

  /// Viết hoa chữ cái đầu
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Rút gọn text
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  /// Lấy initials từ tên (VD: "Nguyễn Văn An" -> "NA")
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  // ─── UI Helpers ────────────────────────────────────────────────────

  /// Hiển thị SnackBar
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Theme.of(context).colorScheme.error : null,
          duration: duration,
          action: SnackBarAction(
            label: 'Đóng',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
  }

  /// Hiển thị loading dialog
  static void showLoadingDialog(BuildContext context,
      {String message = 'Đang tải...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  /// Ẩn loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Hiển thị confirm dialog
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    bool isDanger = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDanger
                ? ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ─── Number Helpers ────────────────────────────────────────────────

  /// Format số với dấu phân cách hàng nghìn
  static String formatNumber(num number) {
    return NumberFormat('#,###', 'vi_VN').format(number);
  }

  /// Format tiền VND
  static String formatCurrency(num amount) {
    return '${NumberFormat('#,###', 'vi_VN').format(amount)}đ';
  }
}
