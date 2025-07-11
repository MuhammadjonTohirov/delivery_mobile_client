import 'package:flutter/material.dart';

/// Unified restaurant card component to eliminate code duplication
class UnifiedRestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback? onTap;
  final bool isHorizontal;
  final double? width;
  final double? height;

  const UnifiedRestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.isHorizontal = false,
    this.width,
    this.height,
  });

  /// Factory constructor for featured restaurant cards
  factory UnifiedRestaurantCard.featured({
    required Map<String, dynamic> restaurant,
    VoidCallback? onTap,
  }) {
    return UnifiedRestaurantCard(
      restaurant: restaurant,
      onTap: onTap,
      isHorizontal: false,
      width: 300,
      height: 220,
    );
  }

  /// Factory constructor for list restaurant cards
  factory UnifiedRestaurantCard.list({
    required Map<String, dynamic> restaurant,
    VoidCallback? onTap,
  }) {
    return UnifiedRestaurantCard(
      restaurant: restaurant,
      onTap: onTap,
      isHorizontal: true,
      height: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = restaurant['name'] ?? 'Restaurant';
    final rating = restaurant['average_rating']?.toString() ?? '0.0';
    final deliveryTime = restaurant['estimated_delivery_time']?.toString() ?? 'N/A';
    final bannerUrl = restaurant['banner_image'];
    final logoUrl = restaurant['logo'];
    final tagline = restaurant['tagline'] ?? '';
    final cuisineType = restaurant['cuisine_type'] ?? '';
    final totalReviews = restaurant['total_reviews']?.toString() ?? '0';

    if (isHorizontal) {
      return _buildHorizontalCard(context, name, rating, deliveryTime, bannerUrl, logoUrl, tagline, cuisineType, totalReviews);
    } else {
      return _buildVerticalCard(context, name, rating, deliveryTime, bannerUrl, logoUrl, tagline, cuisineType, totalReviews);
    }
  }

  Widget _buildHorizontalCard(
    BuildContext context,
    String name,
    String rating,
    String deliveryTime,
    String? bannerUrl,
    String? logoUrl,
    String tagline,
    String cuisineType,
    String totalReviews,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Restaurant Image
            _buildImageContainer(context, bannerUrl, logoUrl, 80, 80, true),
            // Restaurant Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantName(context, name),
                    if (tagline.isNotEmpty || cuisineType.isNotEmpty)
                      _buildTagline(context, tagline.isNotEmpty ? tagline : cuisineType),
                    const SizedBox(height: 6),
                    _buildRatingAndTime(context, rating, totalReviews, deliveryTime),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalCard(
    BuildContext context,
    String name,
    String rating,
    String deliveryTime,
    String? bannerUrl,
    String? logoUrl,
    String tagline,
    String cuisineType,
    String totalReviews,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image with Logo Overlay
            _buildImageContainer(context, bannerUrl, logoUrl, double.infinity, 120, false),
            // Restaurant Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRestaurantName(context, name),
                        if (tagline.isNotEmpty || cuisineType.isNotEmpty)
                          _buildTagline(context, tagline.isNotEmpty ? tagline : cuisineType),
                      ],
                    ),
                    _buildRatingAndTime(context, rating, totalReviews, deliveryTime),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(
    BuildContext context,
    String? bannerUrl,
    String? logoUrl,
    double width,
    double height,
    bool isHorizontal,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(64),
        borderRadius: isHorizontal
            ? const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
      ),
      child: Stack(
        children: [
          // Banner Image
          if (bannerUrl != null)
            ClipRRect(
              borderRadius: isHorizontal
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
              child: Image.network(
                bannerUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackIcon(context);
                },
              ),
            )
          else
            _buildFallbackIcon(context),
          // Logo Overlay
          if (logoUrl != null)
            Positioned(
              bottom: isHorizontal ? 4 : 8,
              left: isHorizontal ? null : 8,
              right: isHorizontal ? 4 : null,
              child: Container(
                width: isHorizontal ? 20 : 40,
                height: isHorizontal ? 20 : 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isHorizontal ? 4 : 8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(64),
                      blurRadius: isHorizontal ? 2 : 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isHorizontal ? 4 : 8),
                  child: Image.network(
                    logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.restaurant,
                        size: isHorizontal ? 12 : 20,
                        color: Theme.of(context).primaryColor,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return Center(
      child: Icon(
        Icons.restaurant,
        size: isHorizontal ? 24 : 40,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildRestaurantName(BuildContext context, String name) {
    return Text(
      name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTagline(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRatingAndTime(BuildContext context, String rating, String totalReviews, String deliveryTime) {
    return Row(
      children: [
        // Rating
        Icon(
          Icons.star,
          size: isHorizontal ? 14 : 16,
          color: totalReviews == '0' ? Colors.grey[400] : Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          totalReviews == '0' ? 'New' : rating,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: totalReviews == '0' ? Colors.grey[600] : null,
          ),
        ),
        const SizedBox(width: 4),
        if (totalReviews != '0')
          Text(
            '($totalReviews)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        if (!isHorizontal) const Spacer(),
        if (!isHorizontal) const SizedBox(width: 8),
        // Delivery Time
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: isHorizontal ? 12 : 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 2),
            Text(
              deliveryTime == 'N/A' ? deliveryTime : '$deliveryTime min',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}