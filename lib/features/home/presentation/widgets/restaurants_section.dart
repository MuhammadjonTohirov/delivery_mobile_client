import 'package:flutter/material.dart';
import '../pages/restaurant_details_page.dart';
import 'restaurant_card_list.dart';

/// Restaurants section widget following Single Responsibility Principle
/// Responsible only for displaying the all restaurants vertical list
class RestaurantsSection extends StatelessWidget {
  final List<dynamic> restaurants;
  
  const RestaurantsSection({
    super.key, 
    required this.restaurants,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Restaurants',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all restaurants')),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        restaurants.isEmpty
            ? const Center(child: Text('No restaurants available'))
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: restaurants.length > 5 ? 5 : restaurants.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return RestaurantCardList(
                    restaurant: restaurant,
                    onTap: () => _navigateToRestaurantDetails(context, restaurant),
                  );
                },
              ),
      ],
    );
  }

  void _navigateToRestaurantDetails(
    BuildContext context, 
    Map<String, dynamic> restaurant,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsPage(
          restaurantId: restaurant['id'] ?? 1,
          restaurantData: restaurant,
        ),
      ),
    );
  }
}