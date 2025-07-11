import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import 'package:delivery_customer/core/services/api/api_service.dart';
import '../../../../shared/widgets/cart/cart_wrapper.dart';
import '../../../../shared/widgets/cart/cart_helpers.dart';
import '../../../../shared/widgets/menu/menu_item_card.dart';
import '../../../../shared/widgets/states/error_state_widget.dart';
import '../../../../shared/widgets/states/empty_state_widget.dart';

class RestaurantMenuItemsPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final Map<String, dynamic>? restaurantData;

  const RestaurantMenuItemsPage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantData,
  });

  @override
  State<RestaurantMenuItemsPage> createState() => _RestaurantMenuItemsPageState();
}

class _RestaurantMenuItemsPageState extends State<RestaurantMenuItemsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<MenuItem> _menuItems = [];
  List<dynamic> _categories = [];
  String? _selectedCategory;
  String _currentQuery = '';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  int _totalCount = 0;

  static const int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final apiService = ApiService();
      
      // Load categories
      final categoriesResponse = await apiService.getCategories();
      if (categoriesResponse.success && categoriesResponse.data != null) {
        _categories = categoriesResponse.data!;
      }

      // Load initial menu items
      await _loadMenuItems(isRefresh: true);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load menu items: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMenuItems({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _menuItems.clear();
      });
    }

    if (!_hasMore && !isRefresh) return;

    try {
      final apiService = ApiService();
      final response = await apiService.getMenuItems(
        restaurantId: widget.restaurantId,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
        category: _selectedCategory,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final results = data['results'] as List<dynamic>? ?? [];
        final count = data['count'] as int? ?? 0;
        
        // Convert JSON results to MenuItem objects
        final menuItems = results
            .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
            .toList();

        setState(() {
          if (isRefresh) {
            _menuItems = menuItems;
          } else {
            _menuItems.addAll(menuItems);
          }
          _totalCount = count;
          _hasMore = results.length == _pageSize;
          _currentPage++;
          _isLoading = false;
          _isLoadingMore = false;
          _hasError = false;
        });
      } else {
        throw Exception(response.error ?? 'Failed to load menu items');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load menu items: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadMenuItems();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentQuery = query;
      });
      _loadMenuItems(isRefresh: true);
    });
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadMenuItems(isRefresh: true);
  }

  Future<void> _onRefresh() async {
    await _loadMenuItems(isRefresh: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CartWrapper(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header with restaurant info and search
            _buildHeader(),
            
            // Category filters
            _buildCategoryFilters(),
            
            // Results count
            if (_totalCount > 0 || _currentQuery.isNotEmpty || _selectedCategory != null)
              _buildResultsHeader(),
            
            // Content area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with back button and title
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Menu Items',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.restaurantName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _currentQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1, // +1 for "All" chip
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" chip
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  if (selected) _onCategoryChanged(null);
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                checkmarkColor: Theme.of(context).primaryColor,
              ),
            );
          }

          final category = _categories[index - 1];
          final categoryName = category['name'] ?? 'Category';
          final categoryId = category['id']?.toString();

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categoryName),
              selected: _selectedCategory == categoryId,
              onSelected: (selected) {
                _onCategoryChanged(selected ? categoryId : null);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$_totalCount items found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (_currentQuery.isNotEmpty || _selectedCategory != null)
            TextButton(
              onPressed: () {
                _debounceTimer?.cancel();
                _searchController.clear();
                setState(() {
                  _currentQuery = '';
                  _selectedCategory = null;
                });
                _loadMenuItems(isRefresh: true);
              },
              child: const Text('Clear filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return ErrorStateWidget(
        message: _errorMessage,
        onRetry: _loadInitialData,
      );
    }

    if (_menuItems.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.restaurant_menu,
        title: 'No menu items found',
        subtitle: _currentQuery.isNotEmpty || _selectedCategory != null
            ? 'Try adjusting your search or filters'
            : 'This restaurant hasn\'t added any menu items yet',
        actionText: _currentQuery.isNotEmpty || _selectedCategory != null ? 'Clear filters' : null,
        onActionPressed: _currentQuery.isNotEmpty || _selectedCategory != null
            ? () {
                _searchController.clear();
                setState(() {
                  _currentQuery = '';
                  _selectedCategory = null;
                });
                _loadMenuItems(isRefresh: true);
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _menuItems.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _menuItems.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final menuItem = _menuItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MenuItemCard(
              menuItem: menuItem,
              onTap: () {
                CartHelpers.showMenuItemModal(context, menuItem);
              },
            ),
          );
        },
      ),
    );
  }
}