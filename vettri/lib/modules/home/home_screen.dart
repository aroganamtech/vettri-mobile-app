import 'package:flutter/material.dart';
import '../../core/widgets/bottom_navbar.dart';

import 'widgets/header_section.dart';
import 'widgets/category_row.dart';
import 'widgets/deal_carousel.dart';
import 'widgets/food_carousel_section.dart';
import 'widgets/movie_section.dart';
import 'widgets/ott_section.dart';
import '../../core/widgets/movie_carousel.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HeaderSection(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: CategoryRow(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: DealCarousel(),
            ),
            MovieCarousel(),
            FoodCarouselSection(),
            MovieSection(),
            OTTSection(),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
