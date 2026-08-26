import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final IconData icon;
  final Color color;
  final String unit;
  final bool inStock;
  final int stockCount;
  final bool featured;
  final double? rating;
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    required this.unit,
    this.inStock = true,
    this.stockCount = 20,
    this.featured = false,
    this.rating,
  });
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get subtotal => product.price * quantity;
}

// ─── Cart Controller (simple shared state) ─────────────────────────────────────

class CartController extends ChangeNotifier {
  static final CartController instance = CartController._();
  CartController._();

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (s, i) => s + i.quantity);
  double get total => _items.values.fold(0, (s, i) => s + i.subtotal);
  bool isInCart(String productId) => _items.containsKey(productId);
  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  void add(Product p) {
    if (_items.containsKey(p.id)) {
      _items[p.id]!.quantity++;
    } else {
      _items[p.id] = CartItem(product: p);
    }
    notifyListeners();
  }

  void remove(Product p) {
    if (!_items.containsKey(p.id)) return;
    if (_items[p.id]!.quantity > 1) {
      _items[p.id]!.quantity--;
    } else {
      _items.remove(p.id);
    }
    notifyListeners();
  }

  void removeAll(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────

const _categories = [
  ('All', Icons.apps_rounded, AppTheme.primary),
  ('Supplements', Icons.science_rounded, Color(0xFFC41E2D)),
  ('Apparel', Icons.checkroom_rounded, Color(0xFF7B1FA2)),
  ('Accessories', Icons.water_drop_rounded, Color(0xFF29B6F6)),
  ('Equipment', Icons.fitness_center_rounded, Color(0xFF2E7D32)),
];

final _products = [
  const Product(
    id: 'p1',
    name: 'Whey Protein Gold — 1kg',
    category: 'Supplements',
    price: 2499,
    icon: Icons.science_rounded,
    color: Color(0xFFC41E2D),
    unit: 'per tub',
    stockCount: 8,
    featured: true,
    rating: 4.8,
  ),
  const Product(
    id: 'p2',
    name: 'BCAA Recovery — 300g',
    category: 'Supplements',
    price: 1199,
    icon: Icons.science_rounded,
    color: Color(0xFFC41E2D),
    unit: 'per tub',
    stockCount: 14,
    rating: 4.5,
  ),
  const Product(
    id: 'p3',
    name: 'Creatine Monohydrate',
    category: 'Supplements',
    price: 899,
    icon: Icons.science_rounded,
    color: Color(0xFFC41E2D),
    unit: 'per tub',
    stockCount: 2,
    rating: 4.7,
  ),
  const Product(
    id: 'p4',
    name: 'Mass Gainer — 2kg',
    category: 'Supplements',
    price: 2999,
    icon: Icons.science_rounded,
    color: Color(0xFFC41E2D),
    unit: 'per tub',
    stockCount: 0,
    inStock: false,
    rating: 4.3,
  ),
  const Product(
    id: 'p5',
    name: 'Club Fitness Gym Tee',
    category: 'Apparel',
    price: 649,
    icon: Icons.checkroom_rounded,
    color: Color(0xFF7B1FA2),
    unit: 'per piece',
    stockCount: 22,
    featured: true,
    rating: 4.6,
  ),
  const Product(
    id: 'p6',
    name: 'Performance Tank Top',
    category: 'Apparel',
    price: 549,
    icon: Icons.checkroom_rounded,
    color: Color(0xFF7B1FA2),
    unit: 'per piece',
    stockCount: 16,
    rating: 4.4,
  ),
  const Product(
    id: 'p7',
    name: 'Training Shorts',
    category: 'Apparel',
    price: 799,
    icon: Icons.checkroom_rounded,
    color: Color(0xFF7B1FA2),
    unit: 'per piece',
    stockCount: 9,
    rating: 4.5,
  ),
  const Product(
    id: 'p8',
    name: 'Gym Shaker Bottle 700ml',
    category: 'Accessories',
    price: 299,
    icon: Icons.water_drop_rounded,
    color: Color(0xFF29B6F6),
    unit: 'per piece',
    stockCount: 30,
    featured: true,
    rating: 4.9,
  ),
  const Product(
    id: 'p9',
    name: 'Lifting Gloves',
    category: 'Accessories',
    price: 449,
    icon: Icons.back_hand_rounded,
    color: Color(0xFF29B6F6),
    unit: 'per pair',
    stockCount: 11,
    rating: 4.6,
  ),
  const Product(
    id: 'p10',
    name: 'Gym Duffel Bag',
    category: 'Accessories',
    price: 1299,
    icon: Icons.backpack_rounded,
    color: Color(0xFF29B6F6),
    unit: 'per piece',
    stockCount: 5,
    rating: 4.7,
  ),
  const Product(
    id: 'p11',
    name: 'Resistance Band Set',
    category: 'Equipment',
    price: 599,
    icon: Icons.sports_gymnastics_rounded,
    color: Color(0xFF2E7D32),
    unit: 'per set',
    stockCount: 13,
    rating: 4.4,
  ),
  const Product(
    id: 'p12',
    name: 'Skipping Rope Pro',
    category: 'Equipment',
    price: 399,
    icon: Icons.sports_rounded,
    color: Color(0xFF2E7D32),
    unit: 'per piece',
    stockCount: 18,
    rating: 4.5,
  ),
  const Product(
    id: 'p13',
    name: 'Knee Sleeves',
    category: 'Equipment',
    price: 899,
    icon: Icons.accessibility_new_rounded,
    color: Color(0xFF2E7D32),
    unit: 'per pair',
    stockCount: 7,
    rating: 4.6,
  ),
  const Product(
    id: 'p14',
    name: 'Lifting Belt — Leather',
    category: 'Equipment',
    price: 1799,
    icon: Icons.fitness_center_rounded,
    color: Color(0xFF2E7D32),
    unit: 'per piece',
    stockCount: 4,
    rating: 4.8,
  ),
];

// ─── Main Shop Screen ──────────────────────────────────────────────────────────

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});
  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    CartController.instance.addListener(_onCartChange);
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()),
    );
  }

  void _onCartChange() => setState(() {});

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    CartController.instance.removeListener(_onCartChange);
    super.dispose();
  }

  List<Product> get _filteredProducts {
    return _products.where((p) {
      final matchCat =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch =
          _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery);
      return matchCat && matchSearch;
    }).toList();
  }

  List<Product> get _featuredProducts =>
      _products.where((p) => p.featured).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: IndexedStack(
          index: _navIndex,
          children: [
            _buildHomeTab(),
            _buildCategoriesTab(),
            const _CartTab(),
            _buildOrdersTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HOME TAB ─────────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              // ── Pickup notice — IMPORTANT ─────────────────────────────────
              _buildPickupNotice(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 22),
              // Category quick row
              _buildCategoryRow(),
              const SizedBox(height: 24),
              // Featured
              _sectionLabel('Featured Products', '🔥 Popular picks'),
              const SizedBox(height: 14),
              _buildFeaturedRow(),
              const SizedBox(height: 26),
              // All products grid
              _sectionLabel('All Products', '${_products.length} items'),
              const SizedBox(height: 14),
              _buildProductGrid(_products),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: AppTheme.background,
      elevation: 0,
      toolbarHeight: 64,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Club Fitness Shop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Pre-order · Pay & collect in person',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 9.5),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Pickup-only payment notice (the key NB requirement) ────────────────────
  Widget _buildPickupNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withAOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withAOpacity(0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How ordering works',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'This app is for browsing & pre-ordering only. There\'s no online payment — pay in cash/UPI and collect your order directly at the Club Fitness front desk.',
                  style: TextStyle(
                    color: Colors.white.withAOpacity(0.65),
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? AppTheme.primary.withAOpacity(0.5)
              : Colors.white.withAOpacity(0.06),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search products…',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = _categories[i];
          final selected = _selectedCategory == c.$1;
          final color = c.$3;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = c.$1;
                _navIndex = 1;
              });
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: selected ? color : color.withAOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withAOpacity(selected ? 1 : 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    c.$2,
                    color: selected ? Colors.white : color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.$1,
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textSecondary,
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedRow() {
    return SizedBox(
      height: 186,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _featuredProducts.length,
        itemBuilder: (_, i) =>
            _FeaturedProductCard(product: _featuredProducts[i]),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(product: products[i]),
    );
  }

  Widget _sectionLabel(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          sub,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  // ── CATEGORIES TAB ───────────────────────────────────────────────────────────
  Widget _buildCategoriesTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverAppBar(
          floating: true,
          backgroundColor: AppTheme.background,
          elevation: 0,
          toolbarHeight: 64,
          title: Text(
            'Categories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final c = _categories[i];
                      final selected = _selectedCategory == c.$1;
                      final color = c.$3;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = c.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? color : AppTheme.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? color
                                  : Colors.white.withAOpacity(0.07),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                c.$2,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                c.$1,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '${_filteredProducts.length} products',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.66,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _ProductCard(product: _filteredProducts[i]),
              childCount: _filteredProducts.length,
            ),
          ),
        ),
      ],
    );
  }

  // ── ORDERS TAB ────────────────────────────────────────────────────────────────
  Widget _buildOrdersTab() {
    final orders = [
      (
        'CF-ORD-1082',
        'Ready for Pickup',
        const Color(0xFF4CAF50),
        'Jun 18',
        '₹2,798',
        2,
      ),
      (
        'CF-ORD-1077',
        'Confirmed',
        const Color(0xFF29B6F6),
        'Jun 15',
        '₹649',
        1,
      ),
      (
        'CF-ORD-1065',
        'Collected',
        AppTheme.textSecondary,
        'Jun 10',
        '₹1,498',
        2,
      ),
    ];
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverAppBar(
          floating: true,
          backgroundColor: AppTheme.background,
          elevation: 0,
          toolbarHeight: 64,
          title: Text(
            'My Orders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              orders
                  .map(
                    (o) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (o.$3).withAOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: (o.$3).withAOpacity(0.14),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  Icons.shopping_bag_rounded,
                                  color: o.$3,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.$1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${o.$6} items · ${o.$4}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                o.$5,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: (o.$3).withAOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: o.$3,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  o.$2,
                                  style: TextStyle(
                                    color: o.$3,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.storefront_rounded, Icons.storefront_outlined, 'Home'),
      (Icons.grid_view_rounded, Icons.grid_view_outlined, 'Categories'),
      (Icons.shopping_cart_rounded, Icons.shopping_cart_outlined, 'Cart'),
      (Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Orders'),
    ];
    final cartCount = CartController.instance.itemCount;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = _navIndex == i;
              final isCart = i == 2;
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withAOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            selected ? item.$1 : item.$2,
                            color: selected ? AppTheme.primary : Colors.grey,
                            size: 22,
                          ),
                          if (isCart && cartCount > 0)
                            Positioned(
                              right: -8,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.surface,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$cartCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: TextStyle(
                          color: selected ? AppTheme.primary : Colors.grey,
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Featured Product Card (horizontal scroll) ────────────────────────────────

class _FeaturedProductCard extends StatelessWidget {
  final Product product;
  const _FeaturedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final inCart = CartController.instance.isInCart(product.id);
        final qty = CartController.instance.quantityOf(product.id);

        return Container(
          width: 150,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [product.color.withAOpacity(0.16), AppTheme.card],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: product.color.withAOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: product.color.withAOpacity(0.18),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(product.icon, color: product.color, size: 19),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'HOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              if (product.rating != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD600),
                      size: 13,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${product.rating}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: product.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  inCart
                      ? _MiniQtyStepper(
                          qty: qty,
                          color: product.color,
                          onAdd: () => CartController.instance.add(product),
                          onRemove: () =>
                              CartController.instance.remove(product),
                        )
                      : GestureDetector(
                          onTap: () => CartController.instance.add(product),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: product.color,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
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
}

// ─── Standard Product Card (grid) ──────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final inCart = CartController.instance.isInCart(product.id);
        final qty = CartController.instance.quantityOf(product.id);
        final lowStock = product.inStock && product.stockCount <= 3;

        return GestureDetector(
          onTap: () => _openProductDetail(context, product),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: inCart
                    ? product.color.withAOpacity(0.5)
                    : Colors.white.withAOpacity(0.06),
                width: inCart ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image / icon area
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: product.color.withAOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            product.icon,
                            color: product.color,
                            size: 38,
                          ),
                        ),
                      ),
                      if (!product.inStock)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withAOpacity(0.6),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (lowStock && product.inStock)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA000),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${product.stockCount} left',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.unit,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 9.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: product.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (!product.inStock)
                            const SizedBox(width: 28, height: 28)
                          else if (inCart)
                            _MiniQtyStepper(
                              qty: qty,
                              color: product.color,
                              onAdd: () => CartController.instance.add(product),
                              onRemove: () =>
                                  CartController.instance.remove(product),
                            )
                          else
                            GestureDetector(
                              onTap: () => CartController.instance.add(product),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: product.color,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openProductDetail(BuildContext context, Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailSheet(product: p),
    );
  }
}

// ─── Mini Quantity Stepper (used in cards) ────────────────────────────────────

class _MiniQtyStepper extends StatelessWidget {
  final int qty;
  final Color color;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _MiniQtyStepper({
    required this.qty,
    required this.color,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.remove_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          SizedBox(
            width: 18,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Product Detail Sheet ──────────────────────────────────────────────────────

class _ProductDetailSheet extends StatelessWidget {
  final Product product;
  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final inCart = CartController.instance.isInCart(product.id);
        final qty = CartController.instance.quantityOf(product.id);

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Icon hero
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: product.color.withAOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: product.color.withAOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(product.icon, color: product.color, size: 48),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                product.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: product.color.withAOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: product.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (product.rating != null) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD600),
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${product.rating} rating',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: product.color,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        product.unit,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (!product.inStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withAOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: AppTheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  else
                    Text(
                      '${product.stockCount} in stock',
                      style: TextStyle(
                        color: product.stockCount <= 3
                            ? const Color(0xFFFFA000)
                            : AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Pickup reminder
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1A12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withAOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pay & collect at Club Fitness front desk — no online payment.',
                        style: TextStyle(
                          color: Colors.white.withAOpacity(0.6),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (product.inStock)
                inCart
                    ? Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: product.color.withAOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        CartController.instance.remove(product),
                                    icon: Icon(
                                      Icons.remove_rounded,
                                      color: product.color,
                                    ),
                                  ),
                                  Text(
                                    '$qty in cart',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        CartController.instance.add(product),
                                    icon: Icon(
                                      Icons.add_rounded,
                                      color: product.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () {
                          CartController.instance.add(product);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: product.color,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
            ],
          ),
        );
      },
    );
  }
}

// ─── CART TAB ──────────────────────────────────────────────────────────────────

class _CartTab extends StatefulWidget {
  const _CartTab();
  @override
  State<_CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<_CartTab> {
  @override
  void initState() {
    super.initState();
    CartController.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    CartController.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = CartController.instance.items;

    if (items.isEmpty) {
      return _buildEmptyCart();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            toolbarHeight: 64,
            title: Text(
              'My Cart (${CartController.instance.itemCount})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => CartController.instance.clear(),
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1A12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withAOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF4CAF50),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No payment happens here. Confirm your order, then pay & collect at the gym.',
                        style: TextStyle(
                          color: Colors.white.withAOpacity(0.65),
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _CartItemTile(item: items[i]),
                childCount: items.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 220)),
        ],
      ),
      bottomNavigationBar: _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 64,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'My Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: AppTheme.card,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppTheme.textSecondary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Browse the shop and add some products',
                      style: TextStyle(
                        color: Colors.white.withAOpacity(0.35),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar() {
    final total = CartController.instance.total;
    final count = CartController.instance.itemCount;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(
            top: BorderSide(color: Colors.white10, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$count item${count == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Total: ₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _openCheckout(context),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Place Pre-Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCheckout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CheckoutSheet(),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: p.color.withAOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(p.icon, color: p.color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '₹${p.price.toStringAsFixed(0)} ${p.unit}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.subtotal.toStringAsFixed(0)}',
                style: TextStyle(
                  color: p.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              _MiniQtyStepper(
                qty: item.quantity,
                color: p.color,
                onAdd: () => CartController.instance.add(p),
                onRemove: () => CartController.instance.remove(p),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Checkout Sheet ─────────────────────────────────────────────────────────────

class _CheckoutSheet extends StatelessWidget {
  const _CheckoutSheet();

  @override
  Widget build(BuildContext context) {
    final items = CartController.instance.items;
    final total = CartController.instance.total;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirm Pre-Order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Order summary
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white10, height: 16),
              itemBuilder: (_, i) {
                final item = items[i];
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} ×${item.quantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '₹${item.subtotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Payment notice — reiterated at checkout
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1200),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFFD600).withAOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_rounded,
                  color: Color(0xFFFFD600),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This confirms your pre-order only. No payment is collected through the app. Pay in cash/UPI and collect your items at the Club Fitness front desk.',
                    style: TextStyle(
                      color: Colors.white.withAOpacity(0.7),
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog(context, total);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Confirm Pre-Order',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, double total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Order Placed!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Text(
          'Your pre-order of ₹${total.toStringAsFixed(0)} has been placed. Visit the Club Fitness front desk to pay and collect your items.',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              CartController.instance.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
