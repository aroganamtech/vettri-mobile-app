import 'package:flutter/material.dart';
import 'category_item.dart';
import '../../../routes/app_routes.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CategoryItem(
          icon: Icons.shopping_bag_outlined,
          label: 'Shop',
          onTap: () => Navigator.pushNamed(context, AppRoutes.ecommerce),
        ),
        CategoryItem(
          icon: Icons.restaurant_outlined,
          label: 'Food',
          onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
        ),
        CategoryItem(
          icon: Icons.movie_outlined,
          label: 'Movies',
          onTap: () => Navigator.pushNamed(context, AppRoutes.movies),
        ),
        CategoryItem(
          icon: Icons.live_tv_outlined,
          label: 'OTT',
          onTap: () => Navigator.pushNamed(context, AppRoutes.entertainment),
        ),
      ],
    );
  }
}

