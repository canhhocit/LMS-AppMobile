import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient(AuthInterceptor authInterceptor)
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ) {
    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }
}
