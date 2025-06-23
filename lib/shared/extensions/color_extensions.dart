import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Extension on Color for additional utilities
extension ColorExtensions on Color {
  
  // =============================================================================
  // BRIGHTNESS & CONTRAST
  // =============================================================================
  
  /// Get a lighter version of the color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Get a darker version of the color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Get the complementary color
  Color get complement {
    final hsl = HSLColor.fromColor(this);
    final hue = (hsl.hue + 180) % 360;
    return hsl.withHue(hue).toColor();
  }

  /// Check if color is dark
  bool get isDark {
    final brightness = ThemeData.estimateBrightnessForColor(this);
    return brightness == Brightness.dark;
  }

  /// Check if color is light
  bool get isLight => !isDark;

  /// Get contrasting text color (black or white)
  Color get contrastText => isDark ? Colors.white : Colors.black;

  // =============================================================================
  // OPACITY HELPERS
  // =============================================================================
  
  /// Get color with specific opacity (0.0 to 1.0)
  Color withAlpha(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'Opacity must be between 0.0 and 1.0');
    return withOpacity(opacity);
  }

  /// Common opacity shortcuts
  Color get o10 => withOpacity(0.1);
  Color get o20 => withOpacity(0.2);
  Color get o30 => withOpacity(0.3);
  Color get o40 => withOpacity(0.4);
  Color get o50 => withOpacity(0.5);
  Color get o60 => withOpacity(0.6);
  Color get o70 => withOpacity(0.7);
  Color get o80 => withOpacity(0.8);
  Color get o90 => withOpacity(0.9);

  // =============================================================================
  // COLOR HARMONY
  // =============================================================================
  
  /// Get analogous colors (colors next to this color on color wheel)
  List<Color> get analogous {
    final hsl = HSLColor.fromColor(this);
    return [
      hsl.withHue((hsl.hue + 30) % 360).toColor(),
      hsl.withHue((hsl.hue - 30) % 360).toColor(),
    ];
  }

  /// Get triadic colors (colors equally spaced on color wheel)
  List<Color> get triadic {
    final hsl = HSLColor.fromColor(this);
    return [
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  /// Get split complementary colors
  List<Color> get splitComplementary {
    final hsl = HSLColor.fromColor(this);
    return [
      hsl.withHue((hsl.hue + 150) % 360).toColor(),
      hsl.withHue((hsl.hue + 210) % 360).toColor(),
    ];
  }

  // =============================================================================
  // MATERIAL DESIGN UTILITIES
  // =============================================================================
  
  /// Get material color swatch from this color
  MaterialColor get materialColor {
    final Map<int, Color> swatch = {
      50: lighten(0.4),
      100: lighten(0.3),
      200: lighten(0.2),
      300: lighten(0.1),
      400: lighten(0.05),
      500: this,
      600: darken(0.05),
      700: darken(0.1),
      800: darken(0.2),
      900: darken(0.3),
    };
    return MaterialColor(value, swatch);
  }

  /// Get color with material elevation overlay
  Color withElevation(double elevation, {Brightness brightness = Brightness.dark}) {
    if (brightness == Brightness.light) return this;
    
    final overlay = Colors.white.withOpacity(_elevationToOpacity(elevation));
    return Color.alphaBlend(overlay, this);
  }

  double _elevationToOpacity(double elevation) {
    // Material Design elevation overlay opacity calculation
    return (4.5 * math.log(elevation + 1) + 2) / 100;
  }
}

/// Extension for creating gradients easily
extension GradientExtensions on Color {
  
  /// Create linear gradient with another color
  LinearGradient linearGradientTo(Color endColor, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [this, endColor],
      stops: stops,
    );
  }

  /// Create radial gradient
  RadialGradient radialGradientTo(Color endColor, {
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
    List<double>? stops,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: [this, endColor],
      stops: stops,
    );
  }

  /// Create sweep gradient
  SweepGradient sweepGradientTo(Color endColor, {
    AlignmentGeometry center = Alignment.center,
    double startAngle = 0.0,
    double endAngle = math.pi * 2,
    List<double>? stops,
  }) {
    return SweepGradient(
      center: center,
      startAngle: startAngle,
      endAngle: endAngle,
      colors: [this, endColor],
      stops: stops,
    );
  }
}

/// Pre-defined color palettes for quick access
class AppColors {
  // =============================================================================
  // SEMANTIC COLORS
  // =============================================================================
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // =============================================================================
  // NEUTRAL COLORS
  // =============================================================================
  
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // =============================================================================
  // BRAND COLORS (customize these for your app)
  // =============================================================================
  
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryOrange = Color(0xFFF97316);

  // =============================================================================
  // BACKGROUND COLORS
  // =============================================================================
  
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF1F2937);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color surfaceDark = Color(0xFF374151);

  // =============================================================================
  // HELPER METHODS
  // =============================================================================
  
  /// Get color by name
  static Color? getColorByName(String name) {
    switch (name.toLowerCase()) {
      case 'success': return success;
      case 'warning': return warning;
      case 'error': return error;
      case 'info': return info;
      case 'primary': return primaryBlue;
      case 'green': return primaryGreen;
      case 'purple': return primaryPurple;
      case 'orange': return primaryOrange;
      default: return null;
    }
  }

  /// Generate color palette from hex string
  static MaterialColor createMaterialColor(String hexColor) {
    final color = Color(int.parse('0xFF${hexColor.replaceAll('#', '')}'));
    return color.materialColor;
  }
}

/// Extension for hex color strings
extension HexColor on String {
  
  /// Convert hex string to Color
  Color get hexColor {
    String hex = replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha if not present
    }
    return Color(int.parse(hex, radix: 16));
  }
}

/// Extension for easier color manipulation
extension ColorHelpers on BuildContext {
  
  /// Get theme colors easily
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  /// Get specific theme colors
  Color get primaryColor => colors.primary;
  Color get secondaryColor => colors.secondary;
  Color get backgroundColor => colors.background;
  Color get surfaceColor => colors.surface;
  Color get errorColor => colors.error;
  
  /// Get text colors based on theme
  Color get textPrimary => colors.onSurface;
  Color get textSecondary => colors.onSurface.withOpacity(0.7);
  Color get textDisabled => colors.onSurface.withOpacity(0.4);
  
  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Get contrasting color for current theme
  Color get onBackground => colors.onBackground;
  Color get onSurface => colors.onSurface;
}