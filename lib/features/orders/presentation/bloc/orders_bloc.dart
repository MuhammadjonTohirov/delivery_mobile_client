import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

// Events
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object> get props => [];
}

class OrdersLoadRequested extends OrdersEvent {}

class OrdersRefreshRequested extends OrdersEvent {}

class OrderCreateRequested extends OrdersEvent {
  final int restaurantId;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic> deliveryAddress;
  final String? notes;
  final String? promoCode;

  const OrderCreateRequested({
    required this.restaurantId,
    required this.items,
    required this.deliveryAddress,
    this.notes,
    this.promoCode,
  });

  @override
  List<Object> get props => [restaurantId, items, deliveryAddress];
}

// States
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<dynamic> orders;

  const OrdersLoaded({required this.orders});

  @override
  List<Object> get props => [orders];
}

class OrderCreating extends OrdersState {}

class OrderCreated extends OrdersState {
  final Map<String, dynamic> order;

  const OrderCreated({required this.order});

  @override
  List<Object> get props => [order];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final ApiService apiService;

  OrdersBloc({required this.apiService}) : super(OrdersInitial()) {
    on<OrdersLoadRequested>(_onOrdersLoadRequested);
    on<OrdersRefreshRequested>(_onOrdersRefreshRequested);
    on<OrderCreateRequested>(_onOrderCreateRequested);
  }

  Future<void> _onOrdersLoadRequested(
    OrdersLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    await _loadOrders(emit);
  }

  Future<void> _onOrdersRefreshRequested(
    OrdersRefreshRequested event,
    Emitter<OrdersState> emit,
  ) async {
    await _loadOrders(emit);
  }

  Future<void> _onOrderCreateRequested(
    OrderCreateRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrderCreating());

    try {
      final response = await apiService.createOrder(
        restaurantId: event.restaurantId,
        items: event.items,
        deliveryAddress: event.deliveryAddress,
        notes: event.notes,
        promoCode: event.promoCode,
      );

      if (response.success && response.data != null) {
        emit(OrderCreated(order: response.data!));
      } else {
        emit(OrdersError(message: response.error ?? 'Failed to create order'));
      }
    } catch (e) {
      emit(OrdersError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _loadOrders(Emitter<OrdersState> emit) async {
    try {
      final response = await apiService.getOrders();

      if (response.success && response.data != null) {
        emit(OrdersLoaded(orders: response.data!));
      } else {
        emit(OrdersError(message: response.error ?? 'Failed to load orders'));
      }
    } catch (e) {
      emit(OrdersError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }
}