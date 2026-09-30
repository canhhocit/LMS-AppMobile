import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class AppFileLauncher {
  static Future<void> openOrDownloadFile(
    BuildContext context,
    String url, {
    String? fileName,
  }) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      _showSnackBar(context, '⚠️ Đường dẫn tệp tin không hợp lệ!', isError: true);
      return;
    }

    try {
      final uri = Uri.parse(cleanUrl);

      // 1. Try launching in external application (Browser / Download manager)
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }

      // 2. Fallback to platform default mode if external mode fails
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {
          launched = false;
        }
      }

      if (launched) {
        if (context.mounted) {
          _showSnackBar(context, '🚀 Đang tải/mở tệp: ${fileName ?? "Tài liệu"}');
        }
      } else {
        // Fallback: Copy link to clipboard
        await Clipboard.setData(ClipboardData(text: cleanUrl));
        if (context.mounted) {
          _showSnackBar(
            context,
            '📋 Đã sao chép liên kết tệp! Bạn có thể dán vào trình duyệt để tải về.',
          );
        }
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: cleanUrl));
      if (context.mounted) {
        _showSnackBar(
          context,
          '📋 Đã sao chép liên kết tệp! Bạn có thể dán vào trình duyệt để tải về.',
        );
      }
    }
  }

  static void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
