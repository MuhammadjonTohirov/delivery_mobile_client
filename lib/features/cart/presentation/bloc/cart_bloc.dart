import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/storage_service.dart';

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
  CartBloc() : super(CartInitial()) {
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartItemAdded>(_onCartItemAdded);
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
    } catch (e) {
      emit(CartError(message: 'Failed to load cart: ${e.toString()}'));
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = StorageService.getCartData();
      
      // Check if item already exists
      final existingItemIndex = items.indexWhere(
        (item) => item['id'] == event.item['id'],
      );
      
      if (existingItemIndex != -1) {
        // Update quantity if item exists
        items[existingItemIndex]['quantity'] = 
            (items[existingItemIndex]['quantity'] ?? 1) + 1;
      } else {
        // Add new item
        final newItem = Map<String, dynamic>.from(event.item);
        newItem['quantity'] = newItem['quantity'] ?? 1;
        items.add(newItem);
      }
      
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
    } catch (e) {
      emit(CartError(message: 'Failed to add item to cart: ${e.toString()}'));
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
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
    } catch (e) {
      emit(CartError(message: 'Failed to remove item from cart: ${e.toString()}'));
    }
  }

  Future<void> _onCartItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = StorageService.getCartData();
      final itemIndex = items.indexWhere(
        (item) => item['id'].toString() == event.itemId,
      );
      
      if (itemIndex != -1) {
        if (event.quantity <= 0) {
          items.removeAt(itemIndex);
        } else {
          items[itemIndex]['quantity'] = event.quantity;
        }
        
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
      emit(CartError(message: 'Failed to update item quantity: ${e.toString()}'));
    }
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    try {
      await StorageService.clearCartData();
      emit(const CartLoaded(
        items: [],
        subtotal: 0.0,
        deliveryFee: 0.0,
        tax: 0.0,
        total: 0.0,
        itemCount: 0,
      ));
    } catch (e) {
      emit(CartError(message: 'Failed to clear cart: ${e.toString()}'));
    }
  }

  Map<String, double> _calculateTotals(List<Map<String, dynamic>> items) {
    double subtotal = 0.0;
    int itemCount = 0;
    
    for (final item in items) {
      final price = (item['price'] ?? 0.0).toDouble();
      final quantity = (item['quantity'] ?? 1) as int;
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