import 'package:flutter/material.dart';

/// Extension on Widget to add common styling and layout utilities
extension WidgetExtensions on Widget {
  
  // =============================================================================
  // CONTAINER STYLING EXTENSIONS
  // =============================================================================
  
  /// Wraps widget in a Container with common styling options
  Widget withContainer({
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double borderRadius = 8.0,
    Color? borderColor,
    double borderWidth = 1.0,
    List<BoxShadow>? shadows,
    AlignmentGeometry? alignment,
    Clip? clip,
  }) {
    return Container(
      clipBehavior: clip ?? Clip.none,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null 
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
        boxShadow: shadows,
      ),
      child: this,
    );
  }

  /// Quick card-like container with shadow
  Widget asCard({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double borderRadius = 12.0,
    double elevation = 2.0,
    Color shadowColor = Colors.black12,
  }) {
    return withContainer(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      shadows: [
        BoxShadow(
          color: shadowColor,
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
        ),
      ],
    );
  }

  /// Bordered container
  Widget withBorder({
    Color? borderColor,
    double borderWidth = 1.0,
    double borderRadius = 8.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
  }) {
    return withContainer(
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderColor: borderColor ?? Colors.grey.shade300,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
    );
  }

  /// Rounded container with specific radius
  Widget withRadius(double radius, {
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
  }) {
    return withContainer(
      padding: padding,
      backgroundColor: backgroundColor,
      borderRadius: radius,
    );
  }

  /// Glass-morphism effect container
  Widget asGlassCard({
    double borderRadius = 16.0,
    double blur = 10.0,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withAlpha((0.2 * 255).toInt()),
            width: 1,
          ),
        ),
        child: this,
      ),
    );
  }

  // =============================================================================
  // PADDING & MARGIN EXTENSIONS
  // =============================================================================

  /// Add symmetric padding
  Widget withPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left ?? horizontal ?? all ?? 0,
        top: top ?? vertical ?? all ?? 0,
        right: right ?? horizontal ?? all ?? 0,
        bottom: bottom ?? vertical ?? all ?? 0,
      ),
      child: this,
    );
  }

  /// Quick padding shortcuts
  Widget paddingAll(double value) => withPadding(all: value);
  Widget paddingHorizontal(double value) => withPadding(horizontal: value);
  Widget paddingVertical(double value) => withPadding(vertical: value);
  Widget paddingOnly({double? left, double? top, double? right, double? bottom}) {
    return withPadding(left: left, top: top, right: right, bottom: bottom);
  }

  /// Add margin
  Widget withMargin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: left ?? horizontal ?? all ?? 0,
        top: top ?? vertical ?? all ?? 0,
        right: right ?? horizontal ?? all ?? 0,
        bottom: bottom ?? vertical ?? all ?? 0,
      ),
      child: this,
    );
  }

  // =============================================================================
  // ALIGNMENT & POSITIONING EXTENSIONS
  // =============================================================================

  /// Center the widget
  Widget centered() => Center(child: this);
  
  /// Align widget
  Widget aligned(AlignmentGeometry alignment) => Align(alignment: alignment, child: this);
  
  /// Common alignment shortcuts
  Widget alignTopLeft() => aligned(Alignment.topLeft);
  Widget alignTopCenter() => aligned(Alignment.topCenter);
  Widget alignTopRight() => aligned(Alignment.topRight);
  Widget alignCenterLeft() => aligned(Alignment.centerLeft);
  Widget alignCenterRight() => aligned(Alignment.centerRight);
  Widget alignBottomLeft() => aligned(Alignment.bottomLeft);
  Widget alignBottomCenter() => aligned(Alignment.bottomCenter);
  Widget alignBottomRight() => aligned(Alignment.bottomRight);

  /// Expanded with flex
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
  
  /// Flexible
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  // =============================================================================
  // TRANSFORM & ANIMATION EXTENSIONS
  // =============================================================================

  /// Scale the widget
  Widget scaled(double scale) => Transform.scale(scale: scale, child: this);
  
  /// Rotate the widget
  Widget rotated(double angle) => Transform.rotate(angle: angle, child: this);
  
  /// Translate the widget
  Widget translated({double? x, double? y}) {
    return Transform.translate(offset: Offset(x ?? 0, y ?? 0), child: this);
  }

  /// Add opacity
  Widget withOpacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// Fade transition
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) => Opacity(opacity: value, child: child!),
      child: this,
    );
  }

  /// Slide in animation
  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.translate(offset: value, child: child!);
      },
      child: this,
    );
  }

  // =============================================================================
  // GESTURE & INTERACTION EXTENSIONS
  // =============================================================================

  /// Add tap gesture
  Widget onTap(VoidCallback? onTap, {
    Color? splashColor,
    Color? highlightColor,
    double borderRadius = 8.0,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor,
        highlightColor: highlightColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: this,
      ),
    );
  }

  /// Add long press gesture
  Widget onLongPress(VoidCallback? onLongPress) {
    return GestureDetector(onLongPress: onLongPress, child: this);
  }

  /// Add double tap gesture
  Widget onDoubleTap(VoidCallback? onDoubleTap) {
    return GestureDetector(onDoubleTap: onDoubleTap, child: this);
  }

  // =============================================================================
  // CONDITIONAL EXTENSIONS
  // =============================================================================

  /// Conditionally show widget
  Widget showIf(bool condition) => condition ? this : const SizedBox.shrink();
  
  /// Show widget or replacement based on condition
  Widget showOrElse(bool condition, Widget elseWidget) {
    return condition ? this : elseWidget;
  }

  /// Wrap with another widget conditionally
  Widget wrapIf(bool condition, Widget Function(Widget child) wrapper) {
    return condition ? wrapper(this) : this;
  }

  // =============================================================================
  // SIZE & CONSTRAINTS EXTENSIONS
  // =============================================================================

  /// Set specific size
  Widget withSize({double? width, double? height}) {
    return SizedBox(width: width, height: height, child: this);
  }

  /// Set square size
  Widget asSquare(double size) => withSize(width: size, height: size);

  /// Constrain widget size
  Widget constrained({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        maxWidth: maxWidth ?? double.infinity,
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: this,
    );
  }

  /// Take full width
  Widget fullWidth() => SizedBox(width: double.infinity, child: this);
  
  /// Take full height
  Widget fullHeight() => SizedBox(height: double.infinity, child: this);

  // =============================================================================
  // SCROLL EXTENSIONS
  // =============================================================================

  /// Make widget scrollable
  Widget scrollable({
    Axis scrollDirection = Axis.vertical,
    bool primary = false,
    ScrollPhysics? physics,
  }) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      primary: primary,
      physics: physics,
      child: this,
    );
  }

  // =============================================================================
  // VISIBILITY EXTENSIONS
  // =============================================================================

  /// Control visibility
  Widget visible(bool isVisible) {
    return Visibility(visible: isVisible, child: this);
  }

  /// Hide but maintain space
  Widget invisible() => Visibility(visible: false, child: this);

  /// Remove from tree when not visible
  Widget visibleOrGone(bool isVisible) {
    return Visibility(
      visible: isVisible,
      maintainSize: false,
      maintainAnimation: false,
      maintainState: false,
      child: this,
    );
  }
}

