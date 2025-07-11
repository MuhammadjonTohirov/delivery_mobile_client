import 'package:delivery_customer/core/models/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../core/router/app_router.dart';
import 'package:delivery_customer/core/services/api/api_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../shared/widgets/cart/cart_wrapper.dart';
import '../../../../shared/widgets/cart/cart_helpers.dart';
import '../../../../shared/utils/formatters/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final String restaurantId;
  final Map<String, dynamic>? restaurantData;

  const RestaurantDetailsPage({
    super.key,
    required this.restaurantId,
    this.restaurantData,
  });

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  Map<String, dynamic>? _restaurantDetails;
  List<dynamic> _menuItems = [];
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      
      // Load restaurant details if not provided
      if (widget.restaurantData == null) {
        final response = await apiService.getRestaurantDetails(widget.restaurantId);
        if (response.success && response.data != null) {
          _restaurantDetails = response.data!;
        }
      } else {
        _restaurantDetails = widget.restaurantData!;
      }
      
      // Load menu items for this restaurant
      final menuResponse = await apiService.getMenuItems(restaurantId: widget.restaurantId);
      if (menuResponse.success && menuResponse.data != null) {
        _menuItems = menuResponse.data!['results'] ?? menuResponse.data!;
      }
      
      // Load reviews from server
      final reviewsResponse = await apiService.getRestaurantReviews(widget.restaurantId);
      if (reviewsResponse.success && reviewsResponse.data != null) {
        _reviews = reviewsResponse.data!;
      }
      
    } catch (e) {
      LoggerService.error('Error loading restaurant data', e);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final restaurant = _restaurantDetails ?? {};
    final name = restaurant['name'] ?? 'Restaurant ${widget.restaurantId}';
    final bannerUrl = restaurant['banner_image'];
    final logoUrl = restaurant['logo'];
    
    return CartWrapper(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Enhanced App Bar with Restaurant Image
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    if (bannerUrl != null)
                      CachedNetworkImage(
                        imageUrl: bannerUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).primaryColor.withAlpha(76),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => _buildDefaultBackground(context),
                      )
                    else
                      _buildDefaultBackground(context),
                    
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(178),
                          ],
                        ),
                      ),
                    ),
                    
                    // Restaurant Logo
                    if (logoUrl != null)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: logoUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(
                              Icons.restaurant,
                              color: Theme.of(context).primaryColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(76),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(76),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Enhanced Restaurant Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRestaurantHeader(),
                  const SizedBox(height: 16),
                  _buildQuickStats(),
                  const SizedBox(height: 16),
                  _buildPromotionBanner(),
                ],
              ),
            ),
          ),

          // Menu Section Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Menu Items List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_menuItems.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Menu not available'),
                        ],
                      ),
                    ),
                  );
                }
                
                final item = _menuItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildMenuItemCard(item),
                );
              },
              childCount: _menuItems.isEmpty ? 1 : _menuItems.length,
            ),
          ),
        ],
        ),
        bottomNavigationBar: _buildEnhancedCartButton(),
      ),
    );
  }

  Widget _buildDefaultBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha(204),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    final restaurant = _restaurantDetails ?? {};
    final name = restaurant['name'] ?? 'Restaurant ${widget.restaurantId}';
    final tagline = restaurant['tagline'] ?? 'Delicious food delivered fresh to your door';
    final cuisineType = restaurant['cuisine_type'] ?? 'International Cuisine';
    final rating = restaurant['average_rating']?.toString() ?? '4.5';
    final totalReviews = restaurant['total_reviews']?.toString() ?? '120';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant name with info button
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _showRestaurantInfo(),
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
              ),
              tooltip: 'Restaurant Info',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          tagline.isNotEmpty ? tagline : cuisineType,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        // Clickable ratings
        GestureDetector(
          onTap: () => _showReviews(),
          child: Row(
            children: [
              RatingBarIndicator(
                rating: double.tryParse(rating) ?? 4.5,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$rating ($totalReviews reviews)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final restaurant = _restaurantDetails ?? {};
    final deliveryTime = restaurant['estimated_delivery_time']?.toString() ?? '30';
    final deliveryFee = restaurant['formatted_delivery_fee'] ?? 'Free';
    final minimumOrder = restaurant['formatted_minimum_order'] ?? '\$15';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.access_time,
            value: '$deliveryTime min',
            label: 'Delivery Time',
          ),
          Container(
            height: 40,
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          _buildStatItem(
            icon: Icons.delivery_dining,
            value: deliveryFee,
            label: 'Delivery Fee',
          ),
          Container(
            height: 40,
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          _buildStatItem(
            icon: Icons.shopping_bag,
            value: minimumOrder,
            label: 'Minimum Order',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withAlpha(25),
            Colors.red.withAlpha(25),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withAlpha(76),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer,
            color: Colors.orange[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Offer',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                Text(
                  'Free delivery on orders over \$25',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMenuTab() {
    if (_menuItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Menu not available'),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  Row(
                    children: [
                      Text(
                        MenuItem.fromJson(item).formattedPrice,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isAvailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Add Button
            Container(
              decoration: BoxDecoration(
                color: isAvailable
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withAlpha(76),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: isAvailable
                    ? () {
                        // Create MenuItem from the raw item data
                        final menuItem = MenuItem.fromJson(item);
                        CartHelpers.showMenuItemModal(context, menuItem);
                      }
                    : null,
                icon: Icon(
                  Icons.add,
                  color: isAvailable ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedReviewsTab() {
    if (_reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No reviews yet'),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildReviewsSummary(),
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return _buildReviewCard(review);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSummary() {
    final restaurant = _restaurantDetails ?? {};
    final rating = double.tryParse(restaurant['average_rating']?.toString() ?? '4.5') ?? 4.5;
    final totalReviews = int.tryParse(restaurant['total_reviews']?.toString() ?? '120') ?? 120;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on $totalReviews reviews',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Write review feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Write Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final name = review['customer_name'] ?? 'Anonymous';
    final rating = review['rating'] ?? 5;
    final comment = review['comment'] ?? '';
    final createdAt = review['created_at'] ?? '';
    final avatarUrl = review['avatar'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: rating.toDouble(),
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatReviewDate(createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                comment,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatReviewDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${difference.inDays > 60 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildEnhancedInfoTab() {
    final restaurant = _restaurantDetails ?? {};
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Contact Information',
            [
              _buildInfoItem(
                Icons.phone,
                restaurant['phone'] ?? '+1 (555) 123-4567',
                isClickable: true,
                onTap: () => _showComingSoon('Call restaurant'),
              ),
              _buildInfoItem(
                Icons.email,
                restaurant['email'] ?? 'restaurant${widget.restaurantId}@example.com',
                isClickable: true,
                onTap: () => _showComingSoon('Email restaurant'),
              ),
              _buildInfoItem(
                Icons.location_on,
                restaurant['address'] ?? '123 Main St, City, State 12345',
                isClickable: true,
                onTap: () => _showComingSoon('View on map'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Opening Hours',
            [
              _buildInfoItem(Icons.access_time, 'Monday - Friday: 10:00 AM - 10:00 PM'),
              _buildInfoItem(Icons.access_time, 'Saturday - Sunday: 11:00 AM - 11:00 PM'),
              _buildInfoItem(Icons.access_time, 'Currently Open', 
                textColor: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Delivery Information',
            [
              _buildInfoItem(
                Icons.delivery_dining,
                restaurant['formatted_delivery_fee'] != null
                    ? 'Delivery fee: ${restaurant['formatted_delivery_fee']}'
                    : 'Free delivery on orders over \$25'
              ),
              _buildInfoItem(
                Icons.timer,
                'Average delivery time: ${restaurant['estimated_delivery_time'] ?? 30} minutes'
              ),
              _buildInfoItem(
                Icons.attach_money,
                'Minimum order: ${restaurant['formatted_minimum_order'] ?? '\$15'}'
              ),
              _buildInfoItem(
                Icons.payment,
                'Accepts: Cash, Card, Digital payments'
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Restaurant Features',
            [
              _buildFeatureChip('Free WiFi'),
              _buildFeatureChip('Outdoor Seating'),
              _buildFeatureChip('Takeout Available'),
              _buildFeatureChip('Family Friendly'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String text, {
    bool isClickable = false,
    VoidCallback? onTap,
    Color? textColor,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
              if (isClickable)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha(76),
        ),
      ),
      child: Text(
        feature,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEnhancedCartButton() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoaded && state.itemCount > 0) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  AppRouter.push(context, AppRouter.cart);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).viewCartWithItems(state.itemCount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatUSD(state.total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showReviews() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _buildEnhancedReviewsTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestaurantInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _buildEnhancedInfoTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

