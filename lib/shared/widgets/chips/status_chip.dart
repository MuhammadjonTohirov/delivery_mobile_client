import 'package:flutter/material.dart';

enum StatusType {
  pending,
  confirmed,
  preparing,
  ready,
  delivering,
  delivered,
  cancelled,
  success,
  warning,
  error,
  info,
}

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool showIcon;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusChip({
    super.key,
    required this.label,
    required this.type,
    this.showIcon = true,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getStatusConfig(type, theme);
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: (fontSize ?? 12) + 2,
              color: config.textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: config.textColor,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(StatusType type, ThemeData theme) {
    switch (type) {
      case StatusType.pending:
        return _StatusConfig(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          textColor: Colors.orange.shade700,
          icon: Icons.schedule,
        );
      case StatusType.confirmed:
        return _StatusConfig(
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          textColor: Colors.blue.shade700,
          icon: Icons.check_circle_outline,
        );
      case StatusType.preparing:
        return _StatusConfig(
          backgroundColor: Colors.purple.shade50,
          borderColor: Colors.purple.shade200,
          textColor: Colors.purple.shade700,
          icon: Icons.restaurant,
        );
      case StatusType.ready:
        return _StatusConfig(
          backgroundColor: Colors.teal.shade50,
          borderColor: Colors.teal.shade200,
          textColor: Colors.teal.shade700,
          icon: Icons.done_all,
        );
      case StatusType.delivering:
        return _StatusConfig(
          backgroundColor: Colors.indigo.shade50,
          borderColor: Colors.indigo.shade200,
          textColor: Colors.indigo.shade700,
          icon: Icons.local_shipping,
        );
      case StatusType.delivered:
        return _StatusConfig(
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          textColor: Colors.green.shade700,
          icon: Icons.check_circle,
        );
      case StatusType.cancelled:
        return _StatusConfig(
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          textColor: Colors.red.shade700,
          icon: Icons.cancel,
        );
      case StatusType.success:
        return _StatusConfig(
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          textColor: Colors.green.shade700,
          icon: Icons.check_circle,
        );
      case StatusType.warning:
        return _StatusConfig(
          backgroundColor: Colors.amber.shade50,
          borderColor: Colors.amber.shade200,
          textColor: Colors.amber.shade700,
          icon: Icons.warning,
        );
      case StatusType.error:
        return _StatusConfig(
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          textColor: Colors.red.shade700,
          icon: Icons.error,
        );
      case StatusType.info:
        return _StatusConfig(
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          textColor: Colors.blue.shade700,
          icon: Icons.info,
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
  });
}

// Helper function to convert order status string to StatusType
StatusType getOrderStatusType(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return StatusType.pending;
    case 'confirmed':
      return StatusType.confirmed;
    case 'preparing':
      return StatusType.preparing;
    case 'ready':
      return StatusType.ready;
    case 'delivering':
      return StatusType.delivering;
    case 'delivered':
      return StatusType.delivered;
    case 'cancelled':
      return StatusType.cancelled;
    default:
      return StatusType.pending;
  }
}