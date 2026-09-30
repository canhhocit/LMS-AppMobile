import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/lms_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final LmsRepository _repo = getIt<LmsRepository>();

  bool _isLoading = true;
  List<NotificationEntity> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getNotifications();
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo hệ thống'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (unreadCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '$unreadCount chưa đọc',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? AppSkeleton.listLoader(count: 4, height: 90)
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? const AppEmptyState(
                      title: 'Bạn đã đọc hết thông báo',
                      subtitle: 'Các thông báo mới về lịch học, điểm số và học phí sẽ xuất hiện tại đây.',
                      icon: Icons.notifications_off_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, idx) {
                        final notif = _notifications[idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            onTap: () async {
                              if (!notif.isRead) {
                                await _repo.markNotificationAsRead(notif.id);
                                _loadNotifications();
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: notif.isRead ? AppColors.surface : AppColors.primaryBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: notif.isRead ? AppColors.border : AppColors.primaryLight,
                                    ),
                                  ),
                                  child: Icon(
                                    notif.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                                    color: notif.isRead ? AppColors.textMuted : AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif.title,
                                              style: AppTextStyles.body1.copyWith(
                                                fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (!notif.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif.content,
                                        style: AppTextStyles.body2,
                                      ),
                                      if (notif.createdAt.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          notif.createdAt,
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
