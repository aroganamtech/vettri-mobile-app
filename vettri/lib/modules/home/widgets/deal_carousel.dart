import 'dart:async';
import 'package:flutter/material.dart';
import '../models/deal_item.dart';

class DealCarousel extends StatefulWidget {
  const DealCarousel({super.key});

  @override
  State<DealCarousel> createState() => _DealCarouselState();
}

class _DealCarouselState extends State<DealCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.95);
  int _currentPage = 0;
  Timer? _timer;

  final List<DealItem> _deals = [
    const DealItem(
      title: 'Super Deals!',
      subtitle: 'Up to 60% OFF',
      ctaText: 'Shop Now',
      icon: Icons.shopping_bag_outlined,
      gradientColors: [Color(0xFFFF5A1F), Color(0xFFFF3D00), Color(0xFFFF2D00)],
    ),
    const DealItem(
      title: 'Foodie Feast',
      subtitle: 'Flat ₹100 OFF',
      ctaText: 'Order Now',
      icon: Icons.fastfood_outlined,
      gradientColors: [Color(0xFFE91E63), Color(0xFFFF5722), Color(0xFFFF9800)],
    ),
    const DealItem(
      title: 'Movie Magic',
      subtitle: 'Book 1 Get 1',
      ctaText: 'Book Now',
      icon: Icons.movie_outlined,
      gradientColors: [Color(0xFF2196F3), Color(0xFF3F51B5), Color(0xFF673AB7)],
    ),
    const DealItem(
      title: 'Luxury Stays',
      subtitle: 'Luxury stays discount',
      ctaText: 'Book Now',
      icon: Icons.hotel_outlined,
      gradientColors: [Color(0xFF009688), Color(0xFF4CAF50), Color(0xFF8BC34A)],
    ),
    const DealItem(
      title: 'Fast Tracks',
      subtitle: 'Fast booking offers',
      ctaText: 'Book Now',
      icon: Icons.train_outlined,
      gradientColors: [Color(0xFF607D8B), Color(0xFF455A64), Color(0xFF263238)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _deals.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _deals.length,
            itemBuilder: (context, index) {
              return _buildDealCard(_deals[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildIndicators(),
      ],
    );
  }

  Widget _buildDealCard(DealItem deal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: deal.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: deal.gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              deal.icon,
              size: 150,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        deal.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deal.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: deal.gradientColors.first,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          deal.ctaText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Icon(
                      deal.icon,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _deals.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? const Color(0xFFFF5A1F) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
