import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class EcommerceController extends ChangeNotifier {
  // ── User Profile ───────────────────────────────────────────────────────────
  UserProfile userProfile = UserProfile(
    name: 'Guna K',
    email: 'guna.k@example.com',
    phone: '+91 98765 43210',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
  );

  // ── Addresses ──────────────────────────────────────────────────────────────
  final List<UserAddress> _addresses = [
    UserAddress(
      id: 'addr1',
      label: 'Home',
      name: 'Guna K',
      phone: '+91 98765 43210',
      line1: '12/3, Anna Nagar',
      line2: 'Near Marina Beach',
      city: 'Chennai',
      state: 'Tamil Nadu',
      pincode: '600040',
      isDefault: true,
    ),
    UserAddress(
      id: 'addr2',
      label: 'Office',
      name: 'Guna K',
      phone: '+91 98765 43210',
      line1: 'Block A, Tech Park',
      line2: '',
      city: 'Coimbatore',
      state: 'Tamil Nadu',
      pincode: '641014',
      isDefault: false,
    ),
  ];

  List<UserAddress> get addresses => List.unmodifiable(_addresses);

  UserAddress? get defaultAddress =>
      _addresses.isEmpty ? null : _addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => _addresses.first,
      );

  void addAddress(UserAddress address) {
    if (address.isDefault) {
      for (var a in _addresses) {
        a.isDefault = false;
      }
    }
    _addresses.add(address);
    notifyListeners();
  }

  void updateAddress(UserAddress updated) {
    if (updated.isDefault) {
      for (var a in _addresses) {
        a.isDefault = false;
      }
    }
    final idx = _addresses.indexWhere((a) => a.id == updated.id);
    if (idx >= 0) _addresses[idx] = updated;
    notifyListeners();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void setDefaultAddress(String id) {
    for (var a in _addresses) {
      a.isDefault = a.id == id;
    }
    notifyListeners();
  }

  // ── Cart ───────────────────────────────────────────────────────────────────
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  int get cartCount => _cartItems.fold(0, (s, i) => s + i.quantity);
  double get cartTotal => _cartItems.fold(0, (s, i) => s + i.totalPrice);

  void addToCart(Product product) {
    final idx = _cartItems.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _cartItems[idx].quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) { removeFromCart(productId); return; }
    final idx = _cartItems.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) { _cartItems[idx].quantity = qty; notifyListeners(); }
  }

  bool isInCart(String productId) =>
      _cartItems.any((i) => i.product.id == productId);

  void clearCart() { _cartItems.clear(); notifyListeners(); }

  // ── Wishlist ───────────────────────────────────────────────────────────────
  final Set<String> _wishlist = {};
  final List<Product> _wishlistProducts = [];

  Set<String> get wishlist => Set.unmodifiable(_wishlist);
  List<Product> get wishlistProducts => List.unmodifiable(_wishlistProducts);

  void toggleWishlist(String productId, [Product? product]) {
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
      _wishlistProducts.removeWhere((p) => p.id == productId);
    } else {
      _wishlist.add(productId);
      if (product != null) _wishlistProducts.add(product);
    }
    notifyListeners();
  }

  bool isWishlisted(String productId) => _wishlist.contains(productId);

  // ── Orders ─────────────────────────────────────────────────────────────────
  final List<OrderModel> _orders = [];
  List<OrderModel> get orders => List.unmodifiable(_orders);

  OrderModel placeOrder({
    required List<CartItem> items,
    required double total,
    required double savings,
    String address = '',
    String paymentMethod = 'UPI',
  }) {
    final order = OrderModel(
      orderId: 'VT${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      items: List.from(items),
      total: total,
      savings: savings,
      placedAt: DateTime.now(),
      deliveryAddress: address.isNotEmpty
          ? address
          : defaultAddress?.fullAddress ?? 'Chennai, Tamil Nadu - 600001',
      paymentMethod: paymentMethod,
      status: OrderStatus.confirmed,
    );
    _orders.insert(0, order);
    clearCart();
    notifyListeners();
    return order;
  }

  void advanceOrderStatus(String orderId) {
    final order = _orders.firstWhere((o) => o.orderId == orderId);
    final values = OrderStatus.values;
    final idx = values.indexOf(order.status);
    if (idx < values.length - 1) {
      order.status = values[idx + 1];
      notifyListeners();
    }
  }

  // ── Search & Filter ────────────────────────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _sortBy = 'Popularity';
  String get sortBy => _sortBy;

  double _minPrice = 0;
  double _maxPrice = double.infinity;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  double _minRating = 0;
  double get minRating => _minRating;

  int _minDiscount = 0;
  int get minDiscount => _minDiscount;

  bool _inStockOnly = false;
  bool get inStockOnly => _inStockOnly;

  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setCategory(String c) { _selectedCategory = c; notifyListeners(); }
  void setSortBy(String s) { _sortBy = s; notifyListeners(); }
  void setPriceRange(double min, double max) {
    _minPrice = min; _maxPrice = max; notifyListeners();
  }
  void setMinRating(double r) { _minRating = r; notifyListeners(); }

  void setFilters({
    double? minPrice,
    double? maxPrice,
    double minRating = 0,
    int minDiscount = 0,
    bool inStockOnly = false,
  }) {
    _minPrice = minPrice ?? 0;
    _maxPrice = maxPrice ?? double.infinity;
    _minRating = minRating;
    _minDiscount = minDiscount;
    _inStockOnly = inStockOnly;
    notifyListeners();
  }

  void resetFilters() {
    _minPrice = 0; _maxPrice = double.infinity; _minRating = 0;
    _minDiscount = 0; _inStockOnly = false;
    _searchQuery = ''; _selectedCategory = 'All'; _sortBy = 'Popularity';
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _minPrice > 0 || _maxPrice < double.infinity ||
      _minRating > 0 || _minDiscount > 0 || _inStockOnly;

  List<Product> filteredProducts(List<Product> all) {
    List<Product> list = List.from(all);
    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.brand.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q)).toList();
    }
    if (_minPrice > 0) list = list.where((p) => p.price >= _minPrice).toList();
    if (_maxPrice < double.infinity) list = list.where((p) => p.price <= _maxPrice).toList();
    if (_minRating > 0) list = list.where((p) => p.rating >= _minRating).toList();
    if (_minDiscount > 0) list = list.where((p) => p.discountPercent >= _minDiscount).toList();
    if (_inStockOnly) list = list.where((p) => p.inStock).toList();

    switch (_sortBy) {
      case 'Price: Low to High': list.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'Price: High to Low': list.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'Rating': list.sort((a, b) => b.rating.compareTo(a.rating)); break;
      case 'Discount': list.sort((a, b) => b.discountPercent.compareTo(a.discountPercent)); break;
    }
    return list;
  }
}
