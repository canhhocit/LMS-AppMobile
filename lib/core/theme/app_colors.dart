import 'package:flutter/material.dart';
import '../../app.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4338CA); // Indigo 700
  static const Color primaryBackground = Color(0xFFEEF2FF); // Indigo 50

  // Secondary & Accents
  static const Color secondary = Color(0xFF38BDF8); // Sky 400 (Brighter for Dark Mode)
  static const Color accent = Color(0xFF34D399); // Emerald 400
  static const Color warning = Color(0xFFFBBF24); // Amber 400
  static const Color danger = Color(0xFFF87171); // Rose 400

  // Standard Semantic Colors
  static const Color error = Color(0xFFF87171); // Red / Rose
  static const Color success = Color(0xFF34D399); // Green / Emerald
  static const Color info = Color(0xFF38BDF8); // Blue / Sky

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
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Neutral Colors - High-Contrast Dark Mode (Deep OLED Midnight Slate)
  static const Color darkBackground = Color(0xFF090D16); // Ultra Deep Midnight OLED
  static const Color darkSurface = Color(0xFF151D2A); // Slate 900 Container
  static const Color darkCard = Color(0xFF151D2A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Pure High-Contrast White
  static const Color darkTextSecondary = Color(0xFFE2E8F0); // Slate 200 Crisp Light Neutral
  static const Color darkTextMuted = Color(0xFFA0AEC0); // Slate 400 Soft Muted Light
  static const Color darkBorder = Color(0xFF2D3748); // Slate 700 Outline
  static const Color darkPrimaryBg = Color(0xFF1E293B); // Slate 800 Container Background

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
  static bool isDark([BuildContext? context]) {
    if (context != null) {
      return Theme.of(context).brightness == Brightness.dark;
    }
    return themeNotifier.value == ThemeMode.dark;
  }

  static Color get dynamicTextPrimary => isDark() ? darkTextPrimary : textPrimary;
  static Color get dynamicTextSecondary => isDark() ? darkTextSecondary : textSecondary;
  static Color get dynamicTextMuted => isDark() ? darkTextMuted : textMuted;
  static Color get dynamicSurface => isDark() ? darkSurface : surface;
  static Color get dynamicBackground => isDark() ? darkBackground : background;
  static Color get dynamicBorder => isDark() ? darkBorder : border;
  static Color get dynamicPrimaryBg => isDark() ? darkPrimaryBg : primaryBackground;

  static Color surfaceColor([BuildContext? context]) => isDark(context) ? darkSurface : surface;
  static Color backgroundColor([BuildContext? context]) => isDark(context) ? darkBackground : background;
  static Color textPrimaryColor([BuildContext? context]) => isDark(context) ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor([BuildContext? context]) => isDark(context) ? darkTextSecondary : textSecondary;
  static Color textMutedColor([BuildContext? context]) => isDark(context) ? darkTextMuted : textMuted;
  static Color borderColor([BuildContext? context]) => isDark(context) ? darkBorder : border;
  static Color primaryBgColor([BuildContext? context]) => isDark(context) ? darkPrimaryBg : primaryBackground;
}
