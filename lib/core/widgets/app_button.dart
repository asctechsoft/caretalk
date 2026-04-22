import 'package:flutter/material.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';

/// Button chính dùng chung trong toàn app
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isSmall;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSmall = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final height = isSmall ? AppDimens.buttonHeightSm : AppDimens.buttonHeight;
    final radius = borderRadius ?? AppDimens.buttonRadius;
    final fontSize = isSmall ? 14.0 : 16.0;

    if (isOutlined) {
      final color = textColor ?? AppColors.primary;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            width: isFullWidth ? double.infinity : null,
            height: height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: backgroundColor ?? AppColors.primary,
                width: 1.5,
              ),
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: color),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  child: _buildChild(fontSize, color),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final color = textColor ?? AppColors.textOnPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: isFullWidth ? double.infinity : null,
          height: height,
          decoration: BoxDecoration(
            color: (onPressed == null && !isLoading) 
                ? AppColors.disabled 
                : backgroundColor,
            gradient: ((onPressed != null || isLoading) && backgroundColor == null) 
                ? AppColors.primaryGradient 
                : null,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: color),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                child: _buildChild(fontSize, color),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(double fontSize, Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 18 : 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

/// Gradient Button
class AppGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final double? height;
  final double? borderRadius;

  const AppGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? AppDimens.buttonHeight,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? (gradient ?? AppColors.primaryGradient)
            : const LinearGradient(
                colors: [AppColors.disabled, AppColors.disabled],
              ),
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppDimens.buttonRadius,
        ),
        // boxShadow: onPressed != null
        //     ? [
        //         BoxShadow(
        //           color: AppColors.primary.withValues(alpha: 0.3),
        //           blurRadius: 12,
        //           offset: const Offset(0, 4),
        //         ),
        //       ]
        //     : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppDimens.buttonRadius,
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
