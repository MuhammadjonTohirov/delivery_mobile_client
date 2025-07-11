import 'dart:async';
import 'package:delivery_customer/core/services/api/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/logger_service.dart';

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

// States with better immutability
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Map<String, dynamic>> items;
  final CartTotals totals;

  const CartLoaded({
    required this.items,
    required this.totals,
  });

  @override
  List<Object> get props => [items, totals];

  // Helper getters for backward compatibility
  double get subtotal => totals.subtotal;
  double get deliveryFee => totals.deliveryFee;
  double get tax => totals.tax;
  double get total => totals.total;
  int get itemCount => totals.itemCount;
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}

// Immutable cart totals model
class CartTotals extends Equatable {
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final int itemCount;

  const CartTotals({
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.itemCount,
  });

  @override
  List<Object> get props => [subtotal, deliveryFee, tax, total, itemCount];
}

// Optimized Bloc with performance improvements
class CartBloc extends Bloc<CartEvent, CartState> {
  final ApiService _apiService;
  Timer? _debounceTimer;
  
  // Cache calculations to avoid recomputation
  final Map<String, CartTotals> _calculationCache = {};

  CartBloc({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService(),
        super(CartInitial()) {
    
    // Add transformers for debouncing frequent events
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartMenuItemAdded>(_onCartMenuItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartItemQuantityUpdated>(
      _onCartItemQuantityUpdated,
      transformer: _debounceTransformer(const Duration(milliseconds: 300)),
    );
    on<CartCleared>(_onCartCleared);
  }

  // Debounce transformer to prevent excessive API calls
  EventTransformer<T> _debounceTransformer<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  Future<void> _onCartLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    
    try {
      // Load local data first for immediate UI update
      final localItems = StorageService.getCartData();
      
      // Emit local data immediately if available
      if (localItems.isNotEmpty) {
        final totals = _calculateTotals(localItems);
        emit(CartLoaded(items: localItems, totals: totals));
      }
      
      // Then try to sync with server
      final response = await _apiService.getCart();
      
      if (response.success && response.data != null) {
        final cartData = response.data!;
        final serverItems = (cartData['items'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ?? [];
        
        if (serverItems.isNotEmpty) {
          // Use server data and update local storage
          await StorageService.setCartData(serverItems);
          
          final totals = CartTotals(
            subtotal: (cartData['subtotal'] ?? 0.0).toDouble(),
            deliveryFee: (cartData['delivery_fee'] ?? 0.0).toDouble(),
            tax: (cartData['tax'] ?? 0.0).toDouble(),
            total: (cartData['total'] ?? 0.0).toDouble(),
            itemCount: (cartData['item_count'] ?? 0) as int,
          );
          
          emit(CartLoaded(items: serverItems, totals: totals));
        } else if (localItems.isEmpty) {
          // Both server and local are empty
          emit(const CartLoaded(
            items: [],
            totals: CartTotals(
              subtotal: 0.0,
              deliveryFee: 0.0,
              tax: 0.0,
              total: 0.0,
              itemCount: 0,
            ),
          ));
        }
        // If server is empty but local has items, keep local data
      } else if (localItems.isEmpty) {
        // Server failed and no local data
        emit(const CartLoaded(
          items: [],
          totals: CartTotals(
            subtotal: 0.0,
            deliveryFee: 0.0,
            tax: 0.0,
            total: 0.0,
            itemCount: 0,
          ),
        ));
      }
      // If server fails but we have local data, keep current state
      
    } catch (e) {
      LoggerService.error('Cart load failed', e);
      
      // Fallback to local storage
      try {
        final items = StorageService.getCartData();
        final totals = _calculateTotals(items);
        emit(CartLoaded(items: items, totals: totals));
      } catch (localError) {
        LoggerService.error('Local cart load failed', localError);
        emit(CartError(message: 'Failed to load cart'));
      }
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = List<Map<String, dynamic>>.from(StorageService.getCartData());
      
      // Check if item already exists
      final existingItemIndex = items.indexWhere(
        (item) => item['id'] == event.item['id'],
      );
      
      if (existingItemIndex != -1) {
        // Update quantity if item exists
        final currentQuantity = _parseInt(items[existingItemIndex]['quantity']);
        items[existingItemIndex]['quantity'] = currentQuantity + 1;
      } else {
        // Add new item
        final newItem = Map<String, dynamic>.from(event.item);
        newItem['quantity'] = newItem['quantity'] ?? 1;
        items.add(newItem);
      }
      
      // Update storage
      await StorageService.setCartData(items);
      
      // Calculate and emit new state
      final totals = _calculateTotals(items);
      emit(CartLoaded(items: items, totals: totals));
      
      LoggerService.debug('Item added to cart', {'itemId': event.item['id'], 'totalItems': items.length});
      
    } catch (e) {
      LoggerService.error('Failed to add item to cart', e);
      emit(CartError(message: 'Failed to add item to cart'));
    }
  }

  Future<void> _onCartMenuItemAdded(
    CartMenuItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      // Don't emit loading for better UX - let UI handle loading state
      
      final response = await _apiService.addToCart(
        menuItemId: event.menuItemId,
        quantity: event.quantity,
        notes: event.notes,
        selectedOptions: event.selectedOptions,
      );
      
      if (response.success) {
        // Refresh cart data from server
        add(CartLoadRequested());
      } else {
        emit(CartError(message: response.error ?? 'Failed to add item to cart'));
      }
    } catch (e) {
      LoggerService.error('Failed to add menu item to cart', e);
      emit(CartError(message: 'Failed to add item to cart'));
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
      // Optimistic update - update UI immediately
      final items = List<Map<String, dynamic>>.from(StorageService.getCartData());
      items.removeWhere((item) => item['id'].toString() == event.itemId);
      
      await StorageService.setCartData(items);
      final totals = _calculateTotals(items);
      emit(CartLoaded(items: items, totals: totals));
      
      // Then sync with server in background
      _apiService.removeFromCart(event.itemId).catchError((error) {
        LoggerService.error('Failed to remove item from server', error);
        // Could add retry logic here
      });
      
    } catch (e) {
      LoggerService.error('Failed to remove item from cart', e);
      emit(CartError(message: 'Failed to remove item from cart'));
    }
  }

  Future<void> _onCartItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      if (event.quantity <= 0) {
        add(CartItemRemoved(itemId: event.itemId));
        return;
      }
      
      // Optimistic update
      final items = List<Map<String, dynamic>>.from(StorageService.getCartData());
      final itemIndex = items.indexWhere(
        (item) => item['id'].toString() == event.itemId,
      );
      
      if (itemIndex != -1) {
        items[itemIndex]['quantity'] = event.quantity;
        
        await StorageService.setCartData(items);
        final totals = _calculateTotals(items);
        emit(CartLoaded(items: items, totals: totals));
        
        // Sync with server in background
        _apiService.updateCartItem(
          cartItemId: event.itemId,
          quantity: event.quantity,
        ).catchError((error) {
          LoggerService.error('Failed to update item quantity on server', error);
        });
      }
    } catch (e) {
      LoggerService.error('Failed to update item quantity', e);
      emit(CartError(message: 'Failed to update item quantity'));
    }
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    try {
      // Clear local storage immediately
      await StorageService.clearCartData();
      
      emit(const CartLoaded(
        items: [],
        totals: CartTotals(
          subtotal: 0.0,
          deliveryFee: 0.0,
          tax: 0.0,
          total: 0.0,
          itemCount: 0,
        ),
      ));
      
      // Clear server cart in background
      _apiService.clearCart().catchError((error) {
        LoggerService.error('Failed to clear cart on server', error);
      });
      
    } catch (e) {
      LoggerService.error('Failed to clear cart', e);
      emit(CartError(message: 'Failed to clear cart'));
    }
  }

  // Optimized calculation with caching
  CartTotals _calculateTotals(List<Map<String, dynamic>> items) {
    // Create cache key based on items
    final cacheKey = items.map((item) => 
      '${item['id']}_${item['quantity']}_${item['price']}'
    ).join('|');
    
    // Return cached result if available
    if (_calculationCache.containsKey(cacheKey)) {
      return _calculationCache[cacheKey]!;
    }
    
    double subtotal = 0.0;
    int itemCount = 0;
    
    for (final item in items) {
      final price = _parseDouble(item['price']);
      final quantity = _parseInt(item['quantity']);
      
      subtotal += price * quantity;
      itemCount += quantity;
    }
    
    final deliveryFee = subtotal > 0 ? 2.99 : 0.0;
    final tax = subtotal * 0.08;
    final total = subtotal + deliveryFee + tax;
    
    final totals = CartTotals(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: tax,
      total: total,
      itemCount: itemCount,
    );
    
    // Cache with size limit
    if (_calculationCache.length > 50) {
      _calculationCache.clear();
    }
    _calculationCache[cacheKey] = totals;
    
    return totals;
  }

  // Optimized parsing methods
  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _calculationCache.clear();
    return super.close();
  }
}

// Extension for debouncing (if not available in your current bloc version)
extension StreamExtensions<T> on Stream<T> {
  Stream<T> debounceTime(Duration duration) {
    Timer? timer;
    T? lastData;
    
    return transform(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        lastData = data;
        timer?.cancel();
        timer = Timer(duration, () {
          sink.add(lastData!);
        });
      },
      handleDone: (sink) {
        timer?.cancel();
        sink.close();
      },
    ));
  }
  
  Stream<S> switchMap<S>(Stream<S> Function(T) mapper) {
    return asyncExpand(mapper);
  }
}