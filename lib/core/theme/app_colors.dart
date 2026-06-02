import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary purple palette
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFEDE7FF);
  static const Color primaryMid = Color(0xFFB39DDB);

  // Accent green (Food Menu)
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentGreenLight = Color(0xFFE8F5E9);

  // Accent pink
  static const Color accentPink = Color(0xFFFF80AB);
  static const Color accentPinkLight = Color(0xFFFCE4EC);

  // Accent orange
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentOrangeLight = Color(0xFFFFF3E0);

  // Accent blue
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color accentBlueLight = Color(0xFFE3F2FD);

  // Neutrals
  static const Color background = Color(0xFFF8F6FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFEF5350);

  // Bottom nav
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navSelected = Color(0xFF7C4DFF);
  static const Color navUnselected = Color(0xFFB0B7C3);

  // Divider
  static const Color divider = Color(0xFFF0EEF8);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF9C6FFF), Color(0xFF7C4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softPurpleGradient = LinearGradient(
    colors: [Color(0xFFF3EEFF), Color(0xFFEDE7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGreenGradient = LinearGradient(
    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
