import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class SearchSuggestionsWidget extends StatelessWidget {
  final List<dynamic> categories;
  final List<String> recentSearches;
  final Function(String) onSearchTap;
  final Function(String) onCategoryTap;

  const SearchSuggestionsWidget({
    super.key,
    required this.categories,
    required this.recentSearches,
    required this.onSearchTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (recentSearches.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              title: l10n.recentSearches,
              icon: Icons.history,
              action: TextButton(
                onPressed: () {
                  // Clear recent searches
                },
                child: Text(l10n.clearAll),
              ),
            ),
            const SizedBox(height: 12),
            ...recentSearches.map((search) {
              return _buildSearchSuggestionTile(
                context,
                title: search,
                icon: Icons.history,
                onTap: () => onSearchTap(search),
              );
            }).toList(),
            const SizedBox(height: 24),
          ],
          
          // Popular Categories
          _buildSectionHeader(
            context,
            title: l10n.filterByCategory,
            icon: Icons.category,
          ),
          const SizedBox(height: 12),
          _buildCategoryGrid(context),
          
          const SizedBox(height: 24),
          
          // Popular Search Terms
          _buildSectionHeader(
            context,
            title: l10n.popularItems,
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 12),
          ..._getPopularSearches().map((search) {
            return _buildSearchSuggestionTile(
              context,
              title: search,
              icon: Icons.search,
              onTap: () => onSearchTap(search),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? action,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (action != null) ...[
          const Spacer(),
          action,
        ],
      ],
    );
  }

  Widget _buildSearchSuggestionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.north_west,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
      ),
      itemCount: categories.length > 8 ? 8 : categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryName = category['name'] ?? '';
        final categoryId = category['id'] ?? '';
        
        return GestureDetector(
          onTap: () => onCategoryTap(categoryId),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getCategoryIcon(categoryName),
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String name) {
    final lowercaseName = name.toLowerCase();
    if (lowercaseName.contains('pizza')) return Icons.local_pizza;
    if (lowercaseName.contains('burger')) return Icons.lunch_dining;
    if (lowercaseName.contains('asian') || lowercaseName.contains('chinese')) return Icons.ramen_dining;
    if (lowercaseName.contains('dessert') || lowercaseName.contains('sweet')) return Icons.cake;
    if (lowercaseName.contains('coffee') || lowercaseName.contains('drink')) return Icons.local_cafe;
    if (lowercaseName.contains('salad') || lowercaseName.contains('healthy')) return Icons.eco;
    if (lowercaseName.contains('fast') || lowercaseName.contains('quick')) return Icons.flash_on;
    if (lowercaseName.contains('seafood') || lowercaseName.contains('fish')) return Icons.set_meal;
    return Icons.restaurant_menu;
  }

  List<String> _getPopularSearches() {
    return [
      'Pizza',
      'Burger',
      'Pasta',
      'Sushi',
      'Salad',
      'Coffee',
      'Ice Cream',
      'Chicken',
    ];
  }
}