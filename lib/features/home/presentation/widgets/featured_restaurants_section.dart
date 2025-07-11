import 'package:flutter/material.dart';
import '../pages/restaurant_details_page.dart';
import 'restaurant_card_featured.dart';

/// Featured restaurants section widget following Single Responsibility Principle
/// Responsible only for displaying the featured restaurants horizontal list
class FeaturedRestaurantsSection extends StatelessWidget {
  final List<dynamic> restaurants;
  
  const FeaturedRestaurantsSection({
    super.key, 
    required this.restaurants,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Restaurants',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        restaurants.isEmpty
            ? const Center(child: Text('No featured restaurants available'))
            : SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return RestaurantCardFeatured(
                      restaurant: restaurant,
                      onTap: () => _navigateToRestaurantDetails(context, restaurant, index),
                    );
                  },
                ),
              ),
      ],
    );
  }

  void _navigateToRestaurantDetails(
    BuildContext context, 
    Map<String, dynamic> restaurant, 
    int index,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsPage(
          restaurantId: restaurant['id'] ?? (index + 1).toString(),
          restaurantData: restaurant,
        ),
      ),
    );
  }
}