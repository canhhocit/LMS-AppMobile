import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import 'tuition_cubit.dart';
import 'tuition_state.dart';

class TuitionScreen extends StatelessWidget {
  const TuitionScreen({super.key});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
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
