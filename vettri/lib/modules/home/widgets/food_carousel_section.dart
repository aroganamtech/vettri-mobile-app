import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodRestaurant {
  final String name;
  final String imageUrl;
  final String rating;
  final String time;
  final String cuisine;
  final String location;
  final String offer;

  FoodRestaurant({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.time,
    required this.cuisine,
    required this.location,
    required this.offer,
  });
}

class FoodCarouselSection extends StatefulWidget {
  const FoodCarouselSection({super.key});

  @override
  State<FoodCarouselSection> createState() => _FoodCarouselSectionState();
}

class _FoodCarouselSectionState extends State<FoodCarouselSection> {
  final List<FoodRestaurant> restaurants = [
    FoodRestaurant(
      name: "The Pizza Project",
      imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80",
      rating: "4.5",
      time: "20-25 mins",
      cuisine: "Italian • Pizza • Pasta",
      location: "Adyar, Chennai",
      offer: "ITEMS AT ₹149",
    ),
    FoodRestaurant(
      name: "Burger King",
      imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80",
      rating: "4.2",
      time: "15-20 mins",
      cuisine: "American • Burgers",
      location: "Velachery, Chennai",
      offer: "60% OFF UP TO ₹120",
    ),
    FoodRestaurant(
      name: "Biryani Bhai",
      imageUrl: "https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=500&q=80",
      rating: "4.6",
      time: "30-35 mins",
      cuisine: "Indian • Biryani • Mughlai",
      location: "T. Nagar, Chennai",
      offer: "FREE DEL ABOVE ₹499",
    ),
    FoodRestaurant(
      name: "Sushi World",
      imageUrl: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80",
      rating: "4.8",
      time: "40-45 mins",
      cuisine: "Japanese • Sushi",
      location: "Nungambakkam, Chennai",
      offer: "₹100 OFF ON FIRST ORDER",
    ),
    FoodRestaurant(
      name: "Taco Bell",
      imageUrl: "https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=500&q=80",
      rating: "4.1",
      time: "20-25 mins",
      cuisine: "Mexican • Tacos",
      location: "Mylapore, Chennai",
      offer: "ITEMS AT ₹99",
    ),
    FoodRestaurant(
      name: "Pasta Paradise",
      imageUrl: "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=500&q=80",
      rating: "4.4",
      time: "25-30 mins",
      cuisine: "Italian • Pasta",
      location: "Anna Nagar, Chennai",
      offer: "FLAT ₹150 OFF",
    ),
    FoodRestaurant(
      name: "Wok to Walk",
      imageUrl: "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=500&q=80",
      rating: "4.3",
      time: "15-20 mins",
      cuisine: "Asian • Noodles",
      location: "Besant Nagar, Chennai",
      offer: "20% OFF ABOVE ₹599",
    ),
    FoodRestaurant(
      name: "Dessert Heaven",
      imageUrl: "https://images.unsplash.com/photo-1551024506-0bccd828d307?w=500&q=80",
      rating: "4.7",
      time: "10-15 mins",
      cuisine: "Desserts • Ice Cream",
      location: "Egmore, Chennai",
      offer: "BUY 1 GET 1 FREE",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Popular Near You",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                "Handpicked restaurants",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: restaurants.length + 1,
            itemBuilder: (context, index) {
              if (index < restaurants.length) {
                return _buildRestaurantCard(restaurants[index]);
              } else {
                return _buildShowMoreCard();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(FoodRestaurant restaurant) {
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    child: Image.network(
                      restaurant.imageUrl,
                      height: 160,
                      width: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Text(
                      restaurant.offer,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.green, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "${restaurant.rating} • ${restaurant.time}",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      restaurant.cuisine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      restaurant.location,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowMoreCard() {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[200]!, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
              ),
              const SizedBox(height: 12),
              Text(
                "View All",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
