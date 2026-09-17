import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

enum AppBadgeVariant { primary, success, warning, error, info }

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    Color getBgColor() {
      switch (variant) {
        case AppBadgeVariant.primary:
          return AppColors.primary.withOpacity(0.12);
        case AppBadgeVariant.success:
          return AppColors.success.withOpacity(0.12);
        case AppBadgeVariant.warning:
          return AppColors.warning.withOpacity(0.12);
        case AppBadgeVariant.error:
          return AppColors.error.withOpacity(0.12);
        case AppBadgeVariant.info:
          return AppColors.info.withOpacity(0.12);
      }
    }

    Color getTextColor() {
      switch (variant) {
        case AppBadgeVariant.primary:
          return AppColors.primary;
        case AppBadgeVariant.success:
          return AppColors.success;
        case AppBadgeVariant.warning:
          return AppColors.warning;
        case AppBadgeVariant.error:
          return AppColors.error;
        case AppBadgeVariant.info:
          return AppColors.info;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: getBgColor(),
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
