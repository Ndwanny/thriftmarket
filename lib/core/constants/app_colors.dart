import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand color - Golden Yellow
  static const Color primary = Color(0xFFE8C61E);
  static const Color primaryLight = Color(0xFFF0D86E);
  static const Color primaryDark = Color(0xFFC4A018);
  static const Color primaryContainer = Color(0xFFFDF8DC);

  // Secondary - Pure Black
  static const Color secondary = Color(0xFF0D0D0D);
  static const Color secondaryLight = Color(0xFF2D2D2D);
  static const Color secondaryDark = Color(0xFF000000);
  static const Color secondaryContainer = Color(0xFFF0F0F0);

  // Neutral
  static const Color black = Color(0xFF0D0D0D);
  static const Color grey900 = Color(0xFF1A1A1A);
  static const Color grey800 = Color(0xFF2D2D2D);
  static const Color grey700 = Color(0xFF4A4A4A);
  static const Color grey600 = Color(0xFF6B6B6B);
  static const Color grey500 = Color(0xFF909090);
  static const Color grey400 = Color(0xFFB0B0B0);
  static const Color grey300 = Color(0xFFD0D0D0);
  static const Color grey200 = Color(0xFFE8E8E8);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFE8C61E);
  static const Color warningLight = Color(0xFFFDF8DC);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariantDark = Color(0xFF2D2D2D);

  // Vendor-specific
  static const Color vendorBadge = Color(0xFFE8C61E);
  static const Color vendorBadgeLight = Color(0xFFFDF8DC);
  static const Color featured = Color(0xFFE8C61E);
  static const Color discount = Color(0xFF0D0D0D);

  // Rating
  static const Color starFilled = Color(0xFFE8C61E);
  static const Color starEmpty = Color(0xFFE0E0E0);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF2D2D2D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFE8C61E), Color(0xFFF0D86E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
