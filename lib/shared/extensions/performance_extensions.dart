import 'package:flutter/material.dart';
import 'dart:async';

/// Performance optimization extensions for common UI patterns
extension PerformanceExtensions on Widget {
  
  /// Wrap widget with RepaintBoundary for better performance
  Widget withRepaintBoundary() {
    return RepaintBoundary(child: this);
  }

  /// Add semantic label for accessibility
  Widget withSemantics(String label, {String? hint}) {
    return Semantics(
      label: label,
      hint: hint,
      child: this,
    );
  }

  /// Wrap with Hero widget for page transitions
  Widget withHero(String tag) {
    return Hero(tag: tag, child: this);
  }

  /// Conditionally show widget
  Widget showIf(bool condition) {
    return condition ? this : const SizedBox.shrink();
  }

  /// Add loading state overlay
  Widget withLoadingOverlay(bool isLoading) {
    return Stack(
      children: [
        this,
        if (isLoading)
          Container(
            color: Colors.black.withAlpha(128),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

/// Debounce utility for search and input fields
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Performance-optimized list builder
class PerformantListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PerformantListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Wrap each item in RepaintBoundary for better performance
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      // Add caching for better performance
      cacheExtent: 500,
    );
  }
}

/// Performance-optimized image widget
class PerformantImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const PerformantImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? 
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? 
            const Icon(Icons.error, color: Colors.grey);
        },
      ),
    );
  }
}

/// State management utilities
mixin PerformanceMixin<T extends StatefulWidget> on State<T> {
  bool _mounted = true;

  /// Safe setState that checks if widget is mounted
  void safePop() {
    if (_mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Safe navigation
  void safeNavigate(Widget page) {
    if (_mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}