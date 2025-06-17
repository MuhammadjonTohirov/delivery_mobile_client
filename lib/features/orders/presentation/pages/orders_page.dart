import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/orders_bloc.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<OrdersBloc>().add(OrdersLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersError) {
            return _buildErrorState(state.message);
          } else if (state is OrdersLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_getActiveOrders(state.orders)),
                _buildOrdersList(_getPastOrders(state.orders)),
                _buildOrdersList(state.orders),
              ],
            );
          }
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<OrdersBloc>().add(OrdersLoadRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 120,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 24),
          Text(
            'No orders yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start ordering to see your order history',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to home tab
              Navigator.of(context).pop();
            },
            child: const Text('Browse Restaurants'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<dynamic> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersBloc>().add(OrdersRefreshRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final orderId = order['id'] ?? 0;
    final restaurantName = order['restaurant_name'] ?? 'Restaurant ${orderId}';
    final total = (order['total'] ?? 25.99).toDouble();
    final itemCount = order['item_count'] ?? 3;
    final createdAt = order['created_at'] ?? '2024-01-15T10:30:00Z';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          AppRouter.push(
            context,
            AppRouter.orderDetails,
            arguments: {'orderId': orderId},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$orderId',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      restaurantName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$itemCount items',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (_canTrackOrder(status))
                        TextButton(
                          onPressed: () {
                            AppRouter.push(
                              context,
                              AppRouter.orderTracking,
                              arguments: {'orderId': orderId},
                            );
                          },
                          child: const Text('Track Order'),
                        ),
                      if (_canReorder(status))
                        TextButton(
                          onPressed: () {
                            _showReorderDialog(order);
                          },
                          child: const Text('Reorder'),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'confirmed':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        displayText = 'Confirmed';
        break;
      case 'preparing':
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        displayText = 'Preparing';
        break;
      case 'out_for_delivery':
        backgroundColor = Colors.amber.withOpacity(0.1);
        textColor = Colors.amber.shade700;
        displayText = 'Out for Delivery';
        break;
      case 'delivered':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        displayText = 'Delivered';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<dynamic> _getActiveOrders(List<dynamic> orders) {
    return orders.where((order) {
      final status = order['status']?.toString().toLowerCase() ?? '';
      return ['pending', 'confirmed', 'preparing', 'out_for_delivery'].contains(status);
    }).toList();
  }

  List<dynamic> _getPastOrders(List<dynamic> orders) {
    return orders.where((order) {
      final status = order['status']?.toString().toLowerCase() ?? '';
      return ['delivered', 'cancelled'].contains(status);
    }).toList();
  }

  bool _canTrackOrder(String status) {
    return ['confirmed', 'preparing', 'out_for_delivery'].contains(status.toLowerCase());
  }

  bool _canReorder(String status) {
    return ['delivered'].contains(status.toLowerCase());
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  void _showReorderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder'),
        content: Text('Would you like to reorder from ${order['restaurant_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reorder functionality coming soon!'),
                ),
              );
            },
            child: const Text('Reorder'),
          ),
        ],
      ),
    );
  }
}

// Mock data for demonstration
final List<Map<String, dynamic>> _mockOrders = [
  {
    'id': 1001,
    'restaurant_name': 'Pizza Palace',
    'status': 'delivered',
    'total': 28.99,
    'item_count': 2,
    'created_at': '2024-01-15T10:30:00Z',
  },
  {
    'id': 1002,
    'restaurant_name': 'Burger House',
    'status': 'out_for_delivery',
    'total': 15.50,
    'item_count': 1,
    'created_at': '2024-01-15T12:15:00Z',
  },
  {
    'id': 1003,
    'restaurant_name': 'Sushi Express',
    'status': 'preparing',
    'total': 42.75,
    'item_count': 4,
    'created_at': '2024-01-15T13:45:00Z',
  },
];