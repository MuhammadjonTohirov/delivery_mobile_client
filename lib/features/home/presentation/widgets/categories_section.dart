import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../pages/category_results_page.dart';
import 'category_icon_helper.dart';

/// Categories section widget following Single Responsibility Principle
/// Responsible only for displaying the categories horizontal list
class CategoriesSection extends StatelessWidget {
  final List<Category> categories;
  
  const CategoriesSection({
    super.key, 
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        categories.isEmpty
            ? const Center(child: Text('No categories available'))
            : SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryCard(category: category);
                  },
                ),
              ),
      ],
    );
  }
}

/// Private category card widget following Single Responsibility Principle
/// Responsible only for displaying a single category item
class _CategoryCard extends StatelessWidget {
  final Category category;
  
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryResultsPage(
              categoryId: category.id,
              categoryName: category.name,
            ),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: category.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        category.image!,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            CategoryIconHelper.getCategoryIcon(category.name),
                            size: 35,
                            color: Theme.of(context).primaryColor,
                          );
                        },
                      ),
                    )
                  : Icon(
                      CategoryIconHelper.getCategoryIcon(category.name),
                      size: 35,
                      color: Theme.of(context).primaryColor,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}