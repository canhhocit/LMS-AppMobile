import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../domain/entities/tuition_entity.dart';
import '../../domain/repositories/student_repository.dart';
import 'tuition_cubit.dart';
import 'tuition_state.dart';

class TuitionScreen extends StatefulWidget {
  const TuitionScreen({super.key});

  @override
  State<TuitionScreen> createState() => _TuitionScreenState();
}

class _TuitionScreenState extends State<TuitionScreen> {
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  void _showPayOSModal(BuildContext context, TuitionItemEntity item) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        PayOSPaymentEntity? payOSData;
        bool isLoading = true;
        bool isVerifying = false;
        String? errorMsg;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            // Load PayOS link on open
            if (isLoading && payOSData == null && errorMsg == null) {
              getIt<StudentRepository>().createPayOSPayment(item.id).then((data) {
                setModalState(() {
                  payOSData = data;
                  isLoading = false;
                });
              }).catchError((e) {
                setModalState(() {
                  errorMsg = 'Lỗi tạo liên kết PayOS: ${e.toString()}';
                  isLoading = false;
                });
              });
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Thanh toán PayOS (VietQR)', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    'Hóa đơn: ${item.semester} • Số tiền: ${_formatCurrency(item.remainingAmount)}',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: 20),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(errorMsg!, style: TextStyle(color: AppColors.error)),
                    )
                  else if (payOSData != null) ...[
                    // VietQR Image Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              payOSData!.qrCode,
                              height: 190,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 100, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            payOSData!.bankName,
                            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          Text('STK: ${payOSData!.accountNumber} • ${payOSData!.accountName}', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.indigo.shade200),
                            ),
                            child: Text(
                              'Nội dung: ${payOSData!.description}',
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    AppButton(
                      text: 'Mở trang thanh toán PayOS',
                      icon: Icons.open_in_new,
                      onPressed: () async {
                        final uri = Uri.parse(payOSData!.checkoutUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: isVerifying ? 'Đang xác minh...' : 'Tôi đã chuyển khoản - Xác minh ngay',
                      icon: Icons.check_circle_outline,
                      variant: AppButtonVariant.outline,
                      onPressed: isVerifying
                          ? null
                          : () async {
                              setModalState(() => isVerifying = true);
                              try {
                                await getIt<StudentRepository>().verifyPayOSPayment(item.id);
                                if (context.mounted) {
                                  Navigator.pop(bottomSheetContext);
                                  context.read<TuitionCubit>().loadTuition();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Xác nhận thanh toán PayOS thành công!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isVerifying = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi xác minh: ${e.toString()}'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TuitionCubit(getIt())..loadTuition(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thông tin Học phí'),
        ),
        body: BlocBuilder<TuitionCubit, TuitionState>(
          builder: (context, state) {
            if (state is TuitionLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TuitionError) {
              return Center(child: Text(state.message));
            }
            if (state is TuitionLoaded) {
              final list = state.list;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Total Unpaid Balance Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tổng nợ học phí',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(state.totalUnpaid),
                                  style: AppTextStyles.h1.copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Semester Tuitions List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lịch sử học phí', style: AppTextStyles.h3),
                        Text(
                          '${list.length} học kỳ',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Semester Tuitions List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final isPaid = item.status == 'PAID';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.semester,
                                      style: AppTextStyles.body1.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    AppBadge(
                                      text: isPaid ? 'Đã hoàn thành' : 'Chưa thanh toán',
                                      variant: isPaid
                                          ? AppBadgeVariant.success
                                          : AppBadgeVariant.warning,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tổng học phí:', style: AppTextStyles.body2),
                                    Text(
                                      _formatCurrency(item.totalAmount),
                                      style: AppTextStyles.body1.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Đã nộp:', style: AppTextStyles.body2),
                                    Text(
                                      _formatCurrency(item.paidAmount),
                                      style: AppTextStyles.body1.copyWith(
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Còn nợ:', style: AppTextStyles.body2),
                                    Text(
                                      _formatCurrency(item.remainingAmount),
                                      style: AppTextStyles.body1.copyWith(
                                        color: item.remainingAmount > 0
                                            ? AppColors.error
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.dueDate.isNotEmpty) ...[
                                  const Divider(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month,
                                            size: 16,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Hạn nộp: ${item.dueDate}',
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),

                                      if (!isPaid)
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          icon: const Icon(Icons.qr_code_scanner, size: 16, color: Colors.white),
                                          label: const Text(
                                            'Thanh toán PayOS',
                                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () => _showPayOSModal(context, item),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
