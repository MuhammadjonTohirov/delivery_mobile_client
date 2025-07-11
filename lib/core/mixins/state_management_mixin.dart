import 'package:flutter/material.dart';

/// Mixin to provide better state management utilities
mixin StateManagementMixin<T extends StatefulWidget> on State<T> {
  bool _isDisposed = false;

  /// Safe setState that checks if widget is still mounted
  void safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  /// Debounced setState to prevent excessive calls
  void debouncedSetState(VoidCallback fn, {Duration delay = const Duration(milliseconds: 300)}) {
    if (!_isDisposed && mounted) {
      Future.delayed(delay, () {
        if (!_isDisposed && mounted) {
          setState(fn);
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}