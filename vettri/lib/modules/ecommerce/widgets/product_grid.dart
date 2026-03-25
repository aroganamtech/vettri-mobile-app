import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../controllers/ecommerce_controller.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final EcommerceController controller;

  const ProductGrid({super.key, required this.products, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            Text('No products found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
            const SizedBox(height: 6),
            Text('Try adjusting filters or search term',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
          ]),
        ),
      );
    }

    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) => ProductCard(
        product: products[index],
        controller: controller,
      ),
    );
  }
}
