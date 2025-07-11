import 'package:flutter/material.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

/// Cart icon with badge following Single Responsibility Principle
/// Responsible only for displaying cart icon with item count badge
class CartBadgeIcon extends StatelessWidget {
  final CartState cartState;
  final bool isActive;

  const CartBadgeIcon({
    super.key,
    required this.cartState,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = cartState is CartLoaded 
        ? (cartState as CartLoaded).itemCount 
        : 0;

    return Stack(
      children: [
        Icon(
          isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined,
        ),
        if (itemCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                itemCount > 99 ? '99+' : '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}