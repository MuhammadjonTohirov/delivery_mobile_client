import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/states/error_state_widget.dart';
import '../../../../shared/widgets/chips/status_chip.dart';
import '../../../../shared/utils/formatters/date_formatter.dart';
import '../../../../shared/utils/formatters/currency_formatter.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? initialOrder;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _orderData;
  Map<String, dynamic>? _trackingData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrder != null) {
      _orderData = widget.initialOrder;
    }
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load order details if not provided
      if (_orderData == null) {
        final orderResponse = await _apiService.getOrderDetails(widget.orderId);
        if (orderResponse.success && orderResponse.data != null) {
          _orderData = orderResponse.data;
        }
      }

      // Load tracking data
      final trackingResponse = await _apiService.trackOrder(widget.orderId);
      
      if (trackingResponse.success && trackingResponse.data != null) {
        setState(() {
          _trackingData = trackingResponse.data;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = trackingResponse.error ?? 'Failed to load tracking information';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load tracking information: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: ErrorStateWidget(
          message: _errorMessage!,
          onRetry: _loadTrackingData,
        ),
      );
    }

    if (_orderData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: const ErrorStateWidget(
          message: 'Order not found',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId.toString().padLeft(6, '0')}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadTrackingData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrackingData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(),
              const SizedBox(height: 24),
              _buildTrackingTimeline(),
              const SizedBox(height: 24),
              _buildDeliveryInfo(),
              const SizedBox(height: 24),
              _buildOrderItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    final status = _orderData!['status'] ?? 'pending';
    final createdAt = _orderData!['created_at'];
    final total = (_orderData!['total'] ?? 0.0).toDouble();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              StatusChip(
                label: _getStatusDisplayText(status),
                type: getOrderStatusType(status),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Total',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatUSD(total),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (createdAt != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Order Time',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatOrderDate(DateTime.parse(createdAt)),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    final status = _orderData!['status'] ?? 'pending';
    final trackingEvents = _trackingData?['events'] as List<dynamic>? ?? [];
    
    // Define the standard order flow
    final orderFlow = [
      {'key': 'placed', 'title': 'Order Placed', 'description': 'Your order has been received'},
      {'key': 'confirmed', 'title': 'Order Confirmed', 'description': 'Restaurant confirmed your order'},
      {'key': 'preparing', 'title': 'Preparing', 'description': 'Your food is being prepared'},
      {'key': 'ready', 'title': 'Ready for Pickup', 'description': 'Order is ready for delivery'},
      {'key': 'delivering', 'title': 'Out for Delivery', 'description': 'Driver is on the way'},
      {'key': 'delivered', 'title': 'Delivered', 'description': 'Order has been delivered'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...orderFlow.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == orderFlow.length - 1;
            final isCompleted = _isStepCompleted(step['key']!, status);
            final isCurrent = _isCurrentStep(step['key']!, status);
            
            return _buildTimelineStep(
              step['title']!,
              step['description']!,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
              timestamp: _getStepTimestamp(step['key']!, trackingEvents),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    String description, {
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    String? timestamp,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 16,
                color: isCompleted || isCurrent
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.surface,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCompleted || isCurrent
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (timestamp != null)
                      Text(
                        DateFormatter.formatRelativeTime(DateTime.parse(timestamp)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    final deliveryAddress = _orderData!['delivery_address'] as Map<String, dynamic>?;
    final driverInfo = _trackingData?['driver'] as Map<String, dynamic>?;
    final estimatedDelivery = _trackingData?['estimated_delivery_time'];
    
    if (deliveryAddress == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${deliveryAddress['street'] ?? ''}, ${deliveryAddress['city'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (estimatedDelivery != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estimated delivery: ${DateFormatter.formatTime(DateTime.parse(estimatedDelivery))}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          if (driverInfo != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver: ${driverInfo['name'] ?? 'Driver'}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (driverInfo['phone'] != null)
                        Text(
                          driverInfo['phone'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Call driver functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling driver...')),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    final items = _orderData!['items'] as List<dynamic>? ?? [];
    
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  '${item['quantity']}x',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['name'] ?? 'Item',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatUSD((double.tryParse(item['price'] ?? '0.0')?? 0.0).toDouble()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
        ],
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
      case 'READY':
        return 'Ready';
      case 'PICKED_UP':
      case 'DELIVERING':
        return 'Out for Delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  bool _isStepCompleted(String stepKey, String currentStatus) {
    final statusHierarchy = ['placed', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered'];
    final currentIndex = statusHierarchy.indexOf(currentStatus.toLowerCase());
    final stepIndex = statusHierarchy.indexOf(stepKey);
    
    return currentIndex >= stepIndex;
  }

  bool _isCurrentStep(String stepKey, String currentStatus) {
    return stepKey.toLowerCase() == currentStatus.toLowerCase();
  }

  String? _getStepTimestamp(String stepKey, List<dynamic> events) {
    for (final event in events) {
      if (event['type']?.toString().toLowerCase() == stepKey.toLowerCase()) {
        return event['timestamp'];
      }
    }
    return null;
  }
}