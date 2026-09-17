import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo hệ thống'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? const Center(child: Text('Chưa có thông báo nào'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, idx) {
                        final notif = _notifications[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: notif.isRead ? Colors.white : AppColors.primaryLight,
                          child: ListTile(
                            leading: Icon(
                              notif.isRead ? Icons.notifications_none : Icons.notifications_active,
                              color: notif.isRead ? Colors.grey : AppColors.primary,
                            ),
                            title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(notif.content),
                                const SizedBox(height: 4),
                                Text(notif.createdAt, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            onTap: () async {
                              if (!notif.isRead) {
                                await _repo.markNotificationAsRead(notif.id);
                                _loadNotifications();
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
