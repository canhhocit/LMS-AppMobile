import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/lms_repository_impl.dart';
import '../../data/session/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/lms_repository.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPrefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  getIt.registerSingleton<SharedPreferences>(sharedPrefs);
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Session
  getIt.registerLazySingleton<SessionManager>(
    () => SessionManager(getIt(), getIt()),
  );

  // Network
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(getIt()),
  );
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt()),
  );

  // Unified LMS Repository
  final lmsRepo = LmsRepositoryImpl(
    dioClient: getIt(),
    sessionManager: getIt(),
  );

  getIt.registerSingleton<LmsRepository>(lmsRepo);
  getIt.registerSingleton<AuthRepository>(lmsRepo);
  getIt.registerSingleton<StudentRepository>(lmsRepo);
}
