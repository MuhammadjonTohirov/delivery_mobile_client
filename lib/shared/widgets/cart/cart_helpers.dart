import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import 'menu_item_detail_modal.dart';

class CartHelpers {
  /// Show menu item detail modal for adding to cart
  static Future<void> showMenuItemModal(
    BuildContext context,
    MenuItem menuItem,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuItemDetailModal(menuItem: menuItem),
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