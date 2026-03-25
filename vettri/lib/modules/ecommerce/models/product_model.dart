class Product {
  final String id;
  final String name;
  final String image;
  final List<String> images;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewCount;
  final String category;
  final String brand;
  final String description;
  final bool isSponsored;
  final bool isPrime;
  final int discount;
  final String badge;
  final bool inStock;
  final List<String> highlights;

  Product({
    required this.id,
    required this.name,
    required this.image,
    this.images = const [],
    required this.price,
    required this.originalPrice,
    required this.rating,
    this.reviewCount = 0,
    required this.category,
    this.brand = '',
    this.description = '',
    this.isSponsored = false,
    this.isPrime = false,
    this.discount = 0,
    this.badge = '',
    this.inStock = true,
    this.highlights = const [],
  });

  int get discountPercent =>
      discount > 0
          ? discount
          : originalPrice > price
          ? ((originalPrice - price) / originalPrice * 100).round()
          : 0;
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get totalPrice => product.price * quantity;
}

// ── Address ──────────────────────────────────────────────────────────────────
class UserAddress {
  final String id;
  String label;
  String name;
  String phone;
  String line1;
  String line2;
  String city;
  String state;
  String pincode;
  bool isDefault;

  UserAddress({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.line1,
    this.line2 = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  String get fullAddress =>
      '$name, $line1${line2.isNotEmpty ? ', $line2' : ''}, $city, $state - $pincode';

  UserAddress copyWith({
    String? label,
    String? name,
    String? phone,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id,
      label: label ?? this.label,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

// ── Order tracking ────────────────────────────────────────────────────────────
enum OrderStatus { confirmed, processing, shipped, outForDelivery, delivered }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.confirmed: return 'Order Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
    }
  }

  String get subtitle {
    switch (this) {
      case OrderStatus.confirmed: return 'Your order has been placed successfully';
      case OrderStatus.processing: return 'Seller is preparing your order';
      case OrderStatus.shipped: return 'Order picked up by courier partner';
      case OrderStatus.outForDelivery: return 'Out for delivery · Arriving today';
      case OrderStatus.delivered: return 'Delivered to your doorstep';
    }
  }
}

class OrderModel {
  final String orderId;
  final List<CartItem> items;
  final double total;
  final double savings;
  final DateTime placedAt;
  final String deliveryAddress;
  final String paymentMethod;
  OrderStatus status;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.total,
    required this.savings,
    required this.placedAt,
    this.deliveryAddress = 'Chennai, Tamil Nadu - 600001',
    this.paymentMethod = 'UPI',
    this.status = OrderStatus.confirmed,
  });

  String get expectedDelivery {
    final d = placedAt.add(const Duration(days: 2));
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month]}';
  }
}

// ── User Profile ──────────────────────────────────────────────────────────────
class UserProfile {
  String name;
  String email;
  String phone;
  String avatarUrl;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl = '',
  });
}
