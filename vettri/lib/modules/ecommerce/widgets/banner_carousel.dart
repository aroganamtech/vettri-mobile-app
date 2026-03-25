import 'dart:async';
import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> images;
  const BannerCarousel({super.key, required this.images});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _ctrl = PageController();
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final next = (_current + 1) % widget.images.length;
      _ctrl.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  widget.images[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _current == i ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
