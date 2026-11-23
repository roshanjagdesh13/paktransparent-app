import 'package:flutter/material.dart';

/// App-wide constants derived from the original TypeScript constants/index.ts
/// All browser-specific values removed and replaced with Dart equivalents.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // App Info
  static const String appName = 'PakTransparent';
  static const String appDescription =
      'Pakistan Public Budget Tracker & Transparency Platform';
  static const String appVersion = '1.0.0';

  // API — override via flavor/build config for prod
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/api');
  static const int apiTimeoutMs = 30000;
  static const int apiRetryAttempts = 3;

  // Currency
  static const String currencyCode = 'PKR';
  static const String currencySymbol = 'Rs';
  static const String currencyLocale = 'en-PK';

  // Date formats (used with intl package)
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String monthYearFormat = 'MMM yyyy';

  // Timezone
  static const String timezone = 'Asia/Karachi';

  // Pagination
  static const int defaultPageSize = 20;
  static const List<int> pageSizeOptions = [10, 20, 50, 100];

  // File Upload Limits
  static const int maxFileSizeBytes = 52428800; // 50 MB
  static const int maxFiles = 10;
  static const List<String> acceptedImageTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
  ];
  static const List<String> acceptedVideoTypes = [
    'video/mp4',
    'video/webm',
    'video/quicktime',
  ];
  static const List<String> acceptedDocumentTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ];

  // Fiscal years
  static const String currentFiscalYear = '2024-2025';
  static const List<String> fiscalYears = [
    '2024-2025',
    '2023-2024',
    '2022-2023',
    '2021-2022',
    '2020-2021',
  ];

  // Map defaults (Pakistan center)
  static const double mapDefaultLat = 30.3753;
  static const double mapDefaultLng = 69.3451;
  static const double mapDefaultZoom = 6.0;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Notification durations
  static const Duration notifSuccess = Duration(seconds: 3);
  static const Duration notifError = Duration(seconds: 5);
  static const Duration notifWarning = Duration(seconds: 4);

  // Provinces
  static const Map<String, String> provinces = {
    'punjab': 'Punjab',
    'sindh': 'Sindh',
    'kpk': 'Khyber Pakhtunkhwa',
    'balochistan': 'Balochistan',
    'gilgit_baltistan': 'Gilgit-Baltistan',
    'azad_kashmir': 'Azad Kashmir',
  };

  // Project categories
  static const Map<String, String> projectCategories = {
    'infrastructure': 'Infrastructure',
    'education': 'Education',
    'healthcare': 'Healthcare',
    'transport': 'Transport',
    'energy': 'Energy',
    'water': 'Water & Sanitation',
    'agriculture': 'Agriculture',
    'defense': 'Defense',
    'social_welfare': 'Social Welfare',
    'other': 'Other',
  };

  // Report categories
  static const Map<String, String> reportCategories = {
    'delay': 'Project Delay',
    'quality': 'Quality Issues',
    'corruption': 'Corruption',
    'mismanagement': 'Mismanagement',
    'safety': 'Safety Concerns',
    'environmental': 'Environmental Issues',
    'other': 'Other',
  };

  // Chart colors (matching original design palette)
  static const Color chartPrimary = Color(0xFF004B00);
  static const Color chartSecondary = Color(0xFF286C1E);
  static const Color chartTertiary = Color(0xFF003D87);
  static const Color chartSuccess = Color(0xFF81DB6E);
  static const Color chartWarning = Color(0xFFF59E0B);
  static const Color chartError = Color(0xFFBA1A1A);
  static const Color chartGray = Color(0xFF707A6A);

  // Shared prefs / secure storage keys
  static const String keyTheme = 'pak_transparent_theme';
  static const String keyLanguage = 'pak_transparent_lang';
  static const String keyRecentSearches = 'pak_transparent_recent_searches';
  static const String keyBookmarks = 'pak_transparent_bookmarks';
  static const String keyAuthToken = 'pak_transparent_token';
  static const String keyRefreshToken = 'pak_transparent_refresh';
  static const String keyUserData = 'pak_transparent_user';
  static const String keyOnboardingDone = 'pak_transparent_onboarding';

  // Security
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const int sessionDurationHours = 24;
  static const int inactivityTimeoutMinutes = 30;
  static const int passwordMinLength = 8;

  // Sample data feature flag (disable in prod)
  static const bool showSampleData =
      bool.fromEnvironment('SHOW_SAMPLE_DATA', defaultValue: true);
}
