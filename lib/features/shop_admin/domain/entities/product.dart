class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final bool orderingAllowed;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.orderingAllowed = true,
    this.imageUrl = '',
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    bool? orderingAllowed,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      orderingAllowed: orderingAllowed ?? this.orderingAllowed,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  bool get isLowStock => stock > 0 && stock <= 5;
  bool get isOutOfStock => stock <= 0;
}