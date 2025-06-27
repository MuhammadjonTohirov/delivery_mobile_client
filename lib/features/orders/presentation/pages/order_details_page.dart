import 'package:delivery_customer/shared/extensions/widget_extensions.dart';
import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/chips/status_chip.dart';
import '../../../../shared/utils/formatters/currency_formatter.dart';
import '../../../../shared/utils/formatters/date_formatter.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.getOrderDetails(widget.orderId);
      
      if (response.success && response.data != null) {
        setState(() {
          _orderData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorAlert(response.error ?? 'Failed to load order details');
      }
    } catch (e) {
      final errorMessage = 'Failed to load order details: ${e.toString()}';
      setState(() {
        _isLoading = false;
      });
      _showErrorAlert(errorMessage);
    }
  }

  void _showErrorAlert(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadOrderDetails();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderIdStr = _orderData?['id']?.toString() ?? widget.orderId.toString();
    final shortOrderId = orderIdStr.length > 9 ? orderIdStr.substring(0, 9) : orderIdStr;

    return Scaffold(
      appBar: AppBar(
        title: Text(_orderData != null ? 'Order #$shortOrderId' : 'Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrderDetails,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content - always visible
          RefreshIndicator(
            onRefresh: _loadOrderDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: _orderData != null 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderStatusCard(),
                        const SizedBox(height: 16),
                        _buildRestaurantInfoCard(),
                        const SizedBox(height: 16),
                        _buildOrderItemsCard(),
                        const SizedBox(height: 16),
                        _buildDeliveryInfoCard(),
                        const SizedBox(height: 16),
                        _buildPaymentInfoCard(),
                        const SizedBox(height: 16),
                        _buildOrderSummaryCard(),
                      ],
                    )
                  : _buildPlaceholderContent(),
            ),
          ),
          
          // Loading overlay - appears on top when loading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading order details...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _orderData != null ? _buildActionButtons() : null,
    );
  }

  Widget _buildOrderStatusCard() {
    final statusData = _orderData!['status'];
    final status = statusData is Map ? statusData['current'] ?? 'pending' : statusData ?? 'pending';
    final createdAt = _orderData!['created_at'] ?? _orderData!['timestamps']?['ordered'] ?? DateTime.now().toIso8601String();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StatusChip(
                  label: _getStatusDisplayText(status),
                  type: getOrderStatusType(status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusTimeline(status),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ordered ${DateFormatter.formatOrderDate(DateTime.parse(createdAt))}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final statuses = [
      {'key': 'placed', 'label': 'Order Placed', 'icon': Icons.receipt},
      {'key': 'confirmed', 'label': 'Confirmed', 'icon': Icons.check_circle},
      {'key': 'preparing', 'label': 'Preparing', 'icon': Icons.restaurant},
      {'key': 'ready', 'label': 'Ready for Pickup', 'icon': Icons.restaurant_menu},
      {'key': 'delivering', 'label': 'Out for Delivery', 'icon': Icons.delivery_dining},
      {'key': 'delivered', 'label': 'Delivered', 'icon': Icons.home},
    ];

    final currentIndex = statuses.indexWhere((s) => s['key'] == currentStatus.toLowerCase());

    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isUpcoming = index > currentIndex;

        return Padding(
          padding: EdgeInsets.only(bottom: index == statuses.length - 1 ? 0 : 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green 
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompleted || isUpcoming 
                        ? Colors.green 
                        : Colors.grey,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status['icon'] as IconData,
                  size: 16,
                  color: isCompleted 
                      ? Colors.white 
                      : (isUpcoming ? Colors.green : Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status['label'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted 
                        ? Colors.green
                        : (isUpcoming ? Colors.green : Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRestaurantInfoCard() {
    final restaurant = _orderData!['restaurant'] ?? {};
    final restaurantName = restaurant['name'] ?? _orderData!['restaurant_name'] ?? 'Restaurant';
    final cuisineType = restaurant['cuisine'] ?? 'Restaurant';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restaurant',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.store,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurantName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant['rating'] ?? 4.5}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cuisineType,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showContactOptions();
                  },
                  icon: const Icon(Icons.phone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    final items = _orderData!['items'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items (${items.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map<Widget>((item) => _buildOrderItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.network(
              item['imageUrl'] ?? item['menu_item_image'] ?? '',
              fit: BoxFit.cover,
            )
            .withContainer(clip: Clip.hardEdge, borderRadius: 6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? item['menu_item_name'] ?? 'Unknown Item',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item['description'] != null && item['description'].toString().isNotEmpty)
                  Text(
                    item['description'],
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
                  
          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'x${item['quantity'] ?? 1}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatCurrency(
                  (item['totalPrice'] ?? item['subtotal'] ?? item['unit_price'] ?? double.tryParse(item['price'] ?? '0.0')?? 0.0),
                  item['currency'] ?? _orderData!['pricing']?['currency'] ?? 'USD'
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    final deliveryData = _orderData!['deliveryAddress'] ?? _orderData!['delivery'] ?? {};
    final addressText = deliveryData['fullAddress'] ?? _orderData!['delivery_address'] ?? 'No address provided';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    addressText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estimated: ${deliveryData['estimatedTime'] ?? _orderData!['delivery']?['estimatedTime'] ?? '25-35 min'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (deliveryData['notes'] != null || _orderData!['notes'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.note,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      deliveryData['notes'] ?? _orderData!['notes'] ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    final payment = _orderData!['payment'] ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getPaymentIcon(payment['method'] ?? 'card'),
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getPaymentMethodName(payment['method'] ?? 'card'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payment['status'] ?? 'Paid',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final pricing = _orderData!['pricing'] ?? {};
    final totalPrice = pricing['total'] ?? _orderData!['total_price'] ?? _orderData!['total'] ?? 0.0;
    final currency = pricing['currency'] ?? _orderData!['primary_currency'] ?? 'USD';
    final actualTotal = _parseAmount(totalPrice);
    
    // Convert all values to double for comparison
    final subtotal = _parseAmount(pricing['subtotal']);
    final deliveryFee = _parseAmount(pricing['deliveryFee'] ?? _orderData!['delivery_fee']);
    final discount = _parseAmount(pricing['discount'] ?? _orderData!['discount']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (subtotal > 0) _buildSummaryRow('Subtotal', subtotal, currency),
            if (deliveryFee > 0) _buildSummaryRow('Delivery Fee', deliveryFee, currency),
            if (discount > 0) _buildSummaryRow('Discount', discount, currency, isDiscount: true),
            if (subtotal > 0 || deliveryFee > 0 || discount > 0) const Divider(),
            _buildSummaryRow('Total', actualTotal, currency, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, String currency, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${isDiscount ? '-' : ''}${_formatCurrency(amount.abs(), currency)}',
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  )
                : isDiscount
                    ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                      )
                    : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }


  Widget _buildPlaceholderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Status Card Placeholder
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Loading order information...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Restaurant Info Placeholder
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restaurant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.store, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 14,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Order Items Placeholder
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading order items...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final statusData = _orderData!['status'];
    final status = statusData is Map ? statusData['current'] ?? 'pending' : statusData ?? 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_canTrackOrder(status))
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  AppRouter.push(
                    context,
                    AppRouter.orderTracking,
                    arguments: {'orderId': widget.orderId},
                  );
                },
                child: const Text('Track Order'),
              ),
            ),
          if (_canReorder(status)) ...[
            if (_canTrackOrder(status)) const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _showReorderDialog();
                },
                child: const Text('Reorder'),
              ),
            ),
          ],
          if (_canCancelOrder(status)) ...[
            if (_canTrackOrder(status) || _canReorder(status)) const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _showCancelDialog();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancel Order'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canTrackOrder(String status) {
    return ['confirmed', 'preparing', 'out_for_delivery'].contains(status.toLowerCase());
  }

  bool _canReorder(String status) {
    return ['delivered'].contains(status.toLowerCase());
  }

  bool _canCancelOrder(String status) {
    return ['pending', 'confirmed'].contains(status.toLowerCase());
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      case 'digital':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return 'Credit/Debit Card';
      case 'cash':
        return 'Cash on Delivery';
      case 'digital':
        return 'Digital Wallet';
      default:
        return 'Unknown';
    }
  }

  double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) return double.tryParse(amount) ?? 0.0;
    return 0.0;
  }

  String _formatCurrency(dynamic amount, String currency) {
    final value = _parseAmount(amount);
    
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: const Text('Contact our support team for assistance with your order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support chat coming soon!'),
                ),
              );
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Restaurant'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Message Restaurant'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Messaging feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReorderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder'),
        content: const Text('Would you like to add the same items to your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reorder functionality coming soon!')),
              );
            },
            child: const Text('Reorder'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order cancellation coming soon!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

}