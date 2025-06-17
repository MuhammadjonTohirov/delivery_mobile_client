import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Map<String, dynamic> orderData;

  @override
  void initState() {
    super.initState();
    // Mock order data - in real app, fetch from API
    orderData = _getMockOrderData(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildOrderStatusCard() {
    final status = orderData['status'] ?? 'pending';
    final createdAt = orderData['created_at'] ?? DateTime.now().toIso8601String();

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
                _buildStatusChip(status),
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
                  'Ordered on ${_formatDateTime(createdAt)}',
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
      {'key': 'pending', 'label': 'Order Placed', 'icon': Icons.receipt},
      {'key': 'confirmed', 'label': 'Confirmed', 'icon': Icons.check_circle},
      {'key': 'preparing', 'label': 'Preparing', 'icon': Icons.restaurant},
      {'key': 'out_for_delivery', 'label': 'Out for Delivery', 'icon': Icons.delivery_dining},
      {'key': 'delivered', 'label': 'Delivered', 'icon': Icons.home},
    ];

    final currentIndex = statuses.indexWhere((s) => s['key'] == currentStatus);

    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).dividerColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                status['icon'] as IconData,
                size: 16,
                color: isCompleted ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status['label'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted 
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRestaurantInfoCard() {
    final restaurant = orderData['restaurant'] ?? {};

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
                    Icons.restaurant,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant['name'] ?? 'Restaurant ${widget.orderId}',
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
                            restaurant['cuisine'] ?? 'International',
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
    final items = orderData['items'] ?? [];

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
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fastfood,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Unknown Item',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item['customizations'] != null)
                  Text(
                    item['customizations'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'x${item['quantity'] ?? 1}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '\$${((item['price'] ?? 0.0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
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
    final delivery = orderData['delivery'] ?? {};

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
                    delivery['address'] ?? '123 Main St, City, State 12345',
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
                  'Estimated: ${delivery['estimated_time'] ?? '25-35 min'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (delivery['notes'] != null) ...[
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
                      delivery['notes'],
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
    final payment = orderData['payment'] ?? {};

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
                    color: Colors.green.withOpacity(0.1),
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
    final summary = orderData['summary'] ?? {};

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
            _buildSummaryRow('Subtotal', summary['subtotal'] ?? 25.99),
            _buildSummaryRow('Delivery Fee', summary['delivery_fee'] ?? 2.99),
            _buildSummaryRow('Tax', summary['tax'] ?? 2.28),
            if (summary['discount'] != null)
              _buildSummaryRow('Discount', summary['discount'], isDiscount: true),
            const Divider(),
            _buildSummaryRow(
              'Total',
              summary['total'] ?? 31.26,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
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
            '${isDiscount ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildActionButtons() {
    final status = orderData['status'] ?? 'pending';

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

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
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

  Map<String, dynamic> _getMockOrderData(int orderId) {
    return {
      'id': orderId,
      'status': 'preparing',
      'created_at': '2024-01-15T12:30:00Z',
      'restaurant': {
        'name': 'Pizza Palace',
        'rating': 4.5,
        'cuisine': 'Italian',
      },
      'items': [
        {
          'name': 'Margherita Pizza',
          'price': 12.99,
          'quantity': 1,
          'customizations': 'Extra cheese',
        },
        {
          'name': 'Caesar Salad',
          'price': 8.99,
          'quantity': 1,
        },
        {
          'name': 'Garlic Bread',
          'price': 4.99,
          'quantity': 2,
        },
      ],
      'delivery': {
        'address': '123 Main St, Apt 4B, City, State 12345',
        'estimated_time': '25-35 min',
        'notes': 'Please ring the doorbell',
      },
      'payment': {
        'method': 'card',
        'status': 'Paid',
      },
      'summary': {
        'subtotal': 31.96,
        'delivery_fee': 2.99,
        'tax': 2.79,
        'total': 37.74,
      },
    };
  }
}