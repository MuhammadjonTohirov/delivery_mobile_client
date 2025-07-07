import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/router/app_router.dart';

class CartHelpers {
  /// Navigate to menu item detail page for adding to cart
  static Future<void> showMenuItemModal(
    BuildContext context,
    MenuItem menuItem,
  ) async {
    await AppRouter.push(
      context,
      AppRouter.menuItemDetails,
      arguments: {
        'itemId': menuItem.id,
        'initialData': menuItem.toJson(),
      },
    );
  }

  /// Quick add to cart without modal (for simple items)
  static CartItem createCartItem(
    MenuItem menuItem, {
    int quantity = 1,
    String? notes,
    List<String>? selectedOptions,
  }) {
    return CartItem.fromMenuItem(
      menuItem: menuItem,
      quantity: quantity,
      notes: notes,
      selectedOptions: selectedOptions,
    );
  }
}