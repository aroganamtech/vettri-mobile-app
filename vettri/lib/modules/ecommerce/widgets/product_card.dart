import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../controllers/ecommerce_controller.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final EcommerceController controller;

  const ProductCard({super.key, required this.product, required this.controller});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _scaleAnim;
  bool _cartAdded = false;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _bounceCtrl.dispose(); super.dispose(); }

  String _fmtPrice(double p) {
    if (p >= 100000) return '₹${(p / 100000).toStringAsFixed(1)}L';
    if (p >= 1000) {
      final s = p.toStringAsFixed(0);
      return '₹${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return '₹${p.toStringAsFixed(0)}';
  }

  String _fmtCount(int c) => c >= 1000 ? '${(c / 1000).toStringAsFixed(1)}k' : '$c';

  void _addToCart() {
    widget.controller.addToCart(widget.product);
    setState(() => _cartAdded = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(
          '${widget.product.name.split(' ').take(3).join(' ')} added to cart',
          overflow: TextOverflow.ellipsis,
        )),
      ]),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green.shade700,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final ctrl = widget.controller;
    final isWished = ctrl.isWishlisted(p.id);
    final inCart = ctrl.isInCart(p.id);
    final primary = Theme.of(context).primaryColor;

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: () async {
          await _bounceCtrl.forward();
          await _bounceCtrl.reverse();
          if (!mounted) return;
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: p, controller: ctrl),
          )).then((_) => setState(() {}));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12, offset: const Offset(0, 4),
            )],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ───────────────────────────────────────────────────
              Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade50,
                    child: Image.network(
                      p.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey.shade300, size: 42),
                      ),
                    ),
                  ),
                ),
                if (!p.inStock)
                  Positioned.fill(child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Out of Stock',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                  )),
                if (p.badge.isNotEmpty)
                  Positioned(top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _badgeColor(p.badge),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(p.badge, style: const TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (p.discountPercent > 0)
                  Positioned(bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600, borderRadius: BorderRadius.circular(4)),
                      child: Text('${p.discountPercent}% OFF',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(top: 6, right: 6,
                  child: GestureDetector(
                    onTap: () {
                      ctrl.toggleWishlist(p.id, p);
                      setState(() {});
                    },
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: isWished ? Colors.red.shade50 : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12), blurRadius: 4)],
                      ),
                      child: Center(child: Icon(
                        isWished ? Icons.favorite : Icons.favorite_border,
                        size: 15,
                        color: isWished ? Colors.red.shade500 : Colors.grey.shade500,
                      )),
                    ),
                  ),
                ),
              ]),

              // ── Info ─────────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.brand.isNotEmpty)
                        Text(p.brand.toUpperCase(),
                          style: TextStyle(fontSize: 9, color: primary,
                              fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 1),
                      Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                            height: 1.3, color: Colors.black87)),
                      const SizedBox(height: 4),

                      // Rating
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: _ratingColor(p.rating),
                            borderRadius: BorderRadius.circular(4)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(p.rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 2),
                            const Icon(Icons.star, color: Colors.white, size: 9),
                          ]),
                        ),
                        const SizedBox(width: 4),
                        Flexible(child: Text('(${_fmtCount(p.reviewCount)})',
                          style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                          overflow: TextOverflow.ellipsis)),
                      ]),
                      const SizedBox(height: 4),

                      // Price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(child: Text(_fmtPrice(p.price),
                            style: const TextStyle(fontSize: 14,
                                fontWeight: FontWeight.bold, color: Colors.black),
                            overflow: TextOverflow.ellipsis)),
                          if (p.originalPrice > p.price) ...[
                            const SizedBox(width: 4),
                            Flexible(child: Text(_fmtPrice(p.originalPrice),
                              style: TextStyle(fontSize: 10,
                                  color: Colors.grey.shade400,
                                  decoration: TextDecoration.lineThrough),
                              overflow: TextOverflow.ellipsis)),
                          ],
                        ],
                      ),

                      if (p.isPrime) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A8E0),
                              borderRadius: BorderRadius.circular(3)),
                            child: const Text('prime',
                              style: TextStyle(color: Colors.white, fontSize: 8,
                                  fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                          ),
                          const SizedBox(width: 4),
                          Text('FREE Delivery',
                            style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                        ]),
                      ],

                      const Spacer(),

                      // ── Action buttons in same row ──────────────────────
                      if (p.inStock)
                        Row(children: [
                          // Add to Cart
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: OutlinedButton(
                                onPressed: _addToCart,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: (inCart && _cartAdded) ? Colors.green : primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      (inCart && _cartAdded)
                                          ? Icons.check_circle
                                          : Icons.shopping_cart_outlined,
                                      size: 12,
                                      color: (inCart && _cartAdded) ? Colors.green : primary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      (inCart && _cartAdded) ? 'Added' : 'Cart',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: (inCart && _cartAdded) ? Colors.green : primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Buy Now
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!inCart) ctrl.addToCart(p);
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(
                                        product: p, controller: ctrl, openBuyNow: true),
                                  )).then((_) => setState(() {}));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFB641B),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.bolt, color: Colors.white, size: 12),
                                    SizedBox(width: 2),
                                    Text('Buy', style: TextStyle(
                                        color: Colors.white, fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ])
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: () { ctrl.toggleWishlist(p.id, p); setState(() {}); },
                            icon: Icon(Icons.notifications_outlined,
                                size: 13, color: Colors.grey.shade600),
                            label: Text('Notify Me', style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
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
      ),
    );
  }

  Color _badgeColor(String badge) {
    switch (badge) {
      case 'Deal': return Colors.green.shade600;
      case 'New': return Colors.blue.shade600;
      default: return Colors.orange.shade700;
    }
  }

  Color _ratingColor(double r) {
    if (r >= 4.5) return Colors.green.shade700;
    if (r >= 4.0) return Colors.green.shade500;
    if (r >= 3.5) return Colors.orange.shade600;
    return Colors.red.shade500;
  }
}
