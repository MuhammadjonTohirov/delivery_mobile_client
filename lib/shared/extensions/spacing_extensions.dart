import 'package:flutter/material.dart';

/// Spacing utilities for consistent layout design
class AppSpacing {
  // =============================================================================
  // SPACING CONSTANTS
  // =============================================================================
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // =============================================================================
  // SIZEDBOX UTILITIES
  // =============================================================================
  
  /// Horizontal spacing
  static const Widget h4 = SizedBox(width: xs);
  static const Widget h8 = SizedBox(width: sm);
  static const Widget h16 = SizedBox(width: md);
  static const Widget h24 = SizedBox(width: lg);
  static const Widget h32 = SizedBox(width: xl);
  static const Widget h48 = SizedBox(width: xxl);
  static const Widget h64 = SizedBox(width: xxxl);

  /// Vertical spacing
  static const Widget v4 = SizedBox(height: xs);
  static const Widget v8 = SizedBox(height: sm);
  static const Widget v16 = SizedBox(height: md);
  static const Widget v24 = SizedBox(height: lg);
  static const Widget v32 = SizedBox(height: xl);
  static const Widget v48 = SizedBox(height: xxl);
  static const Widget v64 = SizedBox(height: xxxl);

  // =============================================================================
  // CUSTOM SPACING
  // =============================================================================
  
  /// Custom horizontal spacing
  static Widget horizontal(double width) => SizedBox(width: width);
  
  /// Custom vertical spacing
  static Widget vertical(double height) => SizedBox(height: height);
  
  /// Square spacing
  static Widget square(double size) => SizedBox(width: size, height: size);

  // =============================================================================
  // EDGEINSETS UTILITIES
  // =============================================================================
  
  /// All sides padding
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  /// Horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  /// Vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  /// Combined padding shortcuts
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: lg, vertical: sm);
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);

  // =============================================================================
  // HELPER METHODS
  // =============================================================================
  
  /// Create custom EdgeInsets
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// Create symmetric EdgeInsets
  static EdgeInsets symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  /// Create EdgeInsets from LTRB values
  static EdgeInsets fromLTRB(double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }
}

/// Extension for easy spacing between widgets in lists
extension ListSpacingExtension<T extends Widget> on List<T> {
  
  /// Add spacing between list items
  List<Widget> withSpacing(double spacing) {
    if (isEmpty) return [];
    
    final List<Widget> result = [];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }

  /// Add horizontal spacing between list items
  List<Widget> withHorizontalSpacing(double spacing) {
    if (isEmpty) return [];
    
    final List<Widget> result = [];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(SizedBox(width: spacing));
      }
    }
    return result;
  }

  /// Add spacing using AppSpacing constants
  List<Widget> get withSmallSpacing => withSpacing(AppSpacing.sm);
  List<Widget> get withMediumSpacing => withSpacing(AppSpacing.md);
  List<Widget> get withLargeSpacing => withSpacing(AppSpacing.lg);

  /// Add horizontal spacing using AppSpacing constants
  List<Widget> get withSmallHorizontalSpacing => withHorizontalSpacing(AppSpacing.sm);
  List<Widget> get withMediumHorizontalSpacing => withHorizontalSpacing(AppSpacing.md);
  List<Widget> get withLargeHorizontalSpacing => withHorizontalSpacing(AppSpacing.lg);

  /// Add custom spacing widget between items
  List<Widget> withCustomSpacing(Widget spacer) {
    if (isEmpty) return [];
    
    final List<Widget> result = [];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(spacer);
      }
    }
    return result;
  }

  /// Add dividers between items
  List<Widget> get withDividers => withCustomSpacing(const Divider());
  
  /// Add custom dividers
  List<Widget> withCustomDividers({
    double? height,
    double? thickness,
    Color? color,
    double? indent,
    double? endIndent,
  }) {
    return withCustomSpacing(
      Divider(
        height: height,
        thickness: thickness,
        color: color,
        indent: indent,
        endIndent: endIndent,
      ),
    );
  }
}

