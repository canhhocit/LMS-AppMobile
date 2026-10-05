import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/utils/app_file_launcher.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
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
        bool isLoading = false;
        bool isLoadingOptions = true;
        bool payOsEnabled = false;
        bool simulationEnabled = false;
        bool isVerifying = false;
        String? errorMsg;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            if (isLoadingOptions) {
              isLoadingOptions = false;
              getIt<StudentRepository>().getPaymentOptions().then((options) {
                setModalState(() {
                  payOsEnabled = options['payOsEnabled'] == true;
                  simulationEnabled = options['simulationEnabled'] == true;
                });
              }).catchError((error) {
                setModalState(() {
                  errorMsg = error.toString();
                });
              });
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Thanh toán học phí PayOS (VietQR)',
                      style: AppTextStyles.h3
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Học kỳ: ${item.semester} • Số tiền: ${_formatCurrency(item.remainingAmount)}',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: 20),
                  if (isLoading || isLoadingOptions)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(errorMsg!,
                          style: const TextStyle(color: AppColors.error)),
                    )
                  else if (payOSData != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBgColor(context),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.borderColor(context)),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              payOSData!.qrCode,
                              height: 180,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 100,
                                  color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            payOSData!.bankName,
                            style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                          Text(
                              'STK: ${payOSData!.accountNumber} • ${payOSData!.accountName}',
                              style: AppTextStyles.caption),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor(context),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppColors.borderColor(context)),
                            ),
                            child: Text(
                              'Nội dung: ${payOSData!.description}',
                              style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Mở trang thanh toán PayOS',
                      icon: Icons.open_in_new_rounded,
                      onPressed: () {
                        AppFileLauncher.openOrDownloadFile(
                            context, payOSData!.checkoutUrl);
                      },
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: isVerifying
                          ? 'Đang xác minh...'
                          : 'Xác minh thanh toán',
                      icon: Icons.check_circle_outline_rounded,
                      variant: AppButtonVariant.outline,
                      onPressed: isVerifying
                          ? null
                          : () async {
                              setModalState(() => isVerifying = true);
                              try {
                                final isPaid = await getIt<StudentRepository>()
                                    .verifyPayOSPayment(item.id);
                                if (context.mounted && isPaid) {
                                  Navigator.pop(bottomSheetContext);
                                  context.read<TuitionCubit>().loadTuition();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Xác nhận thanh toán PayOS thành công!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } else if (context.mounted) {
                                  setModalState(() => isVerifying = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Payment is still pending PayOS confirmation.')),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isVerifying = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Chưa ghi nhận giao dịch: ${e.toString()}'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                    ),
                  ] else ...[
                    if (payOsEnabled)
                      AppButton(
                        text: 'Continue / create PayOS payment',
                        icon: Icons.payment,
                        onPressed: () async {
                          setModalState(() {
                            isLoading = true;
                            errorMsg = null;
                          });
                          try {
                            final data = await getIt<StudentRepository>()
                                .createPayOSPayment(item.id);
                            setModalState(() {
                              payOSData = data;
                              isLoading = false;
                            });
                          } catch (error) {
                            setModalState(() {
                              errorMsg = error.toString();
                              isLoading = false;
                            });
                          }
                        },
                      ),
                    if (simulationEnabled)
                      AppButton(
                        text: 'Simulated payment (no real money)',
                        icon: Icons.science_outlined,
                        variant: AppButtonVariant.outline,
                        onPressed: () async {
                          try {
                            await getIt<StudentRepository>()
                                .simulateTuitionPayment(item.id);
                            if (bottomSheetContext.mounted)
                              Navigator.pop(bottomSheetContext);
                            if (context.mounted) {
                              context.read<TuitionCubit>().loadTuition();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Simulation recorded. No real money was transferred.')));
                            }
                          } catch (error) {
                            setModalState(() => errorMsg = error.toString());
                          }
                        },
                      ),
                    if (!payOsEnabled && !simulationEnabled)
                      const Text('No payment method is currently enabled.'),
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
          title: const Text('Thông tin học phí'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<TuitionCubit, TuitionState>(
          builder: (context, state) {
            if (state is TuitionLoading) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const AppSkeleton.rectangular(height: 100),
                    const SizedBox(height: 20),
                    AppSkeleton.listLoader(count: 3, height: 130),
                  ],
                ),
              );
            }
            if (state is TuitionError) {
              return AppErrorState(
                message: state.message,
                onRetry: () => context.read<TuitionCubit>().loadTuition(),
              );
            }
            if (state is TuitionLoaded) {
              final list = state.list;

              return RefreshIndicator(
                onRefresh: () => context.read<TuitionCubit>().loadTuition(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Total Unpaid Balance Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
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
                                Icons.account_balance_wallet_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tổng học phí còn nợ',
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // List Header
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

                      list.isEmpty
                          ? const AppEmptyState(
                              title: 'Chưa có thông tin học phí',
                              subtitle:
                                  'Danh sách hóa đơn học phí sẽ được cập nhật tại đây.',
                              icon: Icons.receipt_long_outlined,
                            )
                          : ListView.builder(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item.semester,
                                              style:
                                                  AppTextStyles.body1.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            AppBadge(
                                              text: isPaid
                                                  ? (item.paymentMethod ==
                                                          'SIMULATED'
                                                      ? 'Paid (simulation)'
                                                      : 'Paid')
                                                  : 'Unpaid',
                                              variant: isPaid
                                                  ? AppBadgeVariant.success
                                                  : AppBadgeVariant.warning,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Tổng học phí:',
                                                style: AppTextStyles.body2),
                                            Text(
                                              _formatCurrency(item.totalAmount),
                                              style:
                                                  AppTextStyles.body1.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Đã nộp:',
                                                style: AppTextStyles.body2),
                                            Text(
                                              _formatCurrency(item.paidAmount),
                                              style:
                                                  AppTextStyles.body1.copyWith(
                                                color: AppColors.success,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Còn nợ:',
                                                style: AppTextStyles.body2),
                                            Text(
                                              _formatCurrency(
                                                  item.remainingAmount),
                                              style:
                                                  AppTextStyles.body1.copyWith(
                                                color: item.remainingAmount > 0
                                                    ? AppColors.error
                                                    : AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (item.dueDate.isNotEmpty ||
                                            !isPaid) ...[
                                          const Divider(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (item.dueDate.isNotEmpty)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      size: 14,
                                                      color:
                                                          AppColors.textMuted,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Hạn: ${item.dueDate}',
                                                      style:
                                                          AppTextStyles.caption,
                                                    ),
                                                  ],
                                                ),
                                              if (!isPaid)
                                                ElevatedButton.icon(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 14,
                                                        vertical: 8),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                      Icons.payment_rounded,
                                                      size: 16,
                                                      color: Colors.white),
                                                  label: const Text(
                                                    'Nộp học phí',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onPressed: () =>
                                                      _showPayOSModal(
                                                          context, item),
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
