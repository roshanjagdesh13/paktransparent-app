import 'package:flutter/material.dart';

/// App theme configuration.
/// Color palette matches the original design reference screenshots.
class AppTheme {
  AppTheme._();

  // ─── Brand Colors (from design reference) ─────────────────────────────────
  static const Color _primary = Color(0xFF004B00);       // Deep green (Pakistan)
  static const Color _primaryContainer = Color(0xFF78FA55);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onPrimaryContainer = Color(0xFF002200);

  static const Color _secondary = Color(0xFF286C1E);
  static const Color _secondaryContainer = Color(0xFFA8F48D);
  static const Color _onSecondary = Color(0xFFFFFFFF);
  static const Color _onSecondaryContainer = Color(0xFF002200);

  static const Color _tertiary = Color(0xFF003D87);      // Deep blue (govt)
  static const Color _tertiaryContainer = Color(0xFFD8E2FF);
  static const Color _onTertiary = Color(0xFFFFFFFF);
  static const Color _onTertiaryContainer = Color(0xFF001945);

  static const Color _error = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);
  static const Color _onError = Color(0xFFFFFFFF);
  static const Color _onErrorContainer = Color(0xFF410002);

  // Surface / Background
  static const Color _background = Color(0xFFF6FBF1);
  static const Color _onBackground = Color(0xFF1A1C19);
  static const Color _surface = Color(0xFFF6FBF1);
  static const Color _onSurface = Color(0xFF1A1C19);
  static const Color _surfaceVariant = Color(0xFFDEE4D8);
  static const Color _onSurfaceVariant = Color(0xFF424940);
  static const Color _outline = Color(0xFF72796F);

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: _onPrimary,
      primaryContainer: _primaryContainer,
      onPrimaryContainer: _onPrimaryContainer,
      secondary: _secondary,
      onSecondary: _onSecondary,
      secondaryContainer: _secondaryContainer,
      onSecondaryContainer: _onSecondaryContainer,
      tertiary: _tertiary,
      onTertiary: _onTertiary,
      tertiaryContainer: _tertiaryContainer,
      onTertiaryContainer: _onTertiaryContainer,
      error: _error,
      onError: _onError,
      errorContainer: _errorContainer,
      onErrorContainer: _onErrorContainer,
      surface: _surface,
      onSurface: _onSurface,
      surfaceContainerHighest: _surfaceVariant,
      onSurfaceVariant: _onSurfaceVariant,
      outline: _outline,
    );

    return _buildTheme(colorScheme);
  }

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF5DDD42),
      onPrimary: const Color(0xFF003A00),
      primaryContainer: const Color(0xFF005300),
      onPrimaryContainer: const Color(0xFF78FA55),
      secondary: const Color(0xFF8CD773),
      onSecondary: const Color(0xFF003A00),
      secondaryContainer: const Color(0xFF0F5304),
      onSecondaryContainer: _secondaryContainer,
      tertiary: const Color(0xFFAFC6FF),
      onTertiary: const Color(0xFF002D6E),
      tertiaryContainer: const Color(0xFF003DA3),
      onTertiaryContainer: _tertiaryContainer,
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: const Color(0xFF1A1C19),
      onSurface: const Color(0xFFE2E3DC),
      surfaceContainerHighest: const Color(0xFF424940),
      onSurfaceVariant: const Color(0xFFC2C9BD),
      outline: const Color(0xFF8C9388),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          minimumSize: const Size(88, 52),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          minimumSize: const Size(88, 52),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input / TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          );
        }),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.3),
        thickness: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
    );
  }
}
