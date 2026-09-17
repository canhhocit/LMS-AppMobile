import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';

class SessionManager {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  SessionManager(this._secureStorage, this._prefs);

  Future<void> saveTokens({required String token, String? refreshToken}) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
    if (refreshToken != null) {
      await _secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken);
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveUserJson(String userJson) async {
    await _prefs.setString(StorageKeys.userSession, userJson);
  }

  String? getUserJson() {
    return _prefs.getString(StorageKeys.userSession);
  }

  Future<void> cacheData(String key, String jsonStr) async {
    await _prefs.setString(key, jsonStr);
  }

  String? getCachedData(String key) {
    return _prefs.getString(key);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _prefs.remove(StorageKeys.userSession);
  }
}
