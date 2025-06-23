import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/router/app_router.dart';
import 'restaurant_details_page.dart';

class CategoryResultsPage extends StatefulWidget {
  final String? categoryId;
  final String categoryName;

  const CategoryResultsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryResultsPage> createState() => _CategoryResultsPageState();
}

class _CategoryResultsPageState extends State<CategoryResultsPage> {
  List<dynamic> _restaurants = [];
  List<dynamic> _menuItems = [];
  bool _isLoading = true;
  bool _showRestaurants = true;
  String _sortBy = 'popularity';

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  Future<void> _loadCategoryData() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      
      // Load restaurants with category filter
      final restaurantsResponse = await apiService.getRestaurants(
        category: widget.categoryName,
      );
      if (restaurantsResponse.success && restaurantsResponse.data != null) {
        _restaurants = restaurantsResponse.data!;
      }
      
      // Load menu items with category filter
      final menuResponse = await apiService.searchMenuItems(
        category: widget.categoryName,
        pageSize: 50,
      );
      if (menuResponse.success && menuResponse.data != null) {
        final data = menuResponse.data!;
        if (data['results'] != null) {
          _menuItems = data['results'];
        }
      }
      
    } catch (e) {
      print('Error loading category data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortResults() {
    setState(() {
      if (_showRestaurants) {
        _restaurants.sort((a, b) {
          switch (_sortBy) {
            case 'rating':
              final ratingA = double.tryParse(a['average_rating']?.toString() ?? '0') ?? 0;
              final ratingB = double.tryParse(b['average_rating']?.toString() ?? '0') ?? 0;
              return ratingB.compareTo(ratingA);
            case 'delivery_time':
              final timeA = int.tryParse(a['estimated_delivery_time']?.toString() ?? '999') ?? 999;
              final timeB = int.tryParse(b['estimated_delivery_time']?.toString() ?? '999') ?? 999;
              return timeA.compareTo(timeB);
            case 'popularity':
            default:
              final reviewsA = int.tryParse(a['total_reviews']?.toString() ?? '0') ?? 0;
              final reviewsB = int.tryParse(b['total_reviews']?.toString() ?? '0') ?? 0;
              return reviewsB.compareTo(reviewsA);
          }
        });
      } else {
        _menuItems.sort((a, b) {
          switch (_sortBy) {
            case 'price':
              final priceA = double.tryParse(a['price']?.toString() ?? '999') ?? 999;
              final priceB = double.tryParse(b['price']?.toString() ?? '999') ?? 999;
              return priceA.compareTo(priceB);
            case 'name':
              return (a['name'] ?? '').compareTo(b['name'] ?? '');
            case 'popularity':
            default:
              return 0; // Keep original order for menu items
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _sortResults();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'popularity',
                child: Text('Popularity'),
              ),
              if (_showRestaurants) ...[
                const PopupMenuItem(
                  value: 'rating',
                  child: Text('Rating'),
                ),
                const PopupMenuItem(
                  value: 'delivery_time',
                  child: Text('Delivery Time'),
                ),
              ] else ...[
                const PopupMenuItem(
                  value: 'price',
                  child: Text('Price'),
                ),
                const PopupMenuItem(
                  value: 'name',
                  child: Text('Name'),
                ),
              ],
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildToggleBar(),
                Expanded(
                  child: _showRestaurants
                      ? _buildRestaurantsList()
                      : _buildMenuItemsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildToggleBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showRestaurants = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showRestaurants
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Restaurants (${_restaurants.length})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _showRestaurants ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showRestaurants = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showRestaurants
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Menu Items (${_menuItems.length})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_showRestaurants ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsList() {
    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No restaurants found in ${widget.categoryName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return _buildRestaurantCard(restaurant);
      },
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    final name = restaurant['name'] ?? 'Restaurant';
    final rating = restaurant['average_rating']?.toString() ?? '4.5';
    final deliveryTime = restaurant['estimated_delivery_time']?.toString() ?? '30';
    final bannerUrl = restaurant['banner_image'];
    final logoUrl = restaurant['logo'];
    final tagline = restaurant['tagline'] ?? '';
    final cuisineType = restaurant['cuisine_type'] ?? '';
    final totalReviews = restaurant['total_reviews']?.toString() ?? '0';
    final deliveryFee = restaurant['formatted_delivery_fee'] ?? 'Free';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RestaurantDetailsPage(
                restaurantId: restaurant['id'] ?? 0,
                restaurantData: restaurant,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Theme.of(context).primaryColor.withAlpha(25),
              ),
              child: Stack(
                children: [
                  if (bannerUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: bannerUrl,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).primaryColor.withAlpha(25),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  
                  // Logo overlay
                  if (logoUrl != null)
                    Positioned(
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
                          child: CachedNetworkImage(
                            imageUrl: logoUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(
                              Icons.restaurant,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Restaurant Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (tagline.isNotEmpty || cuisineType.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      tagline.isNotEmpty ? tagline : cuisineType,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($totalReviews)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$deliveryTime min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        deliveryFee,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemsList() {
    if (_menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No menu items found in ${widget.categoryName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return _buildMenuItemCard(item);
      },
    );
  }

  Widget _buildMenuItemCard(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Menu Item';
    final description = item['description'] ?? '';
    final price = item['price']?.toString() ?? '0.00';
    final imageUrl = item['image'];
    final isAvailable = item['is_available'] ?? true;
    final restaurantName = item['restaurant_name'] ?? 'Restaurant';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Item Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).primaryColor.withAlpha(25),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.fastfood,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.fastfood,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
            ),
            const SizedBox(width: 16),
            
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurantName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '\$${double.tryParse(price)?.toStringAsFixed(2) ?? price}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Button
            if (isAvailable)
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$name added to cart'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add'),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Unavailable',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}