import '../../domain/entities/product.dart';

/// Temporary in-memory data source.
/// Replace with your real repository / API / Firestore calls.
class AdminDataStore {
  AdminDataStore._internal();
  static final AdminDataStore instance = AdminDataStore._internal();

  final List<String> categories = [
    'Supplements',
    'Apparel',
    'Accessories',
    'Beverages',
    'Equipment',
  ];

  final List<Product> _products = [
    const Product(
      id: 'p1',
      name: 'Whey Protein 1kg',
      category: 'Supplements',
      price: 2499,
      stock: 18,
    ),
    const Product(
      id: 'p2',
      name: 'Club Fitness Tee',
      category: 'Apparel',
      price: 699,
      stock: 4,
    ),
    const Product(
      id: 'p3',
      name: 'Shaker Bottle',
      category: 'Accessories',
      price: 299,
      stock: 0,
    ),
    const Product(
      id: 'p4',
      name: 'Energy Drink',
      category: 'Beverages',
      price: 99,
      stock: 40,
      orderingAllowed: false,
    ),
    const Product(
      id: 'p5',
      name: 'Resistance Band',
      category: 'Equipment',
      price: 499,
      stock: 12,
    ),
  ];

  List<Product> get products => List.unmodifiable(_products);

  void updateStock(String id, int newStock) {
    final i = _products.indexWhere((p) => p.id == id);
    if (i != -1) _products[i] = _products[i].copyWith(stock: newStock);
  }

  void toggleOrdering(String id, bool allowed) {
    final i = _products.indexWhere((p) => p.id == id);
    if (i != -1) {
      _products[i] = _products[i].copyWith(orderingAllowed: allowed);
    }
  }

  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  int get outOfStockCount => _products.where((p) => p.isOutOfStock).length;
  int get restrictedCount => _products.where((p) => !p.orderingAllowed).length;
}