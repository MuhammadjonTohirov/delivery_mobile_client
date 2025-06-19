import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<dynamic> categories;
  final String? selectedCategory;
  final String selectedSort;
  final Function(String?) onCategorySelected;
  final Function(String) onSortSelected;

  const FilterChipsWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.selectedSort,
    required this.onCategorySelected,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // All Categories Chip
            _buildFilterChip(
              context,
              label: l10n.allCategories,
              isSelected: selectedCategory == null,
              onTap: () => onCategorySelected(null),
            ),
            
            const SizedBox(width: 8),
            
            // Category Chips
            ...categories.map((category) {
              final categoryName = category['name'] ?? '';
              final categoryId = category['id'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  context,
                  label: categoryName,
                  isSelected: selectedCategory == categoryId,
                  onTap: () => onCategorySelected(categoryId),
                ),
              );
            }).toList(),
            
            const SizedBox(width: 16),
            
            // Sort Dropdown
            _buildSortDropdown(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey[300]!,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSort,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          items: [
            DropdownMenuItem(
              value: 'popularity',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, size: 16),
                  const SizedBox(width: 8),
                  Text(l10n.sortByPopularity),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'price_asc',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_upward, size: 16),
                  const SizedBox(width: 8),
                  Text('${l10n.sortByPrice} (${l10n.low} - ${l10n.high})'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'price_desc',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_downward, size: 16),
                  const SizedBox(width: 8),
                  Text('${l10n.sortByPrice} (${l10n.high} - ${l10n.low})'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'rating',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16),
                  const SizedBox(width: 8),
                  Text(l10n.sortByRating),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onSortSelected(value);
            }
          },
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}