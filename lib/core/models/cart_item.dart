import 'menu_item.dart';

class CartItem {
  final String id;
  final MenuItem menuItem;
  final int quantity;
  final String? notes;
  final List<String> selectedOptions;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    this.notes,
    this.selectedOptions = const [],
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      menuItem: MenuItem.fromJson(json['menu_item'] ?? json),
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes']?.toString(),
      selectedOptions: _parseSelectedOptions(json['selected_options']),
      addedAt: _parseDateTime(json['added_at']) ?? DateTime.now(),
    );
  }

  factory CartItem.fromMenuItem({
    required MenuItem menuItem,
    int quantity = 1,
    String? notes,
    List<String>? selectedOptions,
  }) {
    return CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      menuItem: menuItem,
      quantity: quantity,
      notes: notes,
      selectedOptions: selectedOptions ?? [],
      addedAt: DateTime.now(),
    );
  }

  // Factory to create from legacy Map format for backward compatibility
  factory CartItem.fromLegacyJson(Map<String, dynamic> json) {
    // Convert legacy format to MenuItem first
    final menuItemJson = {
      'id': json['menu_item_id'] ?? json['id'],
      'name': json['name'] ?? '',
      'description': json['description'] ?? '',
      'price': json['price'] ?? 0.0,
      'image': json['image'],
      'restaurant_id': json['restaurant_id'] ?? '',
      'is_available': json['is_available'] ?? true,
    };

    return CartItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      menuItem: MenuItem.fromJson(menuItemJson),
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes']?.toString(),
      selectedOptions: _parseSelectedOptions(json['selected_options']),
      addedAt: _parseDateTime(json['added_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'notes': notes,
      'selected_options': selectedOptions,
      'added_at': addedAt.toIso8601String(),
    };
  }

  // Legacy format for API compatibility
  Map<String, dynamic> toLegacyJson() {
    return {
      'id': id,
      'menu_item_id': menuItem.id,
      'name': menuItem.name,
      'description': menuItem.description,
      'price': menuItem.price,
      'image': menuItem.image,
      'restaurant_id': menuItem.restaurantId,
      'quantity': quantity,
      'notes': notes,
      'selected_options': selectedOptions,
      'is_available': menuItem.isAvailable,
      'added_at': addedAt.toIso8601String(),
    };
  }

  // Helper methods
  static List<String> _parseSelectedOptions(dynamic options) {
    if (options == null) return [];
    if (options is List) {
      return options.map((option) => option.toString()).toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    if (dateTime is String) {
      return DateTime.tryParse(dateTime);
    }
    return null;
  }

  // Computed properties
  double get itemTotal => menuItem.price * quantity;
  String get restaurantId => menuItem.restaurantId;
  String get formattedItemTotal => '\$${itemTotal.toStringAsFixed(2)}';
  bool get hasNotes => notes != null && notes!.isNotEmpty;
  bool get hasSelectedOptions => selectedOptions.isNotEmpty;

  // Create a copy with modified fields
  CartItem copyWith({
    String? id,
    MenuItem? menuItem,
    int? quantity,
    String? notes,
    List<String>? selectedOptions,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // Update quantity
  CartItem updateQuantity(int newQuantity) {
    return copyWith(quantity: newQuantity);
  }

  // Add to quantity
  CartItem addQuantity(int amount) {
    return copyWith(quantity: quantity + amount);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && 
           other.id == id && 
           other.menuItem.id == menuItem.id;
  }

  @override
  int get hashCode => Object.hash(id, menuItem.id);

  @override
  String toString() {
    return 'CartItem(id: $id, menuItem: ${menuItem.name}, quantity: $quantity, total: $formattedItemTotal)';
  }
}