import 'package:flutter/material.dart';

/// Extension on String to create styled Text widgets quickly
extension StringExtensions on String {
  
  // =============================================================================
  // BASIC TEXT STYLES
  // =============================================================================
  
  /// Convert string to Text widget
  Text get text => Text(this);
  
  /// Styled text with common properties
  Text styledText({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    String? fontFamily,
  }) {
    return Text(
      this,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        decoration: decoration,
        fontFamily: fontFamily,
      ),
    );
  }

  // =============================================================================
  // TYPOGRAPHY SHORTCUTS
  // =============================================================================

  /// Heading styles
  Text get h1 => styledText(fontSize: 32, fontWeight: FontWeight.bold);
  Text get h2 => styledText(fontSize: 28, fontWeight: FontWeight.bold);
  Text get h3 => styledText(fontSize: 24, fontWeight: FontWeight.w600);
  Text get h4 => styledText(fontSize: 20, fontWeight: FontWeight.w600);
  Text get h5 => styledText(fontSize: 18, fontWeight: FontWeight.w500);
  Text get h6 => styledText(fontSize: 16, fontWeight: FontWeight.w500);

  /// Body text styles
  Text get bodyLarge => styledText(fontSize: 16, fontWeight: FontWeight.normal);
  Text get bodyMedium => styledText(fontSize: 14, fontWeight: FontWeight.normal);
  Text get bodySmall => styledText(fontSize: 12, fontWeight: FontWeight.normal);

  /// Caption and label styles
  Text get caption => styledText(fontSize: 10, color: Colors.grey[600]);
  Text get label => styledText(fontSize: 11, fontWeight: FontWeight.w500);
  Text get overline => styledText(
    fontSize: 10, 
    fontWeight: FontWeight.w500, 
    letterSpacing: 1.5,
  );

  // =============================================================================
  // FONT WEIGHT SHORTCUTS
  // =============================================================================

  Text get thin => styledText(fontWeight: FontWeight.w100);
  Text get extraLight => styledText(fontWeight: FontWeight.w200);
  Text get light => styledText(fontWeight: FontWeight.w300);
  Text get regular => styledText(fontWeight: FontWeight.w400);
  Text get medium => styledText(fontWeight: FontWeight.w500);
  Text get semiBold => styledText(fontWeight: FontWeight.w600);
  Text get bold => styledText(fontWeight: FontWeight.w700);
  Text get extraBold => styledText(fontWeight: FontWeight.w800);
  Text get black => styledText(fontWeight: FontWeight.w900);

  // =============================================================================
  // COLOR SHORTCUTS
  // =============================================================================

  Text get white => styledText(color: Colors.white);
  Text get grey => styledText(color: Colors.grey);
  Text get red => styledText(color: Colors.red);
  Text get green => styledText(color: Colors.green);
  Text get blue => styledText(color: Colors.blue);
  Text get orange => styledText(color: Colors.orange);
  Text get purple => styledText(color: Colors.purple);

  /// Contextual colors (requires BuildContext)
  Text primary(BuildContext context) => styledText(color: Theme.of(context).primaryColor);
  Text secondary(BuildContext context) => styledText(color: Theme.of(context).colorScheme.secondary);
  Text onPrimary(BuildContext context) => styledText(color: Theme.of(context).colorScheme.onPrimary);
  Text onSecondary(BuildContext context) => styledText(color: Theme.of(context).colorScheme.onSecondary);
  Text surface(BuildContext context) => styledText(color: Theme.of(context).colorScheme.surface);
  Text onSurface(BuildContext context) => styledText(color: Theme.of(context).colorScheme.onSurface);
  Text error(BuildContext context) => styledText(color: Theme.of(context).colorScheme.error);

  // =============================================================================
  // SIZE SHORTCUTS
  // =============================================================================

  Text get xs => styledText(fontSize: 10);
  Text get sm => styledText(fontSize: 12);
  Text get base => styledText(fontSize: 14);
  Text get lg => styledText(fontSize: 16);
  Text get xl => styledText(fontSize: 18);
  Text get xxl => styledText(fontSize: 20);
  Text get xxxl => styledText(fontSize: 24);

  // =============================================================================
  // DECORATION SHORTCUTS
  // =============================================================================

  Text get underline => styledText(decoration: TextDecoration.underline);
  Text get lineThrough => styledText(decoration: TextDecoration.lineThrough);
  Text get styledOverline => styledText(decoration: TextDecoration.overline);

  // =============================================================================
  // ALIGNMENT SHORTCUTS
  // =============================================================================

  Text get centerText => styledText(textAlign: TextAlign.center);
  Text get leftText => styledText(textAlign: TextAlign.left);
  Text get rightText => styledText(textAlign: TextAlign.right);
  Text get justifyText => styledText(textAlign: TextAlign.justify);

  // =============================================================================
  // OVERFLOW HANDLING
  // =============================================================================

  Text get ellipsis => styledText(overflow: TextOverflow.ellipsis);
  Text get fade => styledText(overflow: TextOverflow.fade);
  Text get clip => styledText(overflow: TextOverflow.clip);

  Text maxLines(int lines) => styledText(maxLines: lines, overflow: TextOverflow.ellipsis);

  // =============================================================================
  // SPACING SHORTCUTS
  // =============================================================================

  Text letterSpacing(double spacing) => styledText(letterSpacing: spacing);
  Text wordSpacing(double spacing) => styledText(wordSpacing: spacing);
  Text lineHeight(double height) => styledText(height: height);

  // =============================================================================
  // COMBINATION SHORTCUTS
  // =============================================================================

  /// Title text (large, bold)
  Text get title => styledText(fontSize: 20, fontWeight: FontWeight.bold);
  
  /// Subtitle text (medium, semi-bold)
  Text get subtitle => styledText(fontSize: 16, fontWeight: FontWeight.w600);
  
  /// Muted text (grey color)
  Text get muted => styledText(color: Colors.grey[600]);
  
  /// Success text (green color)
  Text get success => styledText(color: Colors.green[600]);
  
  /// Warning text (orange color)  
  Text get warning => styledText(color: Colors.orange[600]);
  
  /// Danger text (red color)
  Text get danger => styledText(color: Colors.red[600]);
  
  /// Info text (blue color)
  Text get info => styledText(color: Colors.blue[600]);

  // =============================================================================
  // SPECIAL FORMATTING
  // =============================================================================

  /// Uppercase text
  Text get uppercase => Text(toUpperCase());
  
  /// Lowercase text
  Text get lowercase => Text(toLowerCase());
  
  /// Capitalize first letter
  Text get capitalize {
    if (isEmpty) return const Text('');
    return Text('${this[0].toUpperCase()}${substring(1)}');
  }

  /// Title case (capitalize each word)
  Text get titleCase {
    return Text(
      split(' ')
          .map((word) => word.isEmpty 
              ? word 
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
          .join(' ')
    );
  }
}

