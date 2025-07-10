import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Helper class for localization with fallback values
class LocalizationHelper {
  
  /// Get localized string with fallback
  static String getString(BuildContext context, String fallback) {
    final l10n = AppLocalizations.of(context);
    return fallback; // For now, use fallback until we add new keys to localization
  }

  /// Common validation messages
  static String passwordMinLength(BuildContext context) {
    return 'Password must be at least 6 characters';
  }

  static String forgotPassword(BuildContext context) {
    return 'Forgot Password?';
  }

  static String orDivider(BuildContext context) {
    return 'OR';
  }

  static String continueWithGoogle(BuildContext context) {
    return 'Continue with Google';
  }

  static String googleSignInComingSoon(BuildContext context) {
    return 'Google Sign In coming soon!';
  }

  /// Common UI strings
  static String searchFunctionalityComingSoon(BuildContext context) {
    return 'Search functionality coming soon!';
  }

  static String notificationsComingSoon(BuildContext context) {
    return 'Notifications coming soon!';
  }

  static String locationPickerComingSoon(BuildContext context) {
    return 'Location picker coming soon!';
  }

  /// Checkout related strings
  static String useCurrentLocation(BuildContext context) {
    return 'Use Current Location';
  }

  static String enterDeliveryAddress(BuildContext context) {
    return 'Enter your delivery address';
  }

  static String deliveryAddressRequired(BuildContext context) {
    return 'Please enter your delivery address';
  }
}