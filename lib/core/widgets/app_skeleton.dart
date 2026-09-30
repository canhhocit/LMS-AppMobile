import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class AppSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AppSkeleton.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
  });

  const AppSkeleton.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final base = isDark ? const Color(0xFF1E293B) : Colors.grey.shade200;
    final highlight = isDark ? const Color(0xFF334155) : Colors.grey.shade50;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius ?? AppRadius.borderMd,
        ),
      ),
    );
  }

  static Widget cardLoader({BuildContext? context, double height = 100}) {
    final isDark = context != null ? AppColors.isDark(context) : false;
    final base = isDark ? const Color(0xFF1E293B) : Colors.grey.shade200;
    final highlight = isDark ? const Color(0xFF334155) : Colors.grey.shade50;
    final bg = isDark ? AppColors.darkSurface : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.borderMd,
          ),
        ),
      ),
    );
  }

  static Widget listLoader({BuildContext? context, int count = 4, double height = 80}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (_, __) => cardLoader(context: context, height: height),
    );
  }
}
