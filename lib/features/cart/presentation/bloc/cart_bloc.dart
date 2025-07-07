import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/api_service.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class CartLoadRequested extends CartEvent {}

class CartItemAdded extends CartEvent {
  final Map<String, dynamic> item;

  const CartItemAdded({required this.item});

  @override
  List<Object> get props => [item];
}

class CartMenuItemAdded extends CartEvent {
  final String menuItemId;
  final int quantity;
  final String? notes;
  final List<String>? selectedOptions;

  const CartMenuItemAdded({
    required this.menuItemId,
    this.quantity = 1,
    this.notes,
    this.selectedOptions,
  });

  @override
  List<Object> get props => [menuItemId, quantity];
}

class CartItemRemoved extends CartEvent {
  final String itemId;

  const CartItemRemoved({required this.itemId});

  @override
  List<Object> get props => [itemId];
}

class CartItemQuantityUpdated extends CartEvent {
  final String itemId;
  final int quantity;

  const CartItemQuantityUpdated({
    required this.itemId,
    required this.quantity,
  });

  @override
  List<Object> get props => [itemId, quantity];
}

class CartCleared extends CartEvent {}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final int itemCount;

  const CartLoaded({
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.itemCount,
  });

  @override
  List<Object> get props => [items, subtotal, deliveryFee, tax, total, itemCount];
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final ApiService _apiService;

  CartBloc({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService(),
        super(CartInitial()) {
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartMenuItemAdded>(_onCartMenuItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartItemQuantityUpdated>(_onCartItemQuantityUpdated);
    on<CartCleared>(_onCartCleared);
  }

  Future<void> _onCartLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      // Always load from local storage first for better UX
      final localItems = StorageService.getCartData();
      print('🛒 Cart Debug: Local storage has ${localItems.length} items');
      
      // Try to load from server first
      final response = await _apiService.getCart();
      print('🛒 Cart Debug: Server response success: ${response.success}');
      
      if (response.success && response.data != null) {
        final cartData = response.data!;
        final serverItems = cartData['items'] as List<dynamic>? ?? [];
        print('🛒 Cart Debug: Server has ${serverItems.length} items');
        
        // If server has items, use server data
        if (serverItems.isNotEmpty) {
          print('🛒 Cart Debug: Using server data');
          emit(CartLoaded(
            items: serverItems.cast<Map<String, dynamic>>(),
            subtotal: (cartData['subtotal'] ?? 0.0).toDouble(),
            deliveryFee: (cartData['delivery_fee'] ?? 0.0).toDouble(),
            tax: (cartData['tax'] ?? 0.0).toDouble(),
            total: (cartData['total'] ?? 0.0).toDouble(),
            itemCount: (cartData['item_count'] ?? 0) as int,
          ));
        } else {
          // Server is empty, use local storage
          print('🛒 Cart Debug: Server empty, using local storage');
          final calculations = _calculateTotals(localItems);
          
          emit(CartLoaded(
            items: localItems,
            subtotal: calculations['subtotal']!,
            deliveryFee: calculations['deliveryFee']!,
            tax: calculations['tax']!,
            total: calculations['total']!,
            itemCount: calculations['itemCount']!.toInt(),
          ));
        }
      } else {
        // Fallback to local storage if server fails
        print('🛒 Cart Debug: Server failed, using local storage');
        final calculations = _calculateTotals(localItems);
        
        emit(CartLoaded(
          items: localItems,
          subtotal: calculations['subtotal']!,
          deliveryFee: calculations['deliveryFee']!,
          tax: calculations['tax']!,
          total: calculations['total']!,
          itemCount: calculations['itemCount']!.toInt(),
        ));
      }
    } catch (e) {
      print('🛒 Cart Debug: Exception caught: $e');
      // Fallback to local storage
      try {
        final items = StorageService.getCartData();
        print('🛒 Cart Debug: Exception fallback, local has ${items.length} items');
        final calculations = _calculateTotals(items);
        
        emit(CartLoaded(
          items: items,
          subtotal: calculations['subtotal']!,
          deliveryFee: calculations['deliveryFee']!,
          tax: calculations['tax']!,
          total: calculations['total']!,
          itemCount: calculations['itemCount']!.toInt(),
        ));
      } catch (localError) {
        print('🛒 Cart Debug: Local storage also failed: $localError');
        emit(CartError(message: 'Failed to load cart: ${e.toString()}'));
      }
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      print('🛒 Adding item to cart: ${event.item['name']}');
      final items = StorageService.getCartData();
      print('🛒 Current cart has ${items.length} items');
      
      // Check if item already exists
      final existingItemIndex = items.indexWhere(
        (item) => item['id'] == event.item['id'],
      );
      
      if (existingItemIndex != -1) {
        // Update quantity if item exists
        print('🛒 Item exists, updating quantity');
        items[existingItemIndex]['quantity'] = 
            (items[existingItemIndex]['quantity'] ?? 1) + 1;
      } else {
        // Add new item
        print('🛒 Adding new item');
        final newItem = Map<String, dynamic>.from(event.item);
        newItem['quantity'] = newItem['quantity'] ?? 1;
        items.add(newItem);
      }
      
      await StorageService.setCartData(items);
      print('🛒 Saved to storage, cart now has ${items.length} items');
      
      final calculations = _calculateTotals(items);
      emit(CartLoaded(
        items: items,
        subtotal: calculations['subtotal']!,
        deliveryFee: calculations['deliveryFee']!,
        tax: calculations['tax']!,
        total: calculations['total']!,
        itemCount: calculations['itemCount']!.toInt(),
      ));
      print('🛒 Emitted CartLoaded with ${items.length} items');
    } catch (e) {
      print('🛒 Error adding item: $e');
      emit(CartError(message: 'Failed to add item to cart: ${e.toString()}'));
    }
  }

  Future<void> _onCartMenuItemAdded(
    CartMenuItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoading());
      
      final response = await _apiService.addToCart(
        menuItemId: event.menuItemId,
        quantity: event.quantity,
        notes: event.notes,
        selectedOptions: event.selectedOptions,
      );
      
      if (response.success) {
        // Reload cart after successful addition
        final cartResponse = await _apiService.getCart();
        
        if (cartResponse.success && cartResponse.data != null) {
          final cartData = cartResponse.data!;
          final serverItems = cartData['items'] as List<dynamic>? ?? [];
          
          emit(CartLoaded(
            items: serverItems.cast<Map<String, dynamic>>(),
            subtotal: (cartData['subtotal'] ?? 0.0).toDouble(),
            deliveryFee: (cartData['delivery_fee'] ?? 0.0).toDouble(),
            tax: (cartData['tax'] ?? 0.0).toDouble(),
            total: (cartData['total'] ?? 0.0).toDouble(),
            itemCount: (cartData['item_count'] ?? 0) as int,
          ));
        } else {
          // Fallback to local storage
          final items = StorageService.getCartData();
          final calculations = _calculateTotals(items);
          
          emit(CartLoaded(
            items: items,
            subtotal: calculations['subtotal']!,
            deliveryFee: calculations['deliveryFee']!,
            tax: calculations['tax']!,
            total: calculations['total']!,
            itemCount: calculations['itemCount']!.toInt(),
          ));
        }
      } else {
        emit(CartError(message: response.error ?? 'Failed to add item to cart'));
      }
    } catch (e) {
      emit(CartError(message: 'Failed to add item to cart: ${e.toString()}'));
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
      final response = await _apiService.removeFromCart(event.itemId);
      
      if (response.success) {
        // Reload cart after successful removal
        add(CartLoadRequested());
      } else {
        // Fallback to local storage
        final items = StorageService.getCartData();
        items.removeWhere((item) => item['id'].toString() == event.itemId);
        
        await StorageService.setCartData(items);
        
        final calculations = _calculateTotals(items);
        emit(CartLoaded(
          items: items,
          subtotal: calculations['subtotal']!,
          deliveryFee: calculations['deliveryFee']!,
          tax: calculations['tax']!,
          total: calculations['total']!,
          itemCount: calculations['itemCount']!.toInt(),
        ));
      }
    } catch (e) {
      emit(CartError(message: 'Failed to remove item from cart: ${e.toString()}'));
    }
  }

  Future<void> _onCartItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      if (event.quantity <= 0) {
        // Remove item if quantity is 0 or less
        add(CartItemRemoved(itemId: event.itemId));
        return;
      }
      
      final response = await _apiService.updateCartItem(
        cartItemId: event.itemId,
        quantity: event.quantity,
      );
      
      if (response.success) {
        // Reload cart after successful update
        add(CartLoadRequested());
      } else {
        // Fallback to local storage
        final items = StorageService.getCartData();
        final itemIndex = items.indexWhere(
          (item) => item['id'].toString() == event.itemId,
        );
        
        if (itemIndex != -1) {
          items[itemIndex]['quantity'] = event.quantity;
          
          await StorageService.setCartData(items);
          
          final calculations = _calculateTotals(items);
          emit(CartLoaded(
            items: items,
            subtotal: calculations['subtotal']!,
            deliveryFee: calculations['deliveryFee']!,
            tax: calculations['tax']!,
            total: calculations['total']!,
            itemCount: calculations['itemCount']!.toInt(),
          ));
        }
      }
    } catch (e) {
      emit(CartError(message: 'Failed to update item quantity: ${e.toString()}'));
    }
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    try {
      final response = await _apiService.clearCart();
      
      if (response.success) {
        emit(const CartLoaded(
          items: [],
          subtotal: 0.0,
          deliveryFee: 0.0,
          tax: 0.0,
          total: 0.0,
          itemCount: 0,
        ));
      } else {
        // Fallback to local storage
        await StorageService.clearCartData();
        emit(const CartLoaded(
          items: [],
          subtotal: 0.0,
          deliveryFee: 0.0,
          tax: 0.0,
          total: 0.0,
          itemCount: 0,
        ));
      }
    } catch (e) {
      emit(CartError(message: 'Failed to clear cart: ${e.toString()}'));
    }
  }

  Map<String, double> _calculateTotals(List<Map<String, dynamic>> items) {
    double subtotal = 0.0;
    int itemCount = 0;
    
    for (final item in items) {
      // Handle both string and double price values
      final priceValue = item['price'];
      double price = 0.0;
      
      if (priceValue is double) {
        price = priceValue;
      } else if (priceValue is int) {
        price = priceValue.toDouble();
      } else if (priceValue is String) {
        price = double.tryParse(priceValue) ?? 0.0;
      }
      
      final quantityValue = item['quantity'];
      int quantity = 1;
      
      if (quantityValue is int) {
        quantity = quantityValue;
      } else if (quantityValue is double) {
        quantity = quantityValue.toInt();
      } else if (quantityValue is String) {
        quantity = int.tryParse(quantityValue) ?? 1;
      }
      
      subtotal += price * quantity;
      itemCount += quantity;
    }
    
    final deliveryFee = subtotal > 0 ? 2.99 : 0.0; // Free delivery over certain amount
    final tax = subtotal * 0.08; // 8% tax
    final total = subtotal + deliveryFee + tax;
    
    return {
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'itemCount': itemCount.toDouble(),
    };
  }
}