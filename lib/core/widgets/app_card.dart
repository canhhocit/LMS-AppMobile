import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadow.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final defaultBg = AppColors.surfaceColor(context);
    final defaultBorder = Border.all(color: AppColors.borderColor(context));

    final cardWidget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: AppRadius.borderMd,
        border: border ?? defaultBorder,
        boxShadow: isDark ? [] : AppShadow.sm,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
