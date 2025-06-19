import 'package:flutter/material.dart';
import 'storage_service.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'en';

  /// Get the current language code
  static Future<String> getLanguage() async {
    final language = StorageService.getString(_languageKey);
    return language ?? _defaultLanguage;
  }

  /// Set the language code
  static Future<void> setLanguage(String languageCode) async {
    await StorageService.setString(_languageKey, languageCode);
  }

  /// Check if language has been set before
  static Future<bool> hasLanguageBeenSet() async {
    final language = StorageService.getString(_languageKey);
    return language != null;
  }

  /// Get supported locales
  static List<Locale> getSupportedLocales() {
    return const [
      Locale('en'),
      Locale('ru'), 
      Locale('uz'),
    ];
  }

  /// Get language name by code
  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'uz':
        return 'O\'zbek';
      default:
        return 'English';
    }
  }

  /// Get language native name by code
  static String getLanguageNativeName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'uz':
        return 'O\'zbek';
      default:
        return 'English';
    }
  }

  /// Get language flag emoji by code
  static String getLanguageFlag(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'ru':
        return '🇷🇺';
      case 'uz':
        return '🇺🇿';
      default:
        return '🇺🇸';
    }
  }

  /// Clear language preference (for testing/reset)
  static Future<void> clearLanguage() async {
    await StorageService.remove(_languageKey);
  }
}