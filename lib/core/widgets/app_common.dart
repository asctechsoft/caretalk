import 'package:flutter/material.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';

/// Widget hiển thị khi không có dữ liệu
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị lỗi
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              ),
              child:
                  const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Avatar widget dùng chung
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppDimens.avatarMd,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.primarySurface,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                _getInitials(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}

/// Status badge cho bệnh nhân
class AppStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isSmall;

  const AppStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.isSmall = false,
  });

  /// Factory constructors cho các trạng thái bệnh nhân
  factory AppStatusBadge.waiting({bool isSmall = false}) => AppStatusBadge(
        text: 'Đang chờ',
        color: AppColors.statusWaiting,
        isSmall: isSmall,
      );

  factory AppStatusBadge.inProgress({bool isSmall = false}) => AppStatusBadge(
        text: 'Đang tư vấn',
        color: AppColors.statusInProgress,
        isSmall: isSmall,
      );

  factory AppStatusBadge.completed({bool isSmall = false}) => AppStatusBadge(
        text: 'Hoàn thành',
        color: AppColors.statusCompleted,
        isSmall: isSmall,
      );

  factory AppStatusBadge.cancelled({bool isSmall = false}) => AppStatusBadge(
        text: 'Đã hủy',
        color: AppColors.statusCancelled,
        isSmall: isSmall,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
