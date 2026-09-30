import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4338CA); // Indigo 700
  static const Color primaryBackground = Color(0xFFEEF2FF); // Indigo 50

  // Secondary & Accents
  static const Color secondary = Color(0xFF0EA5E9); // Sky 500
  static const Color accent = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color danger = Color(0xFFEF4444); // Rose 500

  // Standard Semantic Colors
  static const Color error = Color(0xFFEF4444); // Red / Rose
  static const Color success = Color(0xFF10B981); // Green / Emerald
  static const Color info = Color(0xFF0EA5E9); // Blue / Sky

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neutral Colors - Light Mode
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Neutral Colors - Premium Dark Mode (Deep OLED Midnight Slate)
  static const Color darkBackground = Color(0xFF0B0F17); // Rich Deep Midnight
  static const Color darkSurface = Color(0xFF161E2E); // Slate 900 Container
  static const Color darkCard = Color(0xFF161E2E);
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Slate 100
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate 500
  static const Color darkBorder = Color(0xFF26334D); // Dark Border Line
  static const Color darkPrimaryBg = Color(0xFF1E1B4B); // Deep Indigo Highlight

  // Status Badges - Light Mode
  static const Color badgeGreenBg = Color(0xFFDCFCE7);
  static const Color badgeGreenText = Color(0xFF15803D);
  static const Color badgeAmberBg = Color(0xFFFEF3C7);
  static const Color badgeAmberText = Color(0xFFB45309);
  static const Color badgeRedBg = Color(0xFFFEE2E2);
  static const Color badgeRedText = Color(0xFFB91C1C);
  static const Color badgeIndigoBg = Color(0xFFE0E7FF);
  static const Color badgeIndigoText = Color(0xFF4338CA);

  // Dynamic Theme Helpers
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color surfaceColor(BuildContext context) => isDark(context) ? darkSurface : surface;
  static Color backgroundColor(BuildContext context) => isDark(context) ? darkBackground : background;
  static Color textPrimaryColor(BuildContext context) => isDark(context) ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(BuildContext context) => isDark(context) ? darkTextSecondary : textSecondary;
  static Color textMutedColor(BuildContext context) => isDark(context) ? darkTextMuted : textMuted;
  static Color borderColor(BuildContext context) => isDark(context) ? darkBorder : border;
  static Color primaryBgColor(BuildContext context) => isDark(context) ? darkPrimaryBg : primaryBackground;
}
