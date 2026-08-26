import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

import '../../../data/data_source/shop_admin_mock_data_source.dart';
import '../../../domain/entities/product.dart';

class StockTab extends StatefulWidget {
  const StockTab({super.key});

  @override
  State<StockTab> createState() => _StockTabState();
}

class _StockTabState extends State<StockTab> {
  final store = AdminDataStore.instance;
  String _filter = 'All';
  String _query = '';

  List<Product> get _filtered {
    return store.products.where((p) {
      final matchesCategory = _filter == 'All' || p.category == _filter;
      final matchesQuery =
          _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openRestockSheet(Product product) {
    final controller = TextEditingController(text: product.stock.toString());
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Current stock: ${product.stock}',
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Set new stock quantity',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final value = int.tryParse(controller.text.trim());
                        if (value != null && value >= 0) {
                          setState(() => store.updateStock(product.id, value));
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text('Update Stock'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...store.categories];

    return Scaffold(
      appBar: AppBar(title: const Text('STOCK')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final c = categories[index];
                  final selected = c == _filter;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppTheme.textSecondary,
                    ),
                    onSelected: (_) => setState(() => _filter = c),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text('No products found',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = _filtered[index];
                        return _StockCard(
                          product: product,
                          onRestock: () => _openRestockSheet(product),
                          onToggleOrdering: (allowed) {
                            setState(
                              () => store.toggleOrdering(product.id, allowed),
                            );
                          },
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

class _StockCard extends StatelessWidget {
  final Product product;
  final VoidCallback onRestock;
  final ValueChanged<bool> onToggleOrdering;

  const _StockCard({
    required this.product,
    required this.onRestock,
    required this.onToggleOrdering,
  });

  Color get _stockColor {
    if (product.isOutOfStock) return AppTheme.error;
    if (product.isLowStock) return AppTheme.warning;
    return AppTheme.success;
  }

  String get _stockLabel {
    if (product.isOutOfStock) return 'Out of stock';
    if (product.isLowStock) return 'Low stock';
    return 'In stock';
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    Text(product.category,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Text('₹${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _stockColor.withAOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_stockLabel • Qty: ${product.stock}',
                  style: TextStyle(
                      color: _stockColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              if (!product.orderingAllowed)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.block, color: AppTheme.textSecondary, size: 18),
                ),
              const Text('Allow ordering',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              Switch(
                value: product.orderingAllowed,
                activeThumbColor: AppTheme.primary,
                onChanged: onToggleOrdering,
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRestock,
              icon: const Icon(Icons.sync_alt, size: 18),
              label: const Text('Restock'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 42),
              ),
            ),
          ),
        ],
      ),
    );
  }
}