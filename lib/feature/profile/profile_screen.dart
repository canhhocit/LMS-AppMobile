import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth/login_screen.dart';
import '../tuition/tuition_screen.dart';
import '../../app.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserEntity? _user;
  bool _isLoading = true;

  // Personalization settings state
  String _aiPersona = 'friendly'; // 'friendly', 'fast', 'strict'
  String _aiStyle = 'balanced'; // 'balanced', 'detailed', 'concise'
  bool _showFloatingAi = true;
  String _avatarTheme = 'lucid_blue'; // 'lucid_blue', 'emerald', 'violet', 'gold', 'crimson'

  @override
  void initState() {
    super.initState();
    _loadProfileAndSettings();
  }

  Future<void> _loadProfileAndSettings() async {
    setState(() => _isLoading = true);
    final user = await getIt<AuthRepository>().getCurrentUser();
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        _user = user;
        _aiPersona = prefs.getString(StorageKeys.aiPersona) ?? 'friendly';
        _aiStyle = prefs.getString(StorageKeys.aiStyle) ?? 'balanced';
        _showFloatingAi = prefs.getBool(StorageKeys.showAiFloatingButton) ?? true;
        _avatarTheme = prefs.getString(StorageKeys.avatarTheme) ?? 'lucid_blue';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAiSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.aiPersona, _aiPersona);
    await prefs.setString(StorageKeys.aiStyle, _aiStyle);
    await prefs.setBool(StorageKeys.showAiFloatingButton, _showFloatingAi);
    await prefs.setString(StorageKeys.avatarTheme, _avatarTheme);
  }

  Color _getAvatarThemeColor() {
    switch (_avatarTheme) {
      case 'emerald':
        return const Color(0xFF059669);
      case 'violet':
        return const Color(0xFF7C3AED);
      case 'gold':
        return const Color(0xFFD97706);
      case 'crimson':
        return const Color(0xFFE11D48);
      case 'lucid_blue':
      default:
        return AppColors.primary;
    }
  }

  void _showAvatarPickerDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Chọn phong cách Avatar', style: AppTextStyles.h3),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tùy chỉnh tông màu và biểu tượng chủ đạo cho Avatar cá nhân của bạn.',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildThemeOption('Lucid Blue', 'lucid_blue', AppColors.primary, setDialogState),
                      _buildThemeOption('Emerald Spark', 'emerald', const Color(0xFF059669), setDialogState),
                      _buildThemeOption('Cyber Violet', 'violet', const Color(0xFF7C3AED), setDialogState),
                      _buildThemeOption('Gold Scholar', 'gold', const Color(0xFFD97706), setDialogState),
                      _buildThemeOption('Sunset Crimson', 'crimson', const Color(0xFFE11D48), setDialogState),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getAvatarThemeColor(),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    await _saveAiSettings();
                    if (mounted) {
                      setState(() {});
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã cập nhật phong cách Avatar!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(String label, String key, Color color, StateSetter setDialogState) {
    final isSelected = _avatarTheme == key;
    return GestureDetector(
      onTap: () {
        setDialogState(() {
          _avatarTheme = key;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 8, backgroundColor: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _user?.fullName ?? '');
    final emailController = TextEditingController(text: _user?.personalEmail ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Chỉnh sửa thông tin cá nhân', style: AppTextStyles.h3),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      label: 'Họ và tên',
                      hint: 'Nhập họ tên',
                      controller: nameController,
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Email cá nhân',
                      hint: 'email@gmail.com',
                      controller: emailController,
                      prefixIcon: Icons.alternate_email,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newName = nameController.text.trim();
                          final newEmail = emailController.text.trim();

                          setDialogState(() => isSaving = true);
                          try {
                            final updatedUser = await getIt<AuthRepository>().updateProfile(
                              fullName: newName.isNotEmpty ? newName : null,
                              personalEmail: newEmail.isNotEmpty ? newEmail : null,
                            );
                            if (mounted) {
                              setState(() => _user = updatedUser);
                              Navigator.pop(dialogCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cập nhật thông tin thành công!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setDialogState(() => isSaving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Cập nhật thất bại: ${e.toString()}'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Đổi mật khẩu', style: AppTextStyles.h3),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      label: 'Mật khẩu hiện tại',
                      hint: '••••••',
                      controller: oldPasswordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Mật khẩu mới',
                      hint: '••••••',
                      controller: newPasswordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_reset,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Xác nhận mật khẩu mới',
                      hint: '••••••',
                      controller: confirmPasswordController,
                      isPassword: true,
                      prefixIcon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final oldPwd = oldPasswordController.text;
                          final newPwd = newPasswordController.text;
                          final confirmPwd = confirmPasswordController.text;

                          if (oldPwd.isEmpty || newPwd.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin mật khẩu')),
                            );
                            return;
                          }
                          if (newPwd != confirmPwd) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mật khẩu mới và xác nhận mật khẩu không khớp'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          try {
                            await getIt<AuthRepository>().changePassword(oldPwd, newPwd);
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đổi mật khẩu thành công!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setDialogState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đổi mật khẩu thất bại. Vui lòng kiểm tra lại mật khẩu cũ!'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Đổi mật khẩu', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user;
    final themeColor = _getAvatarThemeColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & Cá nhân hóa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfileAndSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar Header with Edit Action
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: themeColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: AppAvatar(
                          name: user?.fullName ?? 'Người dùng',
                          radius: 42,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAvatarPickerDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.palette,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.fullName ?? 'Họ và tên',
                        style: AppTextStyles.h2,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                        tooltip: 'Chỉnh sửa hồ sơ',
                        onPressed: _showEditProfileDialog,
                      ),
                    ],
                  ),
                  Text(
                    user?.isLecturer == true
                        ? 'Mã GV: ${user?.lecturerCode ?? "Chưa cấp"} • Vai trò: Giảng viên'
                        : 'Mã SV: ${user?.studentCode ?? "Chưa cấp"} • Vai trò: Sinh viên',
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Companion Personalization Section
            Row(
              children: [
                const Icon(Icons.psychology, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text('Cá nhân hóa Trợ lý AI', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tính cách Trợ lý AI (Persona)', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('💙 Cố vấn Thân thiện'),
                        selected: _aiPersona == 'friendly',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _aiPersona == 'friendly' ? Colors.white : AppColors.textPrimary,
                          fontWeight: _aiPersona == 'friendly' ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _aiPersona = 'friendly');
                            _saveAiSettings();
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('⚡ Trợ lý Siêu tốc'),
                        selected: _aiPersona == 'fast',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _aiPersona == 'fast' ? Colors.white : AppColors.textPrimary,
                          fontWeight: _aiPersona == 'fast' ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _aiPersona = 'fast');
                            _saveAiSettings();
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('🎯 Giám sát Tiến độ'),
                        selected: _aiPersona == 'strict',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _aiPersona == 'strict' ? Colors.white : AppColors.textPrimary,
                          fontWeight: _aiPersona == 'strict' ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _aiPersona = 'strict');
                            _saveAiSettings();
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  Text('Phong cách trả lời của AI', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Cân bằng')),
                          selected: _aiStyle == 'balanced',
                          selectedColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            color: _aiStyle == 'balanced' ? Colors.white : AppColors.textPrimary,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _aiStyle = 'balanced');
                              _saveAiSettings();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Chi tiết')),
                          selected: _aiStyle == 'detailed',
                          selectedColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            color: _aiStyle == 'detailed' ? Colors.white : AppColors.textPrimary,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _aiStyle = 'detailed');
                              _saveAiSettings();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Ngắn gọn')),
                          selected: _aiStyle == 'concise',
                          selectedColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            color: _aiStyle == 'concise' ? Colors.white : AppColors.textPrimary,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _aiStyle = 'concise');
                              _saveAiSettings();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hiển thị nút Hỏi AI Nhanh', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Nút nổi (FAB) hỗ trợ trò chuyện AI mọi lúc', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showFloatingAi,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() => _showFloatingAi = val);
                          _saveAiSettings();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Academic & Organization Details
            Text('Thông tin học tập & Tổ chức', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.domain,
                    label: 'Khoa / Bộ môn',
                    value: user?.facultyName ?? (user?.faculty != null && user!.faculty!.isNotEmpty ? user.faculty! : 'Chưa cập nhật'),
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.history_edu,
                    label: 'Chương trình đào tạo',
                    value: user?.displayCurriculum ?? 'Chưa cập nhật',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.groups,
                    label: 'Lớp hành chính',
                    value: user?.adminClassName ?? 'Chưa phân lớp',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email tài khoản (trường)',
                    value: user?.email ?? 'Chưa cập nhật',
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.alternate_email, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email cá nhân', style: AppTextStyles.caption),
                            const SizedBox(height: 2),
                            Text(
                              user?.personalEmail != null && user!.personalEmail!.isNotEmpty
                                  ? user.personalEmail!
                                  : 'Chưa liên kết email cá nhân',
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: user?.personalEmail != null && user!.personalEmail!.isNotEmpty
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        tooltip: 'Cập nhật email cá nhân',
                        onPressed: _showEditProfileDialog,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security & Services Settings
            Text('Dịch vụ & Bảo mật', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            AppCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TuitionScreen()),
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFF59E0B)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tra cứu Học phí & Công nợ', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Xem lịch sử nộp học phí và tổng dư nợ', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              onTap: _showChangePasswordDialog,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đổi mật khẩu', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Cập nhật mật khẩu tài khoản của bạn', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Theme Settings Card
            Text('Giao diện & Cài đặt', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      themeNotifier.value == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chế độ Tối (Dark Mode)', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Bật/Tắt giao diện tối bảo vệ mắt', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeNotifier.value == ThemeMode.dark,
                    activeColor: AppColors.primary,
                    onChanged: (isDark) {
                      setState(() {
                        themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            AppButton(
              text: 'Đăng xuất',
              icon: Icons.logout,
              variant: AppButtonVariant.outline,
              onPressed: () async {
                await getIt<AuthRepository>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
