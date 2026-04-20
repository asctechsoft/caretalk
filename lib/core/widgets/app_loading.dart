import 'package:flutter/material.dart';
import 'package:care_talk/core/constants/app_colors.dart';

/// Loading indicator dùng chung
class AppLoading extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const AppLoading({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color ?? AppColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading overlay phủ lên màn hình
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: AppLoading(message: message),
          ),
      ],
    );
  }
}

/// Shimmer loading placeholder
class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
