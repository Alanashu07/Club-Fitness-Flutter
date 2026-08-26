import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

import '../../../data/data_source/shop_admin_mock_data_source.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AdminDataStore.instance;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SHOP ADMIN')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Overview', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                  label: 'Total Products',
                  value: '${store.totalProducts}',
                  icon: Icons.inventory_2_outlined,
                  color: AppTheme.primary,
                ),
                _StatCard(
                  label: 'Low Stock',
                  value: '${store.lowStockCount}',
                  icon: Icons.warning_amber_rounded,
                  color: AppTheme.warning,
                ),
                _StatCard(
                  label: 'Out of Stock',
                  value: '${store.outOfStockCount}',
                  icon: Icons.remove_shopping_cart_outlined,
                  color: AppTheme.error,
                ),
                _StatCard(
                  label: 'Restricted',
                  value: '${store.restrictedCount}',
                  icon: Icons.block,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Quick Actions', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _QuickActionTile(
              icon: Icons.add_box_outlined,
              title: 'Add new product',
              subtitle: 'Create a product and assign it to a category',
              onTap: () {},
            ),
            _QuickActionTile(
              icon: Icons.sync_alt,
              title: 'Restock items',
              subtitle: 'Update quantities for low / out of stock items',
              onTap: () {},
            ),
            _QuickActionTile(
              icon: Icons.lock_outline,
              title: 'Manage order restrictions',
              subtitle: 'Disable ordering for selected products',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Note: This app only handles ordering. Payment and '
                      'pickup happen in person at the gym.',
                      style: theme.textTheme.bodyMedium,
                    ),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 26),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withAOpacity(0.15),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }
}