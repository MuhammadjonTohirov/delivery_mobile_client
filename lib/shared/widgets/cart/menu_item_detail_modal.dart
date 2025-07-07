import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/models.dart';
import '../../../features/cart/presentation/bloc/cart_bloc.dart';

class MenuItemDetailModal extends StatefulWidget {
  final MenuItem menuItem;

  const MenuItemDetailModal({
    super.key,
    required this.menuItem,
  });

  @override
  State<MenuItemDetailModal> createState() => _MenuItemDetailModalState();
}

class _MenuItemDetailModalState extends State<MenuItemDetailModal> {
  int quantity = 1;
  String? notes;
  List<String> selectedOptions = [];
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.menuItem;
    final name = item.name;
    final description = item.description;
    final price = item.price;
    final imageUrl = item.image;
    final options = item.options;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  if (imageUrl != null)
                    Container(
                      width: double.infinity,
                      height: 200,
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
                      width: double.infinity,
                      height: 200,
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
                      Text(
                        widget.menuItem.formattedPrice,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Options (if any)
                  if (options.isNotEmpty) ...[
                    Text(
                      'Customize your order',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...options.map((option) => _buildOptionItem(option)),
                    const SizedBox(height: 24),
                  ],
                  
                  // Special Instructions
                  Text(
                    'Special Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      hintText: 'Add any special requests...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      notes = value.isEmpty ? null : value;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
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
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Add to Cart Button
                  AddToCartButton(
                    menuItem: widget.menuItem,
                    quantity: quantity,
                    notes: notes,
                    selectedOptions: selectedOptions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(MenuItemOption option) {
    final optionName = option.name;
    final optionPrice = option.price;
    final isSelected = selectedOptions.contains(optionName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(optionName),
        subtitle: option.hasAdditionalCost ? Text(option.formattedPrice) : null,
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
        activeColor: Theme.of(context).primaryColor,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}

class AddToCartButton extends StatelessWidget {
  final MenuItem menuItem;
  final int quantity;
  final String? notes;
  final List<String> selectedOptions;
  final VoidCallback? onPressed;

  const AddToCartButton({
    super.key,
    required this.menuItem,
    required this.quantity,
    this.notes,
    required this.selectedOptions,
    this.onPressed,
  });

  @override
  /// Builds a widget for the "Add to Cart" button, which displays the total price
  /// and handles the action of adding a menu item to the cart. The button shows
  /// a loading indicator while the cart update is in progress and provides feedback
  /// on successful addition or error via snack bars. The widget is styled with
  /// padding, white background, and a shadow effect.

  Widget build(BuildContext context) {
    final price = menuItem.price;
    final totalPrice = price * quantity;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartLoaded) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${menuItem.name} added to cart'),
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
            
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : (onPressed ?? () {
                  // Create a CartItem from MenuItem
                  final cartItem = CartItem.fromMenuItem(
                    menuItem: menuItem,
                    quantity: quantity,
                    notes: notes,
                    selectedOptions: selectedOptions,
                  );

                  // Convert to legacy format for current CartBloc
                  context.read<CartBloc>().add(CartItemAdded(item: cartItem.toLegacyJson()));
                }),
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
                        'Add to Cart • ${_formatPrice(
                          totalPrice, 
                          menuItem.currencyInfo?.code, 
                          menuItem.currencyInfo?.symbol
                          )}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method for formatting price with currency
  String _formatPrice(double amount, String? currencyCode, String? currencySymbol) {
    if (currencySymbol != null) {
      final decimals = _getDecimalDigitsForCurrency(currencyCode);
      return '$currencySymbol${amount.toStringAsFixed(decimals)}';
    } else if (currencyCode != null) {
      switch (currencyCode.toUpperCase()) {
        case 'USD':
          return '\$${amount.toStringAsFixed(2)}';
        case 'RUB':
          return '₽${amount.toStringAsFixed(2)}';
        case 'UZS':
          return '${amount.toStringAsFixed(0)} сўм';
        case 'EUR':
          return '€${amount.toStringAsFixed(2)}';
        case 'GBP':
          return '£${amount.toStringAsFixed(2)}';
        default:
          return '$currencyCode ${amount.toStringAsFixed(2)}';
      }
    }
    return '\$${amount.toStringAsFixed(2)}'; // fallback
  }

  int _getDecimalDigitsForCurrency(String? currencyCode) {
    if (currencyCode == null) return 2;
    
    switch (currencyCode.toUpperCase()) {
      case 'UZS':
        return 0;
      default:
        return 2;
    }
  }
}