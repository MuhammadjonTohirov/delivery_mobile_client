import 'package:flutter/material.dart';
import 'restaurant_info_extractor.dart';

/// List restaurant card widget following Single Responsibility Principle
/// Responsible only for displaying a restaurant card in vertical list layout
class RestaurantCardList extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;
  
  const RestaurantCardList({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = RestaurantInfoExtractor.extractInfo(restaurant);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildImageSection(context, info),
            _buildDetailsSection(context, info),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, RestaurantInfo info) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(25),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      child: Stack(
        children: [
          if (info.bannerUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                info.bannerUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            )
          else
            Center(
              child: Icon(
                Icons.restaurant,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
          if (info.logoUrl != null) _buildSmallLogoOverlay(context, info.logoUrl!),
        ],
      ),
    );
  }

  Widget _buildSmallLogoOverlay(BuildContext context, String logoUrl) {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.restaurant,
                size: 12,
                color: Theme.of(context).primaryColor,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, RestaurantInfo info) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              info.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (info.tagline.isNotEmpty || info.cuisineType.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  info.tagline.isNotEmpty ? info.tagline : info.cuisineType,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 14,
                  color: info.totalReviews == '0' ? Colors.grey[400] : Colors.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  info.totalReviews == '0' ? 'New' : info.rating,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: info.totalReviews == '0' ? Colors.grey[600] : null,
                  ),
                ),
                const SizedBox(width: 2),
                if (info.totalReviews != '0')
                  Text(
                    '(${info.totalReviews})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 2),
                Text(
                  info.deliveryTime == 'N/A' ? info.deliveryTime : '${info.deliveryTime} min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}