import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/cart/cart_wrapper.dart';
import '../../../../shared/widgets/cart/cart_helpers.dart';
import '../../../../shared/widgets/menu/menu_item_card.dart';
import '../../../../shared/widgets/states/error_state_widget.dart';
import '../../../../shared/widgets/states/empty_state_widget.dart';

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
  final ScrollController _scrollController = ScrollController();
  
  List<MenuItem> _menuItems = [];
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
    _loadMenuItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMenuItems({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _menuItems.clear();
        _isLoading = true;
        _hasError = false;
      });
    }

    if (!_hasMore && !isRefresh) return;

    try {
      final apiService = ApiService();
      
      // Load menu items from all restaurants in this category
      final response = await apiService.getMenuItems(
        category: widget.categoryId,
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
          if (isRefresh || _currentPage == 1) {
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

  Future<void> _onRefresh() async {
    await _loadMenuItems(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return CartWrapper(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('${widget.categoryName} Menu'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _buildContent(),
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
        onRetry: () => _loadMenuItems(isRefresh: true),
      );
    }

    if (_menuItems.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.restaurant_menu,
        title: 'No menu items found',
        subtitle: 'No items available in this category yet',
        actionText: 'Refresh',
        onActionPressed: () => _loadMenuItems(isRefresh: true),
      );
    }

    return Column(
      children: [
        // Results count header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            children: [
              Text(
                '$_totalCount items found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // Menu items list
        Expanded(
          child: RefreshIndicator(
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
          ),
        ),
      ],
    );
  }
}