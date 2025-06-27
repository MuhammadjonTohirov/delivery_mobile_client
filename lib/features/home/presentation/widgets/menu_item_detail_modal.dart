import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/utils/formatters/currency_formatter.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class MenuItemDetailModal extends StatefulWidget {
  final Map<String, dynamic> menuItem;

  const MenuItemDetailModal({
    super.key,
    required this.menuItem,
  });

  @override
  State<MenuItemDetailModal> createState() => _MenuItemDetailModalState();
}

class _MenuItemDetailModalState extends State<MenuItemDetailModal> {
  int quantity = 1;
  String notes = '';
  List<String> selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    final name = widget.menuItem['name'] ?? 'Menu Item';
    final description = widget.menuItem['description'] ?? '';
    final price = (double.tryParse(widget.menuItem['price'] ?? '0.0')?? 0.0);
    final imageUrl = widget.menuItem['image'];
    final options = widget.menuItem['options'] as List<dynamic>? ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  if (imageUrl != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Name and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        CurrencyFormatter.formatUSD(price),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Description
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                  
                  // Options
                  if (options.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Customize your order',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...options.map((option) => _buildOptionTile(option)),
                  ],
                  
                  // Notes
                  const SizedBox(height: 24),
                  Text(
                    'Special instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Add any special instructions...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      setState(() {
                        notes = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quantity and Add to Cart
                  Row(
                    children: [
                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: quantity > 1 ? () {
                                setState(() {
                                  quantity--;
                                });
                              } : null,
                              icon: const Icon(Icons.remove),
                              color: Theme.of(context).primaryColor,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$quantity',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              icon: const Icon(Icons.add),
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Add to Cart Button
                      Expanded(
                        child: BlocConsumer<CartBloc, CartState>(
                          listener: (context, state) {
                            if (state is CartLoaded) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$name added to cart'),
                                  backgroundColor: Theme.of(context).primaryColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else if (state is CartError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            final isLoading = state is CartLoading;
                            final totalPrice = price * quantity;
                            
                            return ElevatedButton(
                              onPressed: isLoading ? null : () {
                                _addToCart(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Add to Cart • ${CurrencyFormatter.formatUSD(totalPrice)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(dynamic option) {
    final optionName = option['name'] ?? option.toString();
    final optionPrice = option['price'] != null ? (option['price'] as num).toDouble() : 0.0;
    final isSelected = selectedOptions.contains(optionName);

    return CheckboxListTile(
      title: Text(optionName),
      subtitle: optionPrice > 0 ? Text('+${CurrencyFormatter.formatUSD(optionPrice)}') : null,
      value: isSelected,
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedOptions.add(optionName);
          } else {
            selectedOptions.remove(optionName);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _addToCart(BuildContext context) {
    // Create cart item from menu item
    final cartItem = {
      'id': widget.menuItem['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'menu_item_id': widget.menuItem['id'],
      'name': widget.menuItem['name'],
      'description': widget.menuItem['description'],
      'price': widget.menuItem['price'],
      'image': widget.menuItem['image'],
      'quantity': quantity,
      'notes': notes.isNotEmpty ? notes : null,
      'selected_options': selectedOptions.isNotEmpty ? selectedOptions : null,
      'restaurant_id': widget.menuItem['restaurant_id'],
      'restaurant_name': widget.menuItem['restaurant_name'],
    };

    // Add to cart using the local cart system first
    context.read<CartBloc>().add(CartItemAdded(item: cartItem));
  }
}