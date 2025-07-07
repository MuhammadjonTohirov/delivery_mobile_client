import 'package:intl/intl.dart';
import '../../../core/models/models.dart';

class CurrencyFormatter {
  static final NumberFormat _usdFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _rubFormatter = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: '₽',
    decimalDigits: 2,
  );

  static final NumberFormat _uzbFormatter = NumberFormat.currency(
    locale: 'uz_UZ',
    symbol: 'сўм',
    decimalDigits: 0,
  );

  /// Format amount as USD currency
  static String formatUSD(double amount) {
    return _usdFormatter.format(amount);
  }

  /// Format amount as RUB currency
  static String formatRUB(double amount) {
    return _rubFormatter.format(amount);
  }

  /// Format amount as UZB sum currency
  static String formatUZB(double amount) {
    return _uzbFormatter.format(amount);
  }

  /// Format amount based on locale
  static String formatByLocale(double amount, String locale) {
    switch (locale.toLowerCase()) {
      case 'ru':
        return formatRUB(amount);
      case 'uz':
        return formatUZB(amount);
      case 'en':
      default:
        return formatUSD(amount);
    }
  }

  /// Format amount with CurrencyInfo from server
  static String formatWithCurrencyInfo(double amount, CurrencyInfo currencyInfo) {
    return currencyInfo.formatPrice(amount);
  }

  /// Format amount with dynamic currency information from server
  static String formatWithCurrency(double amount, {
    String? currencyCode,
    String? currencySymbol,
    String? locale,
  }) {
    // If currency info provided from server, use it
    if (currencyCode != null || currencySymbol != null) {
      final symbol = currencySymbol ?? _getSymbolForCurrencyCode(currencyCode);
      final localeCode = locale ?? _getLocaleForCurrencyCode(currencyCode);
      
      final formatter = NumberFormat.currency(
        locale: localeCode,
        symbol: symbol,
        decimalDigits: _getDecimalDigitsForCurrency(currencyCode),
      );
      return formatter.format(amount);
    }
    
    // Fallback to locale-based formatting
    return formatByLocale(amount, locale ?? 'en');
  }

  /// Format amount as compact currency (e.g., $1.2K)
  static String formatCompact(double amount, [String locale = 'en']) {
    final formatter = NumberFormat.compactCurrency(
      locale: locale,
      symbol: _getSymbolForLocale(locale),
    );
    return formatter.format(amount);
  }

  /// Get currency symbol for locale
  static String _getSymbolForLocale(String locale) {
    switch (locale.toLowerCase()) {
      case 'ru':
        return '₽';
      case 'uz':
        return 'сўм';
      case 'en':
      default:
        return '\$';
    }
  }

  /// Parse currency string to double
  static double? parseCurrency(String currencyString) {
    // Remove currency symbols and spaces
    final cleanString = currencyString
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAll(',', '.');
    
    return double.tryParse(cleanString);
  }

  /// Check if amount is valid for currency operations
  static bool isValidAmount(double? amount) {
    return amount != null && amount >= 0 && amount.isFinite;
  }

  /// Get currency symbol from currency code
  static String _getSymbolForCurrencyCode(String? currencyCode) {
    if (currencyCode == null) return '\$';
    
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'RUB':
        return '₽';
      case 'UZS':
        return 'сўм';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currencyCode.toUpperCase();
    }
  }

  /// Get locale from currency code
  static String _getLocaleForCurrencyCode(String? currencyCode) {
    if (currencyCode == null) return 'en_US';
    
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return 'en_US';
      case 'RUB':
        return 'ru_RU';
      case 'UZS':
        return 'uz_UZ';
      case 'EUR':
        return 'en_EU';
      case 'GBP':
        return 'en_GB';
      default:
        return 'en_US';
    }
  }

  /// Get decimal digits for currency
  static int _getDecimalDigitsForCurrency(String? currencyCode) {
    if (currencyCode == null) return 2;
    
    switch (currencyCode.toUpperCase()) {
      case 'UZS':
        return 0;
      default:
        return 2;
    }
  }
}