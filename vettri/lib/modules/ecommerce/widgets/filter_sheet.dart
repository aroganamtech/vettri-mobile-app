import 'package:flutter/material.dart';
import '../controllers/ecommerce_controller.dart';

class FilterSheet extends StatefulWidget {
  final EcommerceController controller;
  const FilterSheet({super.key, required this.controller});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late double _minPrice;
  late double _maxPrice;
  late double _minRating;
  late int _minDiscount;
  late bool _inStockOnly;

  static const double _absMax = 200000;

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _minPrice = c.minPrice;
    _maxPrice = c.maxPrice == double.infinity ? _absMax : c.maxPrice;
    _minRating = c.minRating;
    _minDiscount = c.minDiscount;
    _inStockOnly = c.inStockOnly;
  }

  String _fmt(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) {
      final s = v.toStringAsFixed(0);
      return '₹${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(
          margin: const EdgeInsets.only(top: 10),
          width: 36, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2)),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() {
                _minPrice = 0; _maxPrice = _absMax;
                _minRating = 0; _minDiscount = 0; _inStockOnly = false;
              }),
              child: Text('Clear All', style: TextStyle(color: primary, fontSize: 13)),
            ),
          ]),
        ),
        const Divider(height: 1),
        Flexible(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Price Range
            _sectionTitle('Price Range'),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _priceChip(_fmt(_minPrice)),
              Text('to', style: TextStyle(color: Colors.grey.shade500)),
              _priceChip(_fmt(_maxPrice)),
            ]),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0, max: _absMax, divisions: 40,
              activeColor: primary, inactiveColor: Colors.grey.shade200,
              onChanged: (v) => setState(() { _minPrice = v.start; _maxPrice = v.end; }),
            ),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _quickPrice('Under ₹1K', 0, 1000, primary),
              _quickPrice('₹1K–10K', 1000, 10000, primary),
              _quickPrice('₹10K–50K', 10000, 50000, primary),
              _quickPrice('₹50K+', 50000, _absMax, primary),
            ]),
            const SizedBox(height: 20),

            // Rating
            _sectionTitle('Minimum Rating'),
            const SizedBox(height: 10),
            Row(children: [4, 3, 2, 1].map((r) {
              final sel = _minRating >= r;
              return GestureDetector(
                onTap: () => setState(() => _minRating = r == _minRating ? 0 : r.toDouble()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: sel ? primary : Colors.grey.shade300),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.star, size: 14,
                        color: sel ? Colors.white : Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text('$r+', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : Colors.grey.shade700)),
                  ]),
                ),
              );
            }).toList()),
            const SizedBox(height: 20),

            // Discount
            _sectionTitle('Minimum Discount'),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [10, 20, 30, 40, 50].map((d) {
              final sel = _minDiscount == d;
              return GestureDetector(
                onTap: () => setState(() => _minDiscount = sel ? 0 : d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? Colors.red.shade600 : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: sel ? Colors.red.shade600 : Colors.grey.shade300),
                  ),
                  child: Text('$d%+', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : Colors.grey.shade700)),
                ),
              );
            }).toList()),
            const SizedBox(height: 20),

            // Availability
            _sectionTitle('Availability'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('In Stock Only', style: TextStyle(fontSize: 14)),
              value: _inStockOnly,
              activeColor: primary,
              onChanged: (v) => setState(() => _inStockOnly = v),
            ),
          ]),
        )),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.controller.setFilters(
                  minPrice: _minPrice > 0 ? _minPrice : null,
                  maxPrice: _maxPrice < _absMax ? _maxPrice : null,
                  minRating: _minRating,
                  minDiscount: _minDiscount,
                  inStockOnly: _inStockOnly,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Apply Filters', style: TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));

  Widget _priceChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _quickPrice(String label, double min, double max, Color primary) {
    final sel = _minPrice >= min && _maxPrice <= max;
    return GestureDetector(
      onTap: () => setState(() { _minPrice = min; _maxPrice = max; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? primary : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: sel ? primary : Colors.grey.shade700)),
      ),
    );
  }
}
