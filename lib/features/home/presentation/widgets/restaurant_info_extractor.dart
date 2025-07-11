/// Restaurant information extractor following Single Responsibility Principle
/// Responsible only for extracting and formatting restaurant data from API response
class RestaurantInfo {
  final String name;
  final String rating;
  final String deliveryTime;
  final String? bannerUrl;
  final String? logoUrl;
  final String tagline;
  final String cuisineType;
  final String totalReviews;

  const RestaurantInfo({
    required this.name,
    required this.rating,
    required this.deliveryTime,
    this.bannerUrl,
    this.logoUrl,
    required this.tagline,
    required this.cuisineType,
    required this.totalReviews,
  });
}

/// Restaurant info extractor utility following Single Responsibility Principle
/// Responsible only for extracting restaurant information from raw data
class RestaurantInfoExtractor {
  static RestaurantInfo extractInfo(Map<String, dynamic> restaurant) {
    return RestaurantInfo(
      name: restaurant['name'] ?? 'Restaurant',
      rating: restaurant['average_rating']?.toString() ?? '0.0',
      deliveryTime: restaurant['estimated_delivery_time']?.toString() ?? 'N/A',
      bannerUrl: restaurant['banner_image'],
      logoUrl: restaurant['logo'],
      tagline: restaurant['tagline'] ?? '',
      cuisineType: restaurant['cuisine_type'] ?? '',
      totalReviews: restaurant['total_reviews']?.toString() ?? '0',
    );
  }
}