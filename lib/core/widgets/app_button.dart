import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      switch (variant) {
        case AppButtonVariant.primary:
          return AppColors.primary;
        case AppButtonVariant.secondary:
          return AppColors.secondary;
        case AppButtonVariant.outline:
        case AppButtonVariant.text:
          return Colors.transparent;
      }
    }

    Color getTextColor() {
      switch (variant) {
        case AppButtonVariant.primary:
        case AppButtonVariant.secondary:
          return Colors.white;
        case AppButtonVariant.outline:
        case AppButtonVariant.text:
          return AppColors.primary;
      }
    }

    BorderSide getBorderSide() {
      if (variant == AppButtonVariant.outline) {
        return const BorderSide(color: AppColors.primary, width: 1.5);
      }
      return BorderSide.none;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getTextColor(),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
            side: getBorderSide(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: getTextColor()),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(color: getTextColor()),
                  ),
                ],
              ),
      ),
    );
  }
}
