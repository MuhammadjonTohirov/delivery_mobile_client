import 'package:flutter/material.dart';
import 'dart:async';

class OrderTrackingPage extends StatefulWidget {
  final int orderId;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late Timer _timer;
  String _currentStatus = 'preparing';
  int _estimatedMinutes = 25;
  late Map<String, dynamic> orderData;

  @override
  void initState() {
    super.initState();
    orderData = _getMockOrderData(widget.orderId);
    _currentStatus = orderData['status'] ?? 'preparing';
    
    // Simulate real-time updates
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateOrderStatus();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateOrderStatus() {
    if (!mounted) return;
    
    setState(() {
      if (_estimatedMinutes > 0) {
        _estimatedMinutes--;
      }
      
      // Simulate status progression
      if (_currentStatus == 'preparing' && _estimatedMinutes < 20) {
        _currentStatus = 'out_for_delivery';
      } else if (_currentStatus == 'out_for_delivery' && _estimatedMinutes < 5) {
        _currentStatus = 'delivered';
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order status updated')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildMapPlaceholder(),
            const SizedBox(height: 16),
            _buildDeliveryPersonCard(),
            const SizedBox(height: 16),
            _buildOrderSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusIcon(),
            const SizedBox(height: 16),
            Text(
              _getStatusTitle(_currentStatus),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(_currentStatus),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_currentStatus != 'delivered') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Estimated: $_estimatedMinutes min',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Order Delivered!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (_currentStatus) {
      case 'preparing':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'out_for_delivery':
        icon = Icons.delivery_dining;
        color = Colors.blue;
        break;
      case 'delivered':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.hourglass_empty;
        color = Colors.grey;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40,
        color: color,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final statuses = ['confirmed', 'preparing', 'out_for_delivery', 'delivered'];
    final currentIndex = statuses.indexOf(_currentStatus);

    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < statuses.length - 1)
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).dividerColor,
                    shape: BoxShape.circle,
                    border: isCurrent 
                        ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                        : null,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMapPlaceholder() {
    return Card(
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Live Tracking Map',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time delivery tracking coming soon',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryPersonCard() {
    if (_currentStatus != 'out_for_delivery') {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Delivery Person',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Text(
                    'JD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
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
                            '4.8',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• 2.5 km away',
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
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _showContactOptions();
                  },
                  icon: const Icon(Icons.message),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
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
    final restaurant = orderData['restaurant'] ?? {};
    final items = orderData['items'] ?? [];

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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant,
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
                        restaurant['name'] ?? 'Restaurant ${widget.orderId}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${items.length} items • \$${orderData['total'] ?? 31.26}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showSupportDialog();
                    },
                    child: const Text('Get Help'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'confirmed':
        return 'Order Confirmed';
      case 'preparing':
        return 'Preparing Your Order';
      case 'out_for_delivery':
        return 'On the Way';
      case 'delivered':
        return 'Order Delivered';
      default:
        return 'Processing Order';
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'confirmed':
        return 'Your order has been confirmed and will be prepared soon.';
      case 'preparing':
        return 'The restaurant is preparing your delicious meal.';
      case 'out_for_delivery':
        return 'Your order is on its way to your location.';
      case 'delivered':
        return 'Your order has been successfully delivered. Enjoy!';
      default:
        return 'We are processing your order.';
    }
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact Delivery Person',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call'),
              subtitle: const Text('+1 (555) 123-4567'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Message'),
              subtitle: const Text('Send a text message'),
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

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: const Text('Our support team is here to help with any issues regarding your order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support chat coming soon!')),
              );
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getMockOrderData(int orderId) {
    return {
      'id': orderId,
      'status': _currentStatus,
      'restaurant': {
        'name': 'Pizza Palace',
        'rating': 4.5,
      },
      'items': [
        {'name': 'Margherita Pizza', 'price': 12.99, 'quantity': 1},
        {'name': 'Caesar Salad', 'price': 8.99, 'quantity': 1},
        {'name': 'Garlic Bread', 'price': 4.99, 'quantity': 2},
      ],
      'total': 31.96,
    };
  }
}