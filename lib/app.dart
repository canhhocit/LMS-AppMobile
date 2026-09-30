import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'feature/auth/splash_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class LearningHubApp extends StatelessWidget {
  const LearningHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'LearningHub Mobile',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          home: const SplashScreen(),
        );
      },
    );
  }
}
