import 'package:dio/dio.dart';
import '../../data/session/session_manager.dart';

class AuthInterceptor extends Interceptor {
  final SessionManager sessionManager;
  final void Function()? onUnauthorized;

  AuthInterceptor(this.sessionManager, {this.onUnauthorized});

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
    }
    return handler.next(err);
  }
}
