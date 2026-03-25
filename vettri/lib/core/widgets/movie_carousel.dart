import 'package:flutter/material.dart';

class MovieCarousel extends StatefulWidget {
  const MovieCarousel({super.key});

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  // Mock data as requested (structured for future Hive integration)
  static const List<Map<String, dynamic>> _movies = [
    {
      "title": "The Astronaut",
      "year": "2025",
      "languages": "3 Languages",
      "genre": "Science Fiction",
      "image": "https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=800&q=80",
      "isNew": true
    },
    {
      "title": "Neon City",
      "year": "2024",
      "languages": "Tamil • English",
      "genre": "Cyberpunk Action",
      "image": "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&q=80",
      "isNew": true
    },
    {
      "title": "Shadow Hunter",
      "year": "2023",
      "languages": "Hindi • English",
      "genre": "Supernatural Thriller",
      "image": "https://images.unsplash.com/photo-1509248961158-e54f6934749c?w=800&q=80",
      "isNew": false
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Text(
            'Recommended for You',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              // Scaling effect for center card
              double scale = (1 - (_currentPage - index).abs() * 0.1).clamp(0.85, 1.0);
              return Transform.scale(
                scale: scale,
                child: _buildMovieCard(_movies[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image
            Image.network(
              movie['image'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.movie, size: 50, color: Colors.grey),
              ),
            ),

            // Bottom Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // "Newly Added" Badge
            if (movie['isNew'] == true)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A1F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Newly Added',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Movie Details & Buttons
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${movie['year']} • ${movie['languages']} • ${movie['genre']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Watchlist Button
                  _buildActionButton(
                    icon: Icons.add,
                    onTap: () {
                      // Callback for add/watchlist
                    },
                    isSmall: true,
                  ),
                  const SizedBox(width: 8),

                  // Play Button
                  _buildActionButton(
                    icon: Icons.play_arrow_rounded,
                    onTap: () {
                      // Navigate to detail page
                    },
                    backgroundColor: const Color(0xFFFF5A1F),
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isSmall = false,
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.black,
  }) {
    double size = isSmall ? 32 : 44;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: isSmall ? 20 : 28,
        ),
      ),
    );
  }
}
