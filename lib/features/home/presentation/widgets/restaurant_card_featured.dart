import 'package:flutter/material.dart';
import 'restaurant_info_extractor.dart';

/// Featured restaurant card widget following Single Responsibility Principle
/// Responsible only for displaying a featured restaurant card in horizontal layout
class RestaurantCardFeatured extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;
  
  const RestaurantCardFeatured({
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
        width: 300,
        height: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerSection(context, info),
            _buildInfoSection(context, info),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection(BuildContext context, RestaurantInfo info) {
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(25),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: info.bannerUrl != null
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    info.bannerUrl!,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
        ),
        if (info.logoUrl != null) _buildLogoOverlay(context, info.logoUrl!),
      ],
    );
  }

  Widget _buildLogoOverlay(BuildContext context, String logoUrl) {
    return Positioned(
      bottom: 8,
      left: 8,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.restaurant,
                size: 20,
                color: Theme.of(context).primaryColor,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, RestaurantInfo info) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNameSection(context, info),
            _buildRatingSection(context, info),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection(BuildContext context, RestaurantInfo info) {
    return Column(
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
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context, RestaurantInfo info) {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: info.totalReviews == '0' ? Colors.grey[400] : Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          info.totalReviews == '0' ? 'New' : info.rating,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: info.totalReviews == '0' ? Colors.grey[600] : null,
          ),
        ),
        const SizedBox(width: 4),
        if (info.totalReviews != '0')
          Text(
            '(${info.totalReviews})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        const Spacer(),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 14,
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
    );
  }
}