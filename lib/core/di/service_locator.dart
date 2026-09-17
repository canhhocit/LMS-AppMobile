import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../data/session/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/student_repository.dart';
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

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dioClient: getIt(),
      sessionManager: getIt(),
    ),
  );
  getIt.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(dioClient: getIt()),
  );
}
