import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_education_logo.dart';
import '../../core/security/biometric_service.dart';
import '../../data/session/session_manager.dart';
import '../main_tab/main_tab_screen.dart';
import 'login_cubit.dart';
import 'login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(getIt()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainTabScreen()),
              );
            } else if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginLoading;

            return Stack(
              children: [
                // Top Header Background
                Container(
                  height: MediaQuery.of(context).size.height * 0.42,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppEducationLogo(size: 80),
                        const SizedBox(height: 12),
                        Text(
                          'LearningHub Mobile',
                          style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hệ thống quản lý học tập & đào tạo',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Login Form Card
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.32,
                    left: 20,
                    right: 20,
                    bottom: 24,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đăng nhập tài khoản',
                          style: AppTextStyles.h2.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vui lòng nhập tên tài khoản hoặc mã sinh viên',
                          style: AppTextStyles.body2,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Tài khoản / Mã sinh viên',
                          hint: 'Nhập mã sinh viên hoặc email',
                          controller: _usernameController,
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Mật khẩu',
                          hint: 'Nhập mật khẩu của bạn',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Đăng nhập',
                          isLoading: isLoading,
                          onPressed: () {
                            context.read<LoginCubit>().login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final biometricService = BiometricService();
                            final isAvailable = await biometricService.isBiometricAvailable();
                            if (!isAvailable) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Thiết bị chưa thiết lập sinh trắc học hoặc phần cứng không hỗ trợ!'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                              }
                              return;
                            }
                            final authenticated = await biometricService.authenticateWithBiometrics();
                            if (authenticated && context.mounted) {
                              final sessionManager = getIt<SessionManager>();
                              final token = await sessionManager.getToken();
                              final userJson = sessionManager.getUserJson();

                              if ((token != null && token.isNotEmpty) || (userJson != null && userJson.isNotEmpty)) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const MainTabScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng đăng nhập tài khoản lần đầu bằng mật khẩu để liên kết Vân tay/FaceID!'),
                                    backgroundColor: AppColors.info,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 22),
                          label: const Text('Đăng nhập Vân tay / FaceID', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const MainTabScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Trải nghiệm hệ thống',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
