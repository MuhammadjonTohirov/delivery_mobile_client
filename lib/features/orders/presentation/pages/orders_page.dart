import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/states/empty_state_widget.dart';
import '../../../../shared/widgets/states/error_state_widget.dart';
import '../../../../shared/widgets/chips/status_chip.dart';
import '../../../../shared/utils/formatters/currency_formatter.dart';
import '../../../../shared/utils/formatters/date_formatter.dart';
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

  // Sort orders by status priority (new to completed)
  List<dynamic> _sortOrdersByStatus(List<dynamic> orders) {
    const statusPriority = {
      'PLACED': 1,
      'CONFIRMED': 2,
      'PREPARING': 3,
      'READY_FOR_PICKUP': 4,
      'PICKED_UP': 5,
      'ON_THE_WAY': 6,
      'DELIVERED': 7,
      'CANCELLED': 8,
    };

    final sortedOrders = List<dynamic>.from(orders);
    sortedOrders.sort((a, b) {
      final statusDataA = a['status'];
      final statusDataB = b['status'];
      final statusA = statusDataA is Map ? statusDataA['current']?.toString().toUpperCase() ?? 'PLACED' : statusDataA?.toString().toUpperCase() ?? 'PLACED';
      final statusB = statusDataB is Map ? statusDataB['current']?.toString().toUpperCase() ?? 'PLACED' : statusDataB?.toString().toUpperCase() ?? 'PLACED';
      
      final priorityA = statusPriority[statusA] ?? 999;
      final priorityB = statusPriority[statusB] ?? 999;
      
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      
      // If same status, sort by creation date (newest first)
      try {
        final dateA = DateTime.parse(a['created_at'] ?? '');
        final dateB = DateTime.parse(b['created_at'] ?? '');
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
    
    return sortedOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrdersBloc>().add(OrdersRefreshRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersError) {
            return _buildErrorState(state.message);
          } else if (state is OrdersLoaded) {
            final sortedOrders = _sortOrdersByStatus(state.orders);
            return Column(
              children: [
                Container(
                  color: Theme.of(context).primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'All (${sortedOrders.length})'),
                      Tab(text: 'Active (${_getActiveOrders(sortedOrders).length})'),
                      Tab(text: 'Past (${_getPastOrders(sortedOrders).length})'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(sortedOrders),
                      _buildOrdersList(_getActiveOrders(sortedOrders)),
                      _buildOrdersList(_getPastOrders(sortedOrders)),
                    ],
                  ),
                ),
              ],
            );
          }
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return ErrorStateWidget(
      message: message,
      onRetry: () {
        context.read<OrdersBloc>().add(OrdersLoadRequested());
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'No orders yet',
      subtitle: 'Start ordering to see your order history',
      actionText: 'Browse Restaurants',
      onActionPressed: () {
        Navigator.of(context).pop();
      },
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
    final statusData = order['status'];
    final status = statusData is Map ? statusData['current'] ?? 'PLACED' : statusData ?? 'PLACED';
    final orderId = order['id']?.toString() ?? 'ORD123456';
    final shortOrderId = orderId.length > 9 ? orderId.substring(0, 9) : orderId;
    final restaurantName = order['restaurant_name'] ?? 'Restaurant';
    final rawTotalPrice = order['total_price'] ?? order['pricing']?['total'] ?? order['total'] ?? 0.0;
    final totalPrice = rawTotalPrice is String ? double.tryParse(rawTotalPrice) ?? 0.0 : rawTotalPrice.toDouble();
    final itemCount = order['item_count'] ?? 0;
    final createdAt = order['created_at'] ?? DateTime.now().toIso8601String();
    final currency = order['primary_currency'] ?? 'UZS';
    
    // Get actual items from server response
    final items = order['items'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _navigateToOrderDetails(order);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #$shortOrderId',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  StatusChip(
                    label: _getStatusDisplayText(status),
                    type: getOrderStatusType(status),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Restaurant Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$itemCount items',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Order Items Preview
              if (items.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Items:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('${item['quantity']}x ', 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item['menu_item_name'] ?? 'Menu Item',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        _formatCurrency(item['unit_price'] ?? 0, item['currency'] ?? currency),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
                if (items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+ ${items.length - 3} more items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              // Total and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatCurrency(totalPrice, currency),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_canTrackOrder(status))
                        ElevatedButton.icon(
                          onPressed: () {
                            _showOrderTracking(order);
                          },
                          icon: const Icon(Icons.location_on, size: 16),
                          label: const Text('Track'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      if (_canReorder(status)) ...[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            _showReorderDialog(order);
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reorder'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
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

  String _getStatusDisplayText(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
        return 'Order Placed';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PREPARING':
        return 'Preparing';
      case 'READY_FOR_PICKUP':
        return 'Ready for Pickup';
      case 'PICKED_UP':
        return 'Picked Up';
      case 'ON_THE_WAY':
        return 'On the Way';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }


  List<dynamic> _getActiveOrders(List<dynamic> orders) {
    return orders.where((order) {
      final statusData = order['status'];
      final status = statusData is Map ? statusData['current']?.toString().toUpperCase() ?? '' : statusData?.toString().toUpperCase() ?? '';
      return ['PLACED', 'CONFIRMED', 'PREPARING', 'READY_FOR_PICKUP', 'PICKED_UP', 'ON_THE_WAY'].contains(status);
    }).toList();
  }

  List<dynamic> _getPastOrders(List<dynamic> orders) {
    return orders.where((order) {
      final statusData = order['status'];
      final status = statusData is Map ? statusData['current']?.toString().toUpperCase() ?? '' : statusData?.toString().toUpperCase() ?? '';
      return ['DELIVERED', 'CANCELLED'].contains(status);
    }).toList();
  }

  String _formatCurrency(dynamic amount, String currency) {
    final value = (amount is String) ? double.tryParse(amount) ?? 0.0 : (amount ?? 0.0).toDouble();
    
    switch (currency.toUpperCase()) {
      case 'UZS':
        return CurrencyFormatter.formatUZB(value);
      case 'USD':
        return CurrencyFormatter.formatUSD(value);
      case 'RUB':
        return CurrencyFormatter.formatRUB(value);
      default:
        return CurrencyFormatter.formatUSD(value);
    }
  }

  bool _canTrackOrder(String status) {
    return ['CONFIRMED', 'PREPARING', 'READY_FOR_PICKUP', 'PICKED_UP', 'ON_THE_WAY', 'DELIVERING'].contains(status.toUpperCase());
  }

  bool _canReorder(String status) {
    return ['DELIVERED'].contains(status.toUpperCase());
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormatter.formatRelativeTime(date);
    } catch (e) {
      return 'Recently';
    }
  }

  void _navigateToOrderDetails(Map<String, dynamic> order) {
    final orderId = order['id'];
    if (orderId != null) {
      AppRouter.push(
        context,
        AppRouter.orderDetails,
        arguments: {'orderId': orderId.toString()},
      );
    }
  }

  void _showOrderTracking(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track Order #${order['id']}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'From ${order['restaurant_name'] ?? 'Restaurant'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Order Status Timeline
                      _buildOrderTimeline(order['status'] ?? 'pending'),
                      
                      const SizedBox(height: 24),
                      
                      // Estimated Delivery Time
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Delivery',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${order['estimated_delivery_time'] ?? 30} minutes',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Contact Support Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contact support feature coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.help_outline, size: 18),
                          label: const Text('Contact Support'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTimeline(String currentStatus) {
    final statuses = [
      {'status': 'PLACED', 'title': 'Order Placed', 'subtitle': 'We have received your order'},
      {'status': 'CONFIRMED', 'title': 'Order Confirmed', 'subtitle': 'Restaurant confirmed your order'},
      {'status': 'PREPARING', 'title': 'Preparing', 'subtitle': 'Your food is being prepared'},
      {'status': 'READY_FOR_PICKUP', 'title': 'Ready for Pickup', 'subtitle': 'Order is ready for pickup'},
      {'status': 'PICKED_UP', 'title': 'Picked Up', 'subtitle': 'Driver picked up your order'},
      {'status': 'ON_THE_WAY', 'title': 'On the Way', 'subtitle': 'Driver is on the way'},
      {'status': 'DELIVERED', 'title': 'Delivered', 'subtitle': 'Enjoy your meal!'},
    ];

    final currentIndex = statuses.indexWhere((s) => s['status'] == currentStatus.toUpperCase());
    
    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
                ),
                if (index < statuses.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status['title'] ?? '',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCompleted 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[600],
                      ),
                    ),
                    Text(
                      status['subtitle'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
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

