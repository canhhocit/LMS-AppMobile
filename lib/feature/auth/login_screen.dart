import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
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
                // Top Header Gradient Background
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'LearningHub Mobile',
                          style: AppTextStyles.h1.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hệ thống quản lý học tập & sinh viên',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Login Form Card
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.35,
                    left: 20,
                    right: 20,
                    bottom: 24,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đăng nhập tài khoản',
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Nhập thông tin tài khoản Sinh viên / Giảng viên để tiếp tục',
                          style: AppTextStyles.body2,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: 'Tên đăng nhập hoặc Mã sinh viên',
                          hint: 'VD: SV62001',
                          controller: _usernameController,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Mật khẩu',
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Đăng Nhập',
                          isLoading: isLoading,
                          onPressed: () {
                            context.read<LoginCubit>().login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Quick bypass for testing UI
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const MainTabScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Dùng thử bản Demo không cần login ➔',
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
