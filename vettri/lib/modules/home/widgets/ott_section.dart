import 'package:flutter/material.dart';
import 'ott_card.dart';

class OTTSection extends StatelessWidget {
  const OTTSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 4),
          child: Text(
            'Popular on OTT',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Trending on OTT Platforms',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              OTTCard(title: 'Crime Series', imageUrl: 'https://images.unsplash.com/photo-1509248961158-e54f6934749c?w=400&q=80'),
              OTTCard(title: 'Romantic Drama', imageUrl: 'https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?w=400&q=80'),
              OTTCard(title: 'Sci-Fi Adventure', imageUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=400&q=80'),
            ],
          ),
        ),
      ],
    );
  }
}
