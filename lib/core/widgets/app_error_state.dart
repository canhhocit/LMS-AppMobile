import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const AppErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Thử lại',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: AppTextStyles.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
