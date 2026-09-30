import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/session/session_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../feature/auth/login_screen.dart';

class AuthInterceptor extends Interceptor {
  final SessionManager sessionManager;
  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final void Function()? onUnauthorized;
  bool _isHandlingUnauthorized = false;

  AuthInterceptor(
    this.sessionManager, {
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.onUnauthorized,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await sessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle token expiration / unauthorized
      sessionManager.clearSession();
      onUnauthorized?.call();

      if (!_isHandlingUnauthorized) {
        _isHandlingUnauthorized = true;

        // Show session expired notification
        scaffoldMessengerKey?.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );

        // Auto redirect to Login screen
        navigatorKey?.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );

        // Reset throttle flag after short delay
        Future.delayed(const Duration(seconds: 3), () {
          _isHandlingUnauthorized = false;
        });
      }
    }
    return handler.next(err);
  }
}
