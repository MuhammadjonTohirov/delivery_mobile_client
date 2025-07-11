import 'package:delivery_customer/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_customer/core/services/api/api_service.dart';
import '../../../../shared/utils/formatters/currency_formatter.dart';
import '../../../../shared/widgets/states/error_state_widget.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class MenuItemDetailsPage extends StatefulWidget {
  final String itemId;
  final Map<String, dynamic>? initialData;

  const MenuItemDetailsPage({
    super.key,
    required this.itemId,
    this.initialData,
  });

  @override
  State<MenuItemDetailsPage> createState() => _MenuItemDetailsPageState();
}

class _MenuItemDetailsPageState extends State<MenuItemDetailsPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _menuItem;
  bool _isLoading = true;
  String? _errorMessage;
  int _quantity = 1;
  String? _notes;
  final List<String> _selectedOptions = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _menuItem = widget.initialData;
      _isLoading = false;
    } else {
      _loadMenuItemDetails();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuItemDetails() async {
    try {
      final response = await _apiService.getMenuItemDetails(widget.itemId);
      
      if (response.success && response.data != null) {
        setState(() {
          _menuItem = response.data;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.error ?? 'Failed to load menu item details';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load menu item details: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Menu Item')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Menu Item')),
        body: ErrorStateWidget(
          message: _errorMessage!,
          onRetry: _loadMenuItemDetails,
        ),
      );
    }

    if (_menuItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Menu Item')),
        body: const ErrorStateWidget(
          message: 'Menu item not found',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_menuItem!['name'] ?? 'Menu Item'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemImage(),
                  _buildItemDetails(),
                  _buildIngredients(),
                  _buildOptions(),
                  _buildNotes(),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAddToCartSection(),
    );
  }

  Widget _buildItemImage() {
    final imageUrl = _menuItem!['image'] ?? _menuItem!['image_url'];
    
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: imageUrl != null && imageUrl.toString().isNotEmpty
          ? Image.network(
              _buildImageUrl(imageUrl.toString()),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 64,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '${AppConstants.serverUrl}/media/$cleanPath';
  }

  Widget _buildItemDetails() {
    final theme = Theme.of(context);
    final price = (_menuItem!['price'] ?? 0.0).toDouble();
    final description = _menuItem!['description'] ?? '';
    final isAvailable = _menuItem!['is_available'] ?? true;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _menuItem!['name'] ?? 'Menu Item',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(price),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    final ingredients = _menuItem!['ingredients'] as List<dynamic>?;
    
    if (ingredients == null || ingredients.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Ingredients',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ingredients.map((ingredient) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  ingredient.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    final options = _menuItem!['options'] as List<dynamic>?;
    
    if (options == null || options.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Customize',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...options.map((option) {
            final optionId = option['id'].toString();
            final isSelected = _selectedOptions.contains(optionId);
            
            return CheckboxListTile(
              title: Text(option['name'] ?? ''),
              subtitle: option['extra_price'] != null && option['extra_price'] > 0
                  ? Text('+${_formatCurrency(option['extra_price'].toDouble())}')
                  : null,
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedOptions.add(optionId);
                  } else {
                    _selectedOptions.remove(optionId);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Special Instructions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add any special instructions...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _notes = value.isEmpty ? null : value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartSection() {
    final theme = Theme.of(context);
    final isAvailable = _menuItem!['is_available'] ?? true;
    final price = (_menuItem!['price'] ?? 0.0).toDouble();
    
    // Calculate total price with options
    double totalPrice = price * _quantity;
    for (final optionId in _selectedOptions) {
      final option = (_menuItem!['options'] as List<dynamic>?)
          ?.firstWhere((opt) => opt['id'].toString() == optionId, orElse: () => null);
      if (option != null && option['extra_price'] != null) {
        totalPrice += option['extra_price'].toDouble() * _quantity;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    _quantity.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Add to cart button
            Expanded(
              child: ElevatedButton(
                onPressed: isAvailable ? _addToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isAvailable 
                      ? 'Add to Cart • ${_formatCurrency(totalPrice)}'
                      : 'Out of Stock',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    final cartBloc = context.read<CartBloc>();
    
    cartBloc.add(CartMenuItemAdded(
      menuItemId: widget.itemId,
      quantity: _quantity,
      notes: _notes,
      selectedOptions: _selectedOptions.isNotEmpty ? _selectedOptions : null,
    ));
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_menuItem!['name']} added to cart'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Go back to previous screen
    Navigator.of(context).pop();
  }

  String _formatCurrency(double amount) {
    // Try to get currency info from the menu item
    final currencyCode = _menuItem?['currency_code'] as String?;
    final currencySymbol = _menuItem?['currency_symbol'] as String?;
    
    if (currencyCode != null || currencySymbol != null) {
      return CurrencyFormatter.formatWithCurrency(
        amount,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
      );
    }
    
    // Fallback to USD if no currency info available
    return CurrencyFormatter.formatUSD(amount);
  }
}