/// Extension for easy Column and Row creation with spacing
extension SpacingBuilders on List<Widget> {
  
  /// Create a Column with spacing
  Widget asColumn({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double spacing = AppSpacing.md,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: withSpacing(spacing),
    );
  }

  /// Create a Row with spacing
  Widget asRow({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double spacing = AppSpacing.md,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: withHorizontalSpacing(spacing),
    );
  }

  /// Create a Wrap with spacing
  Widget asWrap({
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    double spacing = AppSpacing.sm,
    double runSpacing = AppSpacing.sm,
  }) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: this,
    );
  }

  /// Create a ListView with spacing
  Widget asListView({
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    double spacing = AppSpacing.sm,
  }) {
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      children: withSpacing(spacing),
    );
  }
}

/// Extension for responsive spacing based on screen size
extension ResponsiveSpacing on BuildContext {
  
  /// Get responsive spacing based on screen width
  double get responsiveSpacing {
    final width = MediaQuery.of(this).size.width;
    if (width < 600) return AppSpacing.sm;      // Mobile
    if (width < 1200) return AppSpacing.md;     // Tablet
    return AppSpacing.lg;                       // Desktop
  }

  /// Get responsive horizontal spacing
  double get responsiveHorizontalSpacing {
    final width = MediaQuery.of(this).size.width;
    if (width < 600) return AppSpacing.md;      // Mobile
    if (width < 1200) return AppSpacing.lg;     // Tablet
    return AppSpacing.xl;                       // Desktop
  }

  /// Get responsive vertical spacing
  double get responsiveVerticalSpacing {
    final height = MediaQuery.of(this).size.height;
    if (height < 600) return AppSpacing.sm;     // Small screens
    if (height < 900) return AppSpacing.md;     // Medium screens
    return AppSpacing.lg;                       // Large screens
  }

  /// Get responsive padding for screens
  EdgeInsets get responsiveScreenPadding {
    final width = MediaQuery.of(this).size.width;
    if (width < 600) {
      return const EdgeInsets.all(AppSpacing.md);
    } else if (width < 1200) {
      return const EdgeInsets.all(AppSpacing.lg);
    } else {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.lg,
      );
    }
  }

  /// Get responsive card padding
  EdgeInsets get responsiveCardPadding {
    final width = MediaQuery.of(this).size.width;
    if (width < 600) {
      return const EdgeInsets.all(AppSpacing.md);
    } else {
      return const EdgeInsets.all(AppSpacing.lg);
    }
  }
}

/// Quick spacing widgets for common use cases
class Space {
  /// Empty space (invisible)
  static const Widget empty = SizedBox.shrink();
  
  /// Minimal spacing
  static const Widget xs = SizedBox(height: AppSpacing.xs, width: AppSpacing.xs);
  static const Widget sm = SizedBox(height: AppSpacing.sm, width: AppSpacing.sm);
  static const Widget md = SizedBox(height: AppSpacing.md, width: AppSpacing.md);
  static const Widget lg = SizedBox(height: AppSpacing.lg, width: AppSpacing.lg);
  static const Widget xl = SizedBox(height: AppSpacing.xl, width: AppSpacing.xl);
  
  /// Flexible spacing that takes available space
  static const Widget expand = Spacer();
  
  /// Custom spacing
  static Widget custom(double size) => SizedBox(height: size, width: size);
  
  /// Horizontal line spacer
  static Widget horizontalLine({
    double? thickness,
    Color? color,
    double? indent,
    double? endIndent,
  }) {
    return Divider(
      thickness: thickness,
      color: color,
      indent: indent,
      endIndent: endIndent,
    );
  }
  
  /// Vertical line spacer
  static Widget verticalLine({
    double? thickness,
    Color? color,
    double? indent,
    double? endIndent,
  }) {
    return VerticalDivider(
      thickness: thickness,
      color: color,
      indent: indent,
      endIndent: endIndent,
    );
  }
}