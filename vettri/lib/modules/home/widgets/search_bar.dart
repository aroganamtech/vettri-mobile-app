import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 22),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search for products, food & movies...',
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
          Container(
            height: 20,
            width: 1,
            color: Color.fromRGBO(158, 158, 158, 0.3),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const Icon(Icons.location_on, color: Colors.grey, size: 18),
          const SizedBox(width: 4),
          const Text(
            'Chennai',
            style: TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}
