import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../utils/formatters/currency_formatter.dart';

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

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.layout = RestaurantCardLayout.list,
    this.onTap,
    this.showDeliveryInfo = true,
    this.showPromotions = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case RestaurantCardLayout.featured:
        return _buildFeaturedCard(context);
      case RestaurantCardLayout.list:
        return _buildListCard(context);
      case RestaurantCardLayout.grid:
        return _buildGridCard(context);
    }
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageContainer(context, height: 140),
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
                    if (showPromotions) ...[
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageContainer(context, height: 180),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildRestaurantName(context)),
                      if (showPromotions) _buildPromotionBadge(context),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildCuisineTypes(context),
                  const SizedBox(height: 12),
                  _buildRestaurantInfo(context),
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageContainer(context, height: 120),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantName(context, maxLines: 2),
                    const SizedBox(height: 4),
                    _buildCuisineTypes(context, maxLines: 1),
                    const Spacer(),
                    _buildRatingAndDeliveryTime(context, compact: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context, {required double height}) {
    // Check different possible image field names from server
    final imageUrl = restaurant['image'] ?? 
                    restaurant['image_url'] ?? 
                    restaurant['banner'] ?? 
                    restaurant['logo'] ??
                    restaurant['photo'];
    
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: imageUrl != null && imageUrl.toString().isNotEmpty
            ? Image.network(
                _buildImageUrl(imageUrl.toString()),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder(context);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              )
            : _buildImagePlaceholder(context),
      ),
    );
  }

  String _buildImageUrl(String imagePath) {
    // If it's already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // If it's a relative path, build the full URL with server base URL
    // Remove leading slash if present
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    
    // Get base URL from constants (remove /api part for media files)
    const baseUrl = 'http://192.168.1.78:8000'; // Could be extracted from AppConstants
    
    return '$baseUrl/media/$cleanPath';
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildRestaurantName(BuildContext context, {int? maxLines}) {
    return Text(
      restaurant['name'] ?? 'Restaurant',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      maxLines: maxLines ?? 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCuisineTypes(BuildContext context, {int? maxLines}) {
    final cuisines = restaurant['cuisine_types'] ?? restaurant['cuisines'];
    final cuisineText = cuisines is List 
        ? cuisines.join(' • ')
        : (cuisines?.toString() ?? 'Various cuisines');
    
    return Text(
      cuisineText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: maxLines ?? 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRatingAndDeliveryTime(BuildContext context, {bool compact = false}) {
    final rating = _getDouble(restaurant['rating']) ?? 4.0;
    final deliveryTime = restaurant['delivery_time'] ?? restaurant['estimated_delivery_time'] ?? '30-45';
    
    if (compact) {
      return Row(
        children: [
          Icon(Icons.star, size: 16, color: Colors.amber.shade600),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 2),
          Text(
            '$deliveryTime min',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: Colors.amber.shade600,
          ),
          itemCount: 5,
          itemSize: 16,
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.access_time,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '$deliveryTime min',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo(BuildContext context) {
    final deliveryFee = _getDouble(restaurant['delivery_fee']) ?? 0.0;
    final minimumOrder = _getDouble(restaurant['minimum_order']);
    
    return Row(
      children: [
        _buildRatingAndDeliveryTime(context),
        const Spacer(),
        if (showDeliveryInfo) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                deliveryFee > 0 
                    ? CurrencyFormatter.formatUSD(deliveryFee)
                    : 'Free delivery',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: deliveryFee > 0 
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.green.shade600,
                ),
              ),
              if (minimumOrder != null)
                Text(
                  'Min: ${CurrencyFormatter.formatUSD(minimumOrder)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPromotionBadge(BuildContext context) {
    final hasPromotion = restaurant['has_promotion'] ?? false;
    final promotionText = restaurant['promotion_text'] ?? 'Special Offer';
    
    if (!hasPromotion) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        promotionText,
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  double? _getDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}