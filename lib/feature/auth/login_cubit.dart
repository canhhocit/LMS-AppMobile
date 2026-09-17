import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit(this.authRepository) : super(LoginInitial());

  Future<void> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      emit(LoginFailure('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu'));
      return;
    }

    emit(LoginLoading());
    try {
      final user = await authRepository.login(username, password);
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
