import 'package:flutter/material.dart';
import '../controllers/ecommerce_controller.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  final EcommerceController controller;
  const WishlistScreen({super.key, required this.controller});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _fmt(double p) {
    if (p >= 100000) return '${(p / 100000).toStringAsFixed(1)}L';
    if (p >= 1000) {
      final s = p.toStringAsFixed(0);
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return p.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final items = ctrl.wishlistProducts;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: primary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('My Wishlist',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          Text('${items.length} item${items.length != 1 ? 's' : ''}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
      body: items.isEmpty
          ? _emptyState(context, primary)
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _wishlistCard(context, items[i], ctrl, primary),
            ),
    );
  }

  Widget _wishlistCard(BuildContext ctx, Product p,
      EcommerceController ctrl, Color primary) {
    final inCart = ctrl.isInCart(p.id);
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: p, controller: ctrl)))
          .then((_) => setState(() {})),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Container(width: 110, height: 110, color: Colors.grey.shade50,
              child: Image.network(p.image, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.image_not_supported, color: Colors.grey.shade300)))),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (p.brand.isNotEmpty)
                Text(p.brand, style: TextStyle(color: primary, fontSize: 11,
                    fontWeight: FontWeight.w600)),
              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3)),
              const SizedBox(height: 6),
              Row(children: [
                Text('₹${_fmt(p.price)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                if (p.discountPercent > 0)
                  Text('${p.discountPercent}% off',
                    style: TextStyle(color: Colors.green.shade700, fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: SizedBox(height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ctrl.addToCart(p);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Added to cart'),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(12),
                      ));
                    },
                    icon: Icon(inCart ? Icons.check_circle : Icons.shopping_cart_outlined,
                        size: 13, color: Colors.white),
                    label: Text(inCart ? 'In Cart' : 'Add to Cart',
                        style: const TextStyle(color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inCart ? Colors.green.shade600 : primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero, elevation: 0),
                  ))),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () { ctrl.toggleWishlist(p.id); setState(() {}); },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18))),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _emptyState(BuildContext ctx, Color primary) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text('Your wishlist is empty',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Save items you love for later',
          style: TextStyle(color: Colors.grey.shade500)),
      const SizedBox(height: 24),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Explore Products',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ]));
  }
}
