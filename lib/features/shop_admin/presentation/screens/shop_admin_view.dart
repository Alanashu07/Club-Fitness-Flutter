import 'package:flutter/material.dart';

import 'shop_admin_screens.dart';

/// Root shell for the Admin Shopping module.
/// Bottom bar: Home, Categories, Stock, Orders.
class ShopAdminView extends StatefulWidget {
  const ShopAdminView({super.key});

  @override
  State<ShopAdminView> createState() => _ShopAdminViewState();
}

class _ShopAdminViewState extends State<ShopAdminView> {
  int _index = 0;

  final List<Widget> _tabs = const [
    AdminHomeTab(),
    CategoriesTab(),
    StockTab(),
    OrdersTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}