/// Extension on Text widget for additional styling
extension TextWidgetExtensions on Text {
  
  /// Apply theme-based styling
  Text withTheme(BuildContext context, {
    TextStyle? Function(TextTheme)? styleSelector,
  }) {
    final theme = Theme.of(context).textTheme;
    final selectedStyle = styleSelector?.call(theme);
    
    return Text(
      data ?? '',
      style: style?.merge(selectedStyle) ?? selectedStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      locale: locale,
      textScaleFactor: textScaleFactor,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  /// Apply custom color
  Text color(Color color) {
    return Text(
      data ?? '',
      style: (style ?? const TextStyle()).copyWith(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      locale: locale,
      textScaleFactor: textScaleFactor,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  /// Apply custom font size
  Text fontSize(double size) {
    return Text(
      data ?? '',
      style: (style ?? const TextStyle()).copyWith(fontSize: size),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      locale: locale,
      textScaleFactor: textScaleFactor,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  /// Apply font weight
  Text weight(FontWeight weight) {
    return Text(
      data ?? '',
      style: (style ?? const TextStyle()).copyWith(fontWeight: weight),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      locale: locale,
      textScaleFactor: textScaleFactor,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// Extension for Rich Text utilities
extension RichTextExtensions on String {
  
  /// Create RichText with highlighted parts
  RichText richText({
    required String highlight,
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  }) {
    final List<TextSpan> spans = [];
    final parts = split(highlight);
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: normalStyle));
      }
      if (i < parts.length - 1) {
        spans.add(TextSpan(text: highlight, style: highlightStyle));
      }
    }
    
    return RichText(text: TextSpan(children: spans));
  }

  /// Create gradient text effect
  Widget gradientText({
    required Gradient gradient,
    TextStyle? style,
    TextAlign? textAlign,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        this,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}