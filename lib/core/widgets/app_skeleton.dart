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
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius ?? AppRadius.borderMd,
        ),
      ),
    );
  }

  static Widget cardLoader({double height = 100}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.borderMd,
          ),
        ),
      ),
    );
  }

  static Widget listLoader({int count = 4, double height = 80}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (_, __) => cardLoader(height: height),
    );
  }
}
