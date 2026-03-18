class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://api.yourmarketplace.com/v1';
  static const String wsUrl = 'wss://api.yourmarketplace.com';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'current_user';
  static const String onboardingKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String cartKey = 'cart_items';
  static const String searchHistoryKey = 'search_history';
  static const String deviceTokenKey = 'device_fcm_token';

  // Hive boxes
  static const String cartBox = 'cart_box';
  static const String wishlistBox = 'wishlist_box';
  static const String productCacheBox = 'product_cache_box';
  static const String userBox = 'user_box';
  static const String searchBox = 'search_box';

  // Pagination
  static const int pageSize = 20;
  static const int searchPageSize = 15;

  // Product
  static const int maxCartQuantity = 99;
  static const int maxReviewLength = 500;
  static const int maxProductImages = 8;
  static const int searchHistoryLimit = 10;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 64;
  static const int otpLength = 6;
  static const int phoneLength = 10;

  // Commission
  static const double defaultCommissionRate = 0.10; // 10%

  // Timeouts
  static const int otpExpiryMinutes = 10;
  static const int sessionExpiryDays = 30;

  // Animations
  static const int defaultAnimationMs = 300;
  static const int slowAnimationMs = 600;
  static const int fastAnimationMs = 150;

  // Image compression
  static const int imageQuality = 80;
  static const int maxImageSizeKb = 2048;

  // Map
  static const double defaultLatitude = -15.4166;
  static const double defaultLongitude = 28.2833; // Lusaka, Zambia
  static const double defaultMapZoom = 14.0;

  // Support
  static const String supportEmail = 'support@yourmarketplace.com';
  static const String supportPhone = '+260 XXX XXX XXX';
  static const String whatsappSupport = '+260XXXXXXXXX';
}
