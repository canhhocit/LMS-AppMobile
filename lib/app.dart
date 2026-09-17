import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'feature/auth/login_screen.dart';

class LearningHubApp extends StatelessWidget {
  const LearningHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearningHub Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
