import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

enum OrderStatus { pending, ready, collected, cancelled }

class AdminOrder {
  final String id;
  final String memberName;
  final String items;
  final double total;
  final OrderStatus status;

  const AdminOrder({
    required this.id,
    required this.memberName,
    required this.items,
    required this.total,
    required this.status,
  });
}

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final List<AdminOrder> _orders = const [
    AdminOrder(
      id: 'ORD-1042',
      memberName: 'Arjun Nair',
      items: 'Whey Protein 1kg x1',
      total: 2499,
      status: OrderStatus.pending,
    ),
    AdminOrder(
      id: 'ORD-1041',
      memberName: 'Sneha Pillai',
      items: 'Club Fitness Tee x2',
      total: 1398,
      status: OrderStatus.ready,
    ),
    AdminOrder(
      id: 'ORD-1040',
      memberName: 'Rahul Menon',
      items: 'Shaker Bottle x1',
      total: 299,
      status: OrderStatus.collected,
    ),
  ];

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppTheme.warning;
      case OrderStatus.ready:
        return AppTheme.primary;
      case OrderStatus.collected:
        return AppTheme.success;
      case OrderStatus.cancelled:
        return AppTheme.error;
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.ready:
        return 'Ready for pickup';
      case OrderStatus.collected:
        return 'Collected at gym';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ORDERS')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = _orders[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(order.id,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status).withAOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                              color: _statusColor(order.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(order.memberName,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 15)),
                  Text(order.items,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('₹${order.total.toStringAsFixed(0)} • Pay & collect at gym',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}