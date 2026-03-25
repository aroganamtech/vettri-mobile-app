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
      gradientColors: [Color(0xFFFF5A1F), Color(0xFFFF3D00)],
      imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80',
    ),
    const DealItem(
      title: 'Foodie Feast',
      subtitle: 'Flat ₹100 OFF',
      ctaText: 'Order Now',
      icon: Icons.fastfood_outlined,
      gradientColors: [Color(0xFFE91E63), Color(0xFFFF5722)],
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
    ),
    const DealItem(
      title: 'Movie Magic',
      subtitle: 'Book 1 Get 1',
      ctaText: 'Book Now',
      icon: Icons.movie_outlined,
      gradientColors: [Color(0xFF2196F3), Color(0xFF3F51B5)],
      imageUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=800&q=80',
    ),
    const DealItem(
      title: 'Luxury Stays',
      subtitle: 'Luxury stays discount',
      ctaText: 'Book Now',
      icon: Icons.hotel_outlined,
      gradientColors: [Color(0xFF009688), Color(0xFF4CAF50)],
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
    ),
    const DealItem(
      title: 'Fast Tracks',
      subtitle: 'Fast booking offers',
      ctaText: 'Book Now',
      icon: Icons.train_outlined,
      gradientColors: [Color(0xFF607D8B), Color(0xFF455A64)],
      imageUrl: 'https://images.unsplash.com/photo-1474487056236-0529c99a7fd2?w=800&q=80',
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
          height: 240,

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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: deal.gradientColors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background Image
            Image.network(
              deal.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: deal.gradientColors.first.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),

            // Gradient Overlay for Content Contrast
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      deal.gradientColors.first.withOpacity(0.9),
                      deal.gradientColors.last.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Background Icon Pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                deal.icon,
                size: 140,
                color: Colors.white.withOpacity(0.15),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'LIMITED OFFER',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    deal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    deal.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: Text(
                      deal.ctaText.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
