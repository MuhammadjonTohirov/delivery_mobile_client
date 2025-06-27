import 'package:intl/intl.dart';

class DateFormatter {
  // Standard date formats
  static final DateFormat _dateOnly = DateFormat('MMM d, yyyy');
  static final DateFormat _timeOnly = DateFormat('h:mm a');
  static final DateFormat _shortDate = DateFormat('MM/dd/yyyy');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  
  // Localized formatters
  static final Map<String, DateFormat> _localizedDateFormats = {
    'en': DateFormat('MMM d, yyyy', 'en'),
    'ru': DateFormat('d MMM yyyy', 'ru'),
    'uz': DateFormat('d-MMM, yyyy', 'uz'),
  };

  static final Map<String, DateFormat> _localizedTimeFormats = {
    'en': DateFormat('h:mm a', 'en'),
    'ru': DateFormat('HH:mm', 'ru'),
    'uz': DateFormat('HH:mm', 'uz'),
  };

  /// Format date only (e.g., "Jan 15, 2024")
  static String formatDate(DateTime date, [String locale = 'en']) {
    final formatter = _localizedDateFormats[locale] ?? _dateOnly;
    return formatter.format(date);
  }

  /// Format time only (e.g., "2:30 PM")
  static String formatTime(DateTime date, [String locale = 'en']) {
    final formatter = _localizedTimeFormats[locale] ?? _timeOnly;
    return formatter.format(date);
  }

  /// Format date and time (e.g., "Jan 15, 2024 • 2:30 PM")
  static String formatDateTime(DateTime date, [String locale = 'en']) {
    final dateStr = formatDate(date, locale);
    final timeStr = formatTime(date, locale);
    return '$dateStr • $timeStr';
  }

  /// Format short date (e.g., "01/15/2024")
  static String formatShortDate(DateTime date) {
    return _shortDate.format(date);
  }

  /// Format ISO date (e.g., "2024-01-15")
  static String formatISODate(DateTime date) {
    return _isoDate.format(date);
  }

  /// Format relative time (e.g., "2 hours ago", "3 days ago")
  static String formatRelativeTime(DateTime date, [String locale = 'en']) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return _getLocalizedText('justNow', locale);
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return _getLocalizedText('minutesAgo', locale, minutes);
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return _getLocalizedText('hoursAgo', locale, hours);
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return _getLocalizedText('daysAgo', locale, days);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return _getLocalizedText('weeksAgo', locale, weeks);
    } else {
      return formatDate(date, locale);
    }
  }

  /// Format order date for display
  static String formatOrderDate(DateTime date, [String locale = 'en']) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate == today) {
      return '${_getLocalizedText('today', locale)} • ${formatTime(date, locale)}';
    } else if (orderDate == yesterday) {
      return '${_getLocalizedText('yesterday', locale)} • ${formatTime(date, locale)}';
    } else {
      return formatDateTime(date, locale);
    }
  }

  /// Format delivery time estimate
  static String formatDeliveryTime(int minutes, [String locale = 'en']) {
    if (minutes < 60) {
      return _getLocalizedText('deliveryMinutes', locale, minutes);
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return _getLocalizedText('deliveryHours', locale, hours);
      } else {
        return _getLocalizedText('deliveryHoursMinutes', locale, hours, remainingMinutes);
      }
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if date is within the last week
  static bool isWithinLastWeek(DateTime date) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return date.isAfter(weekAgo);
  }

  /// Parse date string in various formats
  static DateTime? parseDate(String dateString) {
    try {
      // Try ISO format first
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        // Try other common formats
        return _shortDate.parse(dateString);
      } catch (e) {
        return null;
      }
    }
  }

  /// Get localized text for relative time
  static String _getLocalizedText(String key, String locale, [int? value1, int? value2]) {
    final texts = <String, Map<String, String>>{
      'justNow': {
        'en': 'Just now',
        'ru': 'Только что',
        'uz': 'Hozir',
      },
      'minutesAgo': {
        'en': '${value1}m ago',
        'ru': '$value1 мин назад',
        'uz': '$value1 daq oldin',
      },
      'hoursAgo': {
        'en': '${value1}h ago',
        'ru': '$value1 ч назад',
        'uz': '$value1 soat oldin',
      },
      'daysAgo': {
        'en': '${value1}d ago',
        'ru': '$value1 дн назад',
        'uz': '$value1 kun oldin',
      },
      'weeksAgo': {
        'en': '${value1}w ago',
        'ru': '$value1 нед назад',
        'uz': '$value1 hafta oldin',
      },
      'today': {
        'en': 'Today',
        'ru': 'Сегодня',
        'uz': 'Bugun',
      },
      'yesterday': {
        'en': 'Yesterday',
        'ru': 'Вчера',
        'uz': 'Kecha',
      },
      'deliveryMinutes': {
        'en': '$value1 min',
        'ru': '$value1 мин',
        'uz': '$value1 daq',
      },
      'deliveryHours': {
        'en': '${value1}h',
        'ru': '$value1 ч',
        'uz': '$value1 soat',
      },
      'deliveryHoursMinutes': {
        'en': '${value1}h ${value2}m',
        'ru': '$value1 ч $value2 мин',
        'uz': '$value1 soat $value2 daq',
      },
    };

    return texts[key]?[locale] ?? texts[key]?['en'] ?? key;
  }
}