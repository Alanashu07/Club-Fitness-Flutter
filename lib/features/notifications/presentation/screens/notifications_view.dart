import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

enum NotificationType { offer, announcement, order, membership }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  String _filter = 'All';

  final List<AppNotification> _notifications = [
    const AppNotification(
      id: 'n1',
      type: NotificationType.offer,
      title: '20% off Whey Protein',
      message:
          'This weekend only — get 20% off all supplements at the gym store.',
      time: '10m ago',
      isRead: false,
    ),
    const AppNotification(
      id: 'n2',
      type: NotificationType.announcement,
      title: 'Gym closed on Jun 24',
      message:
          'We will be closed for maintenance on Jun 24. Regular hours resume Jun 25.',
      time: '1h ago',
      isRead: false,
    ),
    const AppNotification(
      id: 'n3',
      type: NotificationType.order,
      title: 'Order ready for pickup',
      message: 'Your order ORD-1042 is ready to collect at the front desk.',
      time: '3h ago',
      isRead: true,
    ),
    const AppNotification(
      id: 'n4',
      type: NotificationType.membership,
      title: 'Membership renewal reminder',
      message: 'Your Gold membership expires in 7 days. Renew to avoid a gap.',
      time: 'Yesterday',
      isRead: true,
    ),
    const AppNotification(
      id: 'n5',
      type: NotificationType.offer,
      title: 'New shaker bottles in stock',
      message: 'Fresh stock of Club Fitness shaker bottles just arrived.',
      time: '2 days ago',
      isRead: true,
    ),
  ];

  List<AppNotification> get _filtered {
    if (_filter == 'All') return _notifications;
    final type = {
      'Offers': NotificationType.offer,
      'Announcements': NotificationType.announcement,
      'Orders': NotificationType.order,
      'Membership': NotificationType.membership,
    }[_filter];
    return _notifications.where((n) => n.type == type).toList();
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.offer:
        return Icons.local_offer_outlined;
      case NotificationType.announcement:
        return Icons.campaign_outlined;
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.membership:
        return Icons.card_membership_outlined;
    }
  }

  Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.offer:
        return AppTheme.primary;
      case NotificationType.announcement:
        return AppTheme.warning;
      case NotificationType.order:
        return AppTheme.success;
      case NotificationType.membership:
        return const Color(0xFF7C3AED);
    }
  }

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = AppNotification(
            id: _notifications[i].id,
            type: _notifications[i].type,
            title: _notifications[i].title,
            message: _notifications[i].message,
            time: _notifications[i].time,
            isRead: true,
          );
        }
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      final i = _notifications.indexWhere((n) => n.id == id);
      if (i != -1 && !_notifications[i].isRead) {
        _notifications[i] = AppNotification(
          id: _notifications[i].id,
          type: _notifications[i].type,
          title: _notifications[i].title,
          message: _notifications[i].message,
          time: _notifications[i].time,
          isRead: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Offers', 'Announcements', 'Orders', 'Membership'];
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICATIONS'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final f = filters[index];
                  final selected = f == _filter;
                  return ChoiceChip(
                    label: Text(f),
                    selected: selected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppTheme.textSecondary,
                    ),
                    onSelected: (_) => setState(() => _filter = f),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filtered.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = _filtered[index];
                        return _NotificationCard(
                          notification: n,
                          icon: _iconFor(n.type),
                          color: _colorFor(n.type),
                          onTap: () => _markRead(n.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? AppTheme.cardBorder : color.withAOpacity(0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight:
                                notification.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.time,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 56, color: AppTheme.textSecondary),
          SizedBox(height: 12),
          Text(
            'Nothing here yet',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'New offers and announcements will show up here.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}