import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  await NotificationService().initialize(null);
  runApp(const LearningHubApp());
}
