import 'package:flutter/material.dart';

class DealItem {
  final String title;
  final String subtitle;
  final String ctaText;
  final IconData icon;
  final List<Color> gradientColors;
  final String imageUrl;

  const DealItem({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.icon,
    required this.gradientColors,
    required this.imageUrl,
  });
}

