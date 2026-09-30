import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/offline_banner.dart';
import '../classes/class_list_screen.dart';
import '../home/home_screen.dart';
import '../ai_advisor/ai_advisor_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../schedule/schedule_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isDisconnected = results.contains(ConnectivityResult.none) || results.isEmpty;
      if (mounted) {
        setState(() {
          _isOffline = isDisconnected;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onNavigateTab: _onTabTapped),
      const ClassListScreen(),
      const ScheduleScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OfflineBanner(isOffline: _isOffline),
            Expanded(
              child: IndexedStack(
                index: _currentIndex < pages.length ? _currentIndex : 0,
                children: pages,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiAdvisorScreen()),
          );
        },
        elevation: 3,
        backgroundColor: AppColors.primary,
        tooltip: 'Hỏi Cố vấn AI',
        child: const Icon(Icons.assistant_outlined, color: Colors.white, size: 24),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex < pages.length ? _currentIndex : 0,
        onDestinationSelected: _onTabTapped,
        indicatorColor: AppColors.primaryBackground,
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppColors.primary),
            label: 'Lớp học',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            label: 'Lịch học',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded, color: AppColors.primary),
            label: 'Thông báo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
