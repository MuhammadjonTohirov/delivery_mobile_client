import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../utils/formatters/currency_formatter.dart';
import '../images/optimized_network_image.dart';

enum RestaurantCardLayout {
  featured,  // Horizontal card for featured section
  list,      // Vertical card for restaurant list
  grid,      // Grid card for search results
}

class RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final RestaurantCardLayout layout;
  final VoidCallback? onTap;
  final bool showDeliveryInfo;
  final bool showPromotions;

  // Pre-computed values for performance
  late final String _name;
  late final String _cuisineTypes;
  late final double _rating;
  late final String _deliveryTime;
  late final String? _imageUrl;
  late final String? _promotionText;
  late final bool _hasPromotion;

  RestaurantCard({
    super.key,
    required this.restaurant,
    this.layout = RestaurantCardLayout.list,
    this.onTap,
    this.showDeliveryInfo = true,
    this.showPromotions = true,
  }) {
    // Pre-compute all values to avoid repeated computations in build method
    _name = restaurant['name']?.toString() ?? 'Unknown Restaurant';
    _cuisineTypes = _buildCuisineTypesString();
    _rating = _getDouble(restaurant['rating']) ?? 4.0;
    _deliveryTime = restaurant['delivery_time']?.toString() ?? '30-45 min';
    _imageUrl = _getImageUrl();
    _promotionText = restaurant['promotion']?.toString();
    _hasPromotion = _promotionText != null && _promotionText!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // Isolate repaints for better performance
      child: switch (layout) {
        RestaurantCardLayout.featured => _buildFeaturedCard(context),
        RestaurantCardLayout.list => _buildListCard(context),
        RestaurantCardLayout.grid => _buildGridCard(context),
      },
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25), // Use withAlpha instead of withOpacity
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptimizedImage(context, height: 140),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantName(context, maxLines: 1),
                    const SizedBox(height: 4),
                    _buildCuisineTypes(context),
                    const SizedBox(height: 8),
                    _buildRatingAndDeliveryTime(context),
                    if (showPromotions && _hasPromotion) ...[
                      const SizedBox(height: 8),
                      _buildPromotionBadge(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20), // Use withAlpha
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptimizedImage(context, height: 160),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildRestaurantName(context, maxLines: 2),
                      ),
                      if (showPromotions && _hasPromotion)
                        _buildPromotionBadge(context),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildCuisineTypes(context),
                  const SizedBox(height: 12),
                  _buildRatingAndDeliveryTime(context),
                  if (showDeliveryInfo) ...[
                    const SizedBox(height: 8),
                    _buildDeliveryInfo(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20), // Use withAlpha
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildOptimizedImage(context),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantName(context, maxLines: 1),
                    const SizedBox(height: 4),
                    _buildCuisineTypes(context),
                    const Spacer(),
                    _buildRatingAndDeliveryTime(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedImage(BuildContext context, {double? height}) {
    return OptimizedNetworkImage(
      imageUrl: _imageUrl,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      placeholder: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Icon(
          Icons.restaurant,
          size: 32,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildRestaurantName(BuildContext context, {int maxLines = 2}) {
    return Text(
      _name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCuisineTypes(BuildContext context) {
    return Text(
      _cuisineTypes,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRatingAndDeliveryTime(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Rating
        RatingBarIndicator(
          rating: _rating,
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: theme.colorScheme.tertiary,
          ),
          itemCount: 5,
          itemSize: 16,
          unratedColor: theme.colorScheme.outline.withAlpha(80),
        ),
        const SizedBox(width: 4),
        Text(
          _rating.toStringAsFixed(1),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        // Delivery time
        Icon(
          Icons.access_time,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          _deliveryTime,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionBadge(BuildContext context) {
    if (!_hasPromotion) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _promotionText!,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context) {
    final theme = Theme.of(context);
    final deliveryFee = restaurant['delivery_fee'];
    final minOrder = restaurant['min_order'];
    
    return Row(
      children: [
        if (deliveryFee != null) ...[
          Icon(
            Icons.delivery_dining,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            deliveryFee == 0 ? 'Free delivery' : CurrencyFormatter.formatUSD(deliveryFee),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (minOrder != null) ...[
            const SizedBox(width: 16),
            Text(
              'Min ${CurrencyFormatter.formatUSD(minOrder)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ],
    );
  }

  // Helper methods (pre-computed for performance)
  String _buildCuisineTypesString() {
    final cuisines = restaurant['cuisine_types'];
    if (cuisines is List && cuisines.isNotEmpty) {
      return cuisines.take(2).join(' • ');
    }
    return restaurant['cuisine']?.toString() ?? 'Restaurant';
  }

  String? _getImageUrl() {
    final imageFields = ['image', 'image_url', 'banner', 'logo', 'photo'];
    
    for (final field in imageFields) {
      final value = restaurant[field];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    
    return null;
  }

  double? _getDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}