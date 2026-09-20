import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/grade_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/tuition_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../remote/dtos/student_dtos.dart';
import '../session/session_manager.dart';

class StudentRepositoryImpl implements StudentRepository {
  final DioClient dioClient;
  final SessionManager sessionManager;

  StudentRepositoryImpl({
    required this.dioClient,
    required this.sessionManager,
  });

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<List<CourseClassEntity>> getMyClasses() async {
    const cacheKey = StorageKeys.cacheClasses;
    try {
      final response = await dioClient.dio.get(ApiEndpoints.studentClasses);
      final list = _unwrap(response) as List<dynamic>? ?? [];
      await sessionManager.cacheData(cacheKey, jsonEncode(list));
      return list.map((json) => CourseClassDto.fromJson(json as Map<String, dynamic>).toEntity()).toList();
    } catch (_) {
      final cachedStr = sessionManager.getCachedData(cacheKey);
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final list = jsonDecode(cachedStr) as List<dynamic>? ?? [];
        return list.map((json) => CourseClassDto.fromJson(json as Map<String, dynamic>).toEntity()).toList();
      }
      return [];
    }
  }

  @override
  Future<List<ScheduleItemEntity>> getMySchedule() async {
    const cacheKey = StorageKeys.cacheSchedule;
    try {
      final response = await dioClient.dio.get(ApiEndpoints.studentSchedule);
      final list = _unwrap(response) as List<dynamic>? ?? [];
      await sessionManager.cacheData(cacheKey, jsonEncode(list));
      return list.map((json) => ScheduleDto.fromJson(json as Map<String, dynamic>).toEntity()).toList();
    } catch (_) {
      final cachedStr = sessionManager.getCachedData(cacheKey);
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final list = jsonDecode(cachedStr) as List<dynamic>? ?? [];
        return list.map((json) => ScheduleDto.fromJson(json as Map<String, dynamic>).toEntity()).toList();
      }
      return [];
    }
  }

  @override
  Future<List<GradeEntity>> getMyGrades() async {
    const cacheKey = StorageKeys.cacheGrades;
    try {
      final response = await dioClient.dio.get(ApiEndpoints.studentGrades);
      final list = _unwrap(response) as List<dynamic>? ?? [];
      await sessionManager.cacheData(cacheKey, jsonEncode(list));
      return list.map((json) => GradeDto.fromJson(json as Map<String, dynamic>).toEntity()).toList();
    } catch (_) {
      final cachedStr = sessionManager.getCachedData(cacheKey);
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final list = jsonDecode(cachedStr) as List<dynamic>? ?? [];
        return list.map((json) => GradeDto.fromJson(json as Map<String, dynamic>).toEntity()).toList();
      }
      return [];
    }
  }

  @override
  Future<List<TuitionItemEntity>> getMyTuition() async {
    const cacheKey = StorageKeys.cacheTuition;
    try {
      final response = await dioClient.dio.get(ApiEndpoints.studentTuition);
      final list = _unwrap(response) as List<dynamic>? ?? [];
      await sessionManager.cacheData(cacheKey, jsonEncode(list));
      return list.map((json) => TuitionDto.fromJson(json as Map<String, dynamic>).toEntity()).toList();
    } catch (_) {
      final cachedStr = sessionManager.getCachedData(cacheKey);
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final list = jsonDecode(cachedStr) as List<dynamic>? ?? [];
        return list.map((json) => TuitionDto.fromJson(json as Map<String, dynamic>).toEntity()).toList();
      }
      return [];
    }
  }
}
