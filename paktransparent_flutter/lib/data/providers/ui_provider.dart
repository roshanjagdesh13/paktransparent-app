import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// UI state provider — manages theme mode and language selection.
/// Persists user preferences across app restarts.
class UiProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en', 'US');

  UiProvider({required SharedPreferences prefs}) : _prefs = prefs {
    _loadPreferences();
  }

  // ─── Getters ───────────────────────────────────────────────────────────────
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isUrdu => _locale.languageCode == 'ur';
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ─── Load Preferences ──────────────────────────────────────────────────────
  void _loadPreferences() {
    final themeStr = _prefs.getString(AppConstants.keyTheme);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == themeStr,
        orElse: () => ThemeMode.light,
      );
    }

    final langCode = _prefs.getString(AppConstants.keyLanguage);
    if (langCode == 'ur') {
      _locale = const Locale('ur', 'PK');
    } else {
      _locale = const Locale('en', 'US');
    }

    notifyListeners();
  }

  // ─── Theme Mode ────────────────────────────────────────────────────────────
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(AppConstants.keyTheme, mode.name);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  // ─── Language ──────────────────────────────────────────────────────────────
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString(AppConstants.keyLanguage, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'en'
        ? const Locale('ur', 'PK')
        : const Locale('en', 'US');
    await setLocale(newLocale);
  }

  // ─── Onboarding ────────────────────────────────────────────────────────────
  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
  }

  Future<void> markOnboardingComplete() async {
    await _prefs.setBool(AppConstants.keyOnboardingDone, true);
  }

  // ─── Recent Searches ───────────────────────────────────────────────────────
  List<String> getRecentSearches() {
    return _prefs.getStringList(AppConstants.keyRecentSearches) ?? [];
  }

  Future<void> addRecentSearch(String query) async {
    final searches = getRecentSearches();
    searches.remove(query); // Remove if exists
    searches.insert(0, query);
    if (searches.length > 10) {
      searches.removeRange(10, searches.length);
    }
    await _prefs.setStringList(AppConstants.keyRecentSearches, searches);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(AppConstants.keyRecentSearches);
    notifyListeners();
  }

  // ─── Bookmarks ─────────────────────────────────────────────────────────────
  List<String> getBookmarkedProjects() {
    return _prefs.getStringList(AppConstants.keyBookmarks) ?? [];
  }

  Future<void> toggleBookmark(String projectId) async {
    final bookmarks = getBookmarkedProjects();
    if (bookmarks.contains(projectId)) {
      bookmarks.remove(projectId);
    } else {
      bookmarks.add(projectId);
    }
    await _prefs.setStringList(AppConstants.keyBookmarks, bookmarks);
    notifyListeners();
  }

  bool isBookmarked(String projectId) {
    return getBookmarkedProjects().contains(projectId);
  }
}
