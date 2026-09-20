import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppEducationLogo extends StatelessWidget {
  final double size;
  final bool showTitle;
  final String? titleText;
  final String? subtitleText;

  const AppEducationLogo({
    super.key,
    this.size = 80,
    this.showTitle = false,
    this.titleText,
    this.subtitleText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4F46E5),
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Lucidchart-style Education Ring
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              // Graduation Cap & Open Book Icon Combination
              Icon(
                Icons.school_rounded,
                size: size * 0.52,
                color: Colors.white,
              ),
            ],
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 12),
          Text(
            titleText ?? 'LearningHub',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          if (subtitleText != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitleText!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
