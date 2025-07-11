import 'package:delivery_customer/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OptimizedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Duration fadeInDuration;
  final bool enableMemoryCache;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.fadeInDuration = const Duration(milliseconds: 200),
    this.enableMemoryCache = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget(context);
    }

    final screenSize = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Calculate optimal cache dimensions
    final cacheWidth = width != null
        ? (width! * devicePixelRatio).round()
        : (screenSize.width * devicePixelRatio * 0.3).round();
    
    final cacheHeight = height != null
        ? (height! * devicePixelRatio).round()
        : (screenSize.height * devicePixelRatio * 0.2).round();

    Widget imageWidget = CachedNetworkImage(
      imageUrl: _buildImageUrl(imageUrl!),
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder != null
          ? (context, url) => placeholder!
          : (context, url) => _buildDefaultPlaceholder(context),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget!
          : (context, url, error) => _buildErrorWidget(context),
      fadeInDuration: fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheWidth: enableMemoryCache ? cacheWidth : null,
      memCacheHeight: enableMemoryCache ? cacheHeight : null,
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 600,
      useOldImageOnUrlChange: true,
      cacheKey: _generateCacheKey(imageUrl!),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  String _buildImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // Handle relative URLs - use your API base URL
    if (url.startsWith('/')) {
      return '${AppConstants.serverUrl}/$url'; // Should come from AppConstants
    }
    
    return '${AppConstants.serverUrl}/media/$url';
  }

  String _generateCacheKey(String url) {
    // Generate a consistent cache key
    final cleanUrl = _buildImageUrl(url);
    return 'optimized_${cleanUrl.hashCode}';
  }

  Widget _buildDefaultPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 24,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// Extension for easy usage with existing Image.network calls
extension OptimizedImageExtension on Image {
  static Widget network(
    String src, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    return OptimizedNetworkImage(
      imageUrl: src,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: placeholder,
      errorWidget: errorWidget,
      borderRadius: borderRadius,
    );
  }
}