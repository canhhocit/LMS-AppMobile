import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({String? customReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: customReason ?? 'Vui lòng xác thực sinh trắc học để đăng nhập LearningHub LMS',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticateFingerprint() async {
    return authenticateWithBiometrics(
      customReason: 'Vui lòng quét dấu vân tay để xác thực tài khoản LearningHub LMS',
    );
  }

  Future<bool> authenticateFaceId() async {
    return authenticateWithBiometrics(
      customReason: 'Vui lòng quét khuôn mặt (Face ID) để xác thực tài khoản LearningHub LMS',
    );
  }
}
