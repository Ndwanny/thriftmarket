import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand color
  static const Color primary = Color(0xFF6C3CE1);
  static const Color primaryLight = Color(0xFF9B72F0);
  static const Color primaryDark = Color(0xFF4A1DB8);
  static const Color primaryContainer = Color(0xFFEDE7FF);

  // Secondary / accent
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryLight = Color(0xFFFF9A6C);
  static const Color secondaryDark = Color(0xFFCC4A15);
  static const Color secondaryContainer = Color(0xFFFFEDE7);

  // Neutral
  static const Color black = Color(0xFF0D0D0D);
  static const Color grey900 = Color(0xFF1A1A2E);
  static const Color grey800 = Color(0xFF2D2D44);
  static const Color grey700 = Color(0xFF4A4A68);
  static const Color grey600 = Color(0xFF6B6B8A);
  static const Color grey500 = Color(0xFF9090A8);
  static const Color grey400 = Color(0xFFB0B0C8);
  static const Color grey300 = Color(0xFFD0D0E0);
  static const Color grey200 = Color(0xFFE8E8F0);
  static const Color grey100 = Color(0xFFF4F4F8);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Background
  static const Color background = Color(0xFFF8F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EEF8);
  static const Color backgroundDark = Color(0xFF0F0E17);
  static const Color surfaceDark = Color(0xFF1A1928);
  static const Color surfaceVariantDark = Color(0xFF252436);

  // Vendor-specific
  static const Color vendorBadge = Color(0xFF10B981);
  static const Color vendorBadgeLight = Color(0xFFD1FAE5);
  static const Color featured = Color(0xFFFFD700);
  static const Color discount = Color(0xFFFF4757);

  // Rating
  static const Color starFilled = Color(0xFFFFC107);
  static const Color starEmpty = Color(0xFFE0E0E0);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C3CE1), Color(0xFF9B72F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFAA60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF6C3CE1), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