/// Extension for adding shadows to any widget
extension ShadowExtensions on Widget {
  
  /// Add custom shadow
  Widget withShadow({
    Color color = Colors.black12,
    double blurRadius = 8.0,
    Offset offset = const Offset(0, 2),
    double spreadRadius = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            offset: offset,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: this,
    );
  }

  /// Material elevation shadow
  Widget withElevation(double elevation) {
    return Material(
      elevation: elevation,
      color: Colors.transparent,
      child: this,
    );
  }

  /// Soft shadow (commonly used in modern designs)
  Widget withSoftShadow({double? elevation}) {
    final elev = elevation ?? 4.0;
    return withShadow(
      color: Colors.black.withAlpha((0.08 * 255).toInt()),
      blurRadius: elev * 2,
      offset: Offset(0, elev / 2),
    );
  }

  /// Drop shadow effect
  Widget withDropShadow() {
    return withShadow(
      color: Colors.black26,
      blurRadius: 6.0,
      offset: const Offset(0, 3),
    );
  }
}

/// Extension for quick styling combinations
extension QuickStyleExtensions on Widget {
  
  /// Modern card style
  Widget asModernCard({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
  }) {
    return withContainer(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.all(8),
      backgroundColor: backgroundColor,
      borderRadius: 16,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha((0.06 * 255).toInt()),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Button-like styling
  Widget asButton({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 8.0,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return withContainer(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
    ).onTap(onTap);
  }

  /// Chip-like styling
  Widget asChip({
    Color? backgroundColor,
    Color? borderColor,
    EdgeInsetsGeometry? padding,
  }) {
    return withContainer(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      backgroundColor: backgroundColor ?? Colors.grey.shade100,
      borderColor: borderColor,
      borderRadius: 20,
    );
  }

  /// Badge styling
  Widget asBadge({
    Color? backgroundColor,
    Color? textColor,
    double size = 20,
  }) {
    return withContainer(
      width: size,
      height: size,
      backgroundColor: backgroundColor ?? Colors.red,
      borderRadius: size / 2,
      alignment: Alignment.center,
    );
  }

  /// Loading state with shimmer-like effect
  Widget asShimmer({
    Color? baseColor,
    Color? highlightColor,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor ?? Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: this,
    );
  }
}

/// Extension for responsive design helpers
extension ResponsiveExtensions on Widget {
  
  /// Responsive sizing based on screen width
  Widget responsive(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    double size;
    if (screenWidth < 600) {
      size = mobile ?? 1.0;
    } else if (screenWidth < 1200) {
      size = tablet ?? mobile ?? 1.0;
    } else {
      size = desktop ?? tablet ?? mobile ?? 1.0;
    }
    
    return Transform.scale(scale: size, child: this);
  }

  /// Show only on specific screen sizes
  Widget onlyOn(BuildContext context, {
    bool mobile = true,
    bool tablet = true,
    bool desktop = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    bool shouldShow;
    if (screenWidth < 600) {
      shouldShow = mobile;
    } else if (screenWidth < 1200) {
      shouldShow = tablet;
    } else {
      shouldShow = desktop;
    }
    
    return shouldShow ? this : const SizedBox.shrink();
  }
}