import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../controllers/ecommerce_controller.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final EcommerceController controller;
  final bool openBuyNow;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.controller,
    this.openBuyNow = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.openBuyNow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToCart();
      });
    }
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(controller: widget.controller),
      ),
    ).then((_) => setState(() {}));
  }

  String _fmt(double price) {
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) {
      final s = price.toStringAsFixed(0);
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return price.toStringAsFixed(0);
  }

  String _fmtCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final ctrl = widget.controller;
    final primary = Theme.of(context).primaryColor;
    final isWished = ctrl.isWishlisted(p.id);
    final inCart = ctrl.isInCart(p.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          p.brand.isNotEmpty ? p.brand : 'Product',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                onPressed: _navigateToCart,
              ),
              if (ctrl.cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      ctrl.cartCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product image ─────────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Image.network(
                      p.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (p.badge.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.badge == 'Deal'
                              ? Colors.green.shade600
                              : Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (p.discountPercent > 0)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${p.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        ctrl.toggleWishlist(p.id, p);
                        setState(() {});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          isWished ? Icons.favorite : Icons.favorite_border,
                          color: isWished ? Colors.red : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Info card ──────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.brand.isNotEmpty)
                    Text(
                      p.brand,
                      style: TextStyle(
                        color: primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              p.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_fmtCount(p.reviewCount)} ratings',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (p.discountPercent > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            '${p.discountPercent}% off',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      Text(
                        '₹${_fmt(p.price)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (p.originalPrice > p.price)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          Text(
                            'M.R.P: ',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '₹${_fmt(p.originalPrice)}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Save ₹${_fmt(p.originalPrice - p.price)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (p.isPrime)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A8E0),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'prime',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'FREE delivery Tomorrow',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Delivery ───────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  _deliveryRow(
                    Icons.local_shipping_outlined,
                    'Standard Delivery',
                    'FREE · Arrives Tomorrow',
                  ),
                  const SizedBox(height: 10),
                  _deliveryRow(
                    Icons.bolt_outlined,
                    'Express',
                    'FREE for Prime · Today by 10 PM',
                  ),
                  const SizedBox(height: 10),
                  _deliveryRow(
                    Icons.location_on_outlined,
                    'Deliver to',
                    'Chennai - 600001',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Highlights ─────────────────────────────────────────────────────
            if (p.highlights.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Highlights',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...p.highlights.map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                h,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // ── Description ────────────────────────────────────────────────────
            if (p.description.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About this item',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      maxLines: _descExpanded ? null : 3,
                      overflow: _descExpanded ? null : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _descExpanded = !_descExpanded),
                      child: Text(
                        _descExpanded ? 'Show less' : 'Read more',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: p.inStock
            ? Row(
                children: [
                  // Wishlist
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(
                        isWished ? Icons.favorite : Icons.favorite_border,
                        color: isWished ? Colors.red : primary,
                        size: 18,
                      ),
                      label: Text(
                        isWished ? 'Wishlisted' : 'Wishlist',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        ctrl.toggleWishlist(p.id, p);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add to Cart
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(
                        inCart
                            ? Icons.check_circle
                            : Icons.shopping_cart_outlined,
                        size: 18,
                        color: primary,
                      ),
                      label: Text(
                        inCart ? 'Go to Cart' : 'Add to Cart',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (inCart) {
                          _navigateToCart();
                        } else {
                          ctrl.addToCart(p);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Buy Now
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFB641B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ctrl.addToCart(p);
                        setState(() {});
                        _navigateToCart();
                      },
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: null,
                  child: const Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _deliveryRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
