class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String restaurantId;
  final bool isAvailable;
  final String? category;
  final List<MenuItemOption> options;
  final Map<String, dynamic>? nutritionInfo;
  final List<String> allergens;
  final int? preparationTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? currencyCode;
  final String? currencySymbol;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.restaurantId,
    this.isAvailable = true,
    this.category,
    this.options = const [],
    this.nutritionInfo,
    this.allergens = const [],
    this.preparationTime,
    this.createdAt,
    this.updatedAt,
    this.currencyCode,
    this.currencySymbol,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parsePrice(json['price']),
      image: json['image']?.toString(),
      restaurantId: json['restaurant_id']?.toString() ?? json['restaurant']?.toString() ?? '',
      isAvailable: json['is_available'] ?? json['available'] ?? true,
      category: json['category']?.toString(),
      options: _parseOptions(json['options']),
      nutritionInfo: json['nutrition_info'] as Map<String, dynamic>?,
      allergens: _parseStringList(json['allergens']),
      preparationTime: json['preparation_time'] as int?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      currencyCode: json['currency_code']?.toString() ?? json['currency']?.toString(),
      currencySymbol: json['currency_symbol']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'restaurant_id': restaurantId,
      'is_available': isAvailable,
      'category': category,
      'options': options.map((option) => option.toJson()).toList(),
      'nutrition_info': nutritionInfo,
      'allergens': allergens,
      'preparation_time': preparationTime,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
    };
  }

  // Helper method to safely parse price from various formats
  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      // Remove currency symbols and parse
      final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanPrice) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to parse options list
  static List<MenuItemOption> _parseOptions(dynamic options) {
    if (options == null) return [];
    if (options is List) {
      return options
          .map((option) => option is Map<String, dynamic> 
              ? MenuItemOption.fromJson(option) 
              : MenuItemOption.empty())
          .where((option) => option.name.isNotEmpty)
          .toList();
    }
    return [];
  }

  // Helper method to parse string lists
  static List<String> _parseStringList(dynamic list) {
    if (list == null) return [];
    if (list is List) {
      return list.map((item) => item.toString()).toList();
    }
    if (list is String) {
      return list.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    }
    return [];
  }

  // Helper method to parse DateTime
  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    if (dateTime is String) {
      return DateTime.tryParse(dateTime);
    }
    return null;
  }

  // Convenience methods
  bool get hasImage => image != null && image!.isNotEmpty;
  bool get hasOptions => options.isNotEmpty;
  String get formattedPrice {
    // Import the CurrencyFormatter here
    return _formatPrice(price, currencyCode: currencyCode, currencySymbol: currencySymbol);
  }
  
  // Helper method for formatting price with currency
  static String _formatPrice(double amount, {String? currencyCode, String? currencySymbol}) {
    if (currencySymbol != null) {
      // If we have exact symbol from server, use it with proper decimal places
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
  
  // Helper method to get decimal digits for currency
  static int _getDecimalDigitsForCurrency(String? currencyCode) {
    if (currencyCode == null) return 2;
    
    switch (currencyCode.toUpperCase()) {
      case 'UZS':
        return 0;
      default:
        return 2;
    }
  }
  
  // Create a copy with modified fields
  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? restaurantId,
    bool? isAvailable,
    String? category,
    List<MenuItemOption>? options,
    Map<String, dynamic>? nutritionInfo,
    List<String>? allergens,
    int? preparationTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currencyCode,
    String? currencySymbol,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      restaurantId: restaurantId ?? this.restaurantId,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
      options: options ?? this.options,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      allergens: allergens ?? this.allergens,
      preparationTime: preparationTime ?? this.preparationTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MenuItem(id: $id, name: $name, price: $price, restaurant: $restaurantId)';
  }
}

class MenuItemOption {
  final String id;
  final String name;
  final double price;
  final String? description;
  final bool isRequired;
  final int maxSelections;
  final String? currencyCode;
  final String? currencySymbol;

  const MenuItemOption({
    required this.id,
    required this.name,
    this.price = 0.0,
    this.description,
    this.isRequired = false,
    this.maxSelections = 1,
    this.currencyCode,
    this.currencySymbol,
  });

  factory MenuItemOption.fromJson(Map<String, dynamic> json) {
    return MenuItemOption(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: MenuItem._parsePrice(json['price']),
      description: json['description']?.toString(),
      isRequired: json['is_required'] ?? json['required'] ?? false,
      maxSelections: json['max_selections'] ?? json['max'] ?? 1,
      currencyCode: json['currency_code']?.toString() ?? json['currency']?.toString(),
      currencySymbol: json['currency_symbol']?.toString(),
    );
  }

  factory MenuItemOption.empty() {
    return const MenuItemOption(id: '', name: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'is_required': isRequired,
      'max_selections': maxSelections,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
    };
  }

  bool get hasAdditionalCost => price > 0;
  String get formattedPrice {
    if (price <= 0) return '';
    final formatted = MenuItem._formatPrice(price, currencyCode: currencyCode, currencySymbol: currencySymbol);
    return '+$formatted';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItemOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MenuItemOption(id: $id, name: $name, price: $price)';
  }
}