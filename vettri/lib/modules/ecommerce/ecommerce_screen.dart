import 'package:flutter/material.dart';
import 'controllers/ecommerce_controller.dart';
import 'data/product_data.dart';
import 'screens/cart_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/user_profile_screen.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_chip.dart';
import 'widgets/product_grid.dart';

class EcommerceScreen extends StatefulWidget {
  const EcommerceScreen({super.key});

  @override
  State<EcommerceScreen> createState() => _EcommerceScreenState();
}

class _EcommerceScreenState extends State<EcommerceScreen> {
  final EcommerceController _ctrl = EcommerceController();
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showSearch = false;

  // Icons for categories — no emojis
  static const _categoryIcons = <String, IconData>{
    'All': Icons.grid_view_rounded,
    'Mobiles': Icons.smartphone,
    'Electronics': Icons.laptop_mac,
    'Fashion': Icons.checkroom,
    'Home': Icons.home_outlined,
    'Beauty': Icons.face_retouching_natural,
    'Sports': Icons.sports_basketball,
    'Books': Icons.menu_book,
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final primary = Theme.of(context).primaryColor;
        final filtered = _ctrl.filteredProducts(ProductData.allProducts);

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: _buildAppBar(context, primary),
          body: Column(
            children: [
              if (_showSearch) _buildSearchBar(primary),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      BannerCarousel(images: ProductData.bannerImages),
                      const SizedBox(height: 16),
                      _buildFlashDealStrip(primary),
                      const SizedBox(height: 16),
                      _buildCategoryRow(primary),
                      const SizedBox(height: 12),
                      _buildSortRow(context, primary),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(children: [
                          Text(
                            '${filtered.length} result${filtered.length != 1 ? 's' : ''} in "${_ctrl.selectedCategory}"',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                          if (_ctrl.hasActiveFilters) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: () { _ctrl.resetFilters(); _searchCtrl.clear(); },
                              child: Text('Clear filters',
                                style: TextStyle(fontSize: 12, color: primary,
                                    fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ]),
                      ),
                      const SizedBox(height: 10),
                      ProductGrid(products: filtered, controller: _ctrl),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Color primary) {
    return AppBar(
      backgroundColor: primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: () => setState(() => _showSearch = !_showSearch),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Icon(Icons.search, color: Colors.grey.shade400, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(
              _ctrl.searchQuery.isEmpty ? 'Search products, brands...' : _ctrl.searchQuery,
              style: TextStyle(
                color: _ctrl.searchQuery.isEmpty ? Colors.grey.shade400 : Colors.black87,
                fontSize: 13),
              overflow: TextOverflow.ellipsis,
            )),
          ]),
        ),
      ),
      actions: [
        // Profile
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => UserProfileScreen(controller: _ctrl),
          )).then((_) => setState(() {})),
        ),
        // Wishlist
        Stack(children: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => WishlistScreen(controller: _ctrl),
            )).then((_) => setState(() {})),
          ),
          if (_ctrl.wishlist.isNotEmpty)
            Positioned(right: 4, top: 4, child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text(_ctrl.wishlist.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            )),
        ]),
        // Cart
        Stack(clipBehavior: Clip.none, children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => CartScreen(controller: _ctrl),
            )).then((_) => setState(() {})),
          ),
          if (_ctrl.cartCount > 0)
            Positioned(right: 4, top: 4, child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
              child: Text(_ctrl.cartCount.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
            )),
        ]),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar(Color primary) {
    return Container(
      color: primary,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        onChanged: _ctrl.setSearch,
        decoration: InputDecoration(
          hintText: 'Search products, brands, categories...',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: _ctrl.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () { _searchCtrl.clear(); _ctrl.setSearch(''); })
              : null,
        ),
      ),
    );
  }

  Widget _buildFlashDealStrip(Color primary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, Colors.orange.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const Icon(Icons.bolt, color: Colors.yellow, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Flash Sale — Up to 55% OFF',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text('Limited time deals on top brands',
              style: TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Text('Shop Now',
            style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ]),
    );
  }

  Widget _buildCategoryRow(Color primary) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ProductData.categories.length,
        itemBuilder: (_, i) {
          final cat = ProductData.categories[i];
          return CategoryChip(
            label: cat,
            icon: _categoryIcons[cat] ?? Icons.category,
            isSelected: _ctrl.selectedCategory == cat,
            onTap: () => _ctrl.setCategory(cat),
          );
        },
      ),
    );
  }

  Widget _buildSortRow(BuildContext context, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showSortSheet(context, primary),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(children: [
                Icon(Icons.sort, size: 17, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(child: Text('Sort: ${_ctrl.sortBy}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis)),
                Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade500),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _showFilterSheet(context, primary),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _ctrl.hasActiveFilters ? primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _ctrl.hasActiveFilters ? primary : Colors.grey.shade200),
            ),
            child: Row(children: [
              Icon(Icons.tune, size: 17,
                  color: _ctrl.hasActiveFilters ? Colors.white : Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(_ctrl.hasActiveFilters ? 'Filtered' : 'Filter',
                style: TextStyle(fontSize: 12,
                    color: _ctrl.hasActiveFilters ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ]),
    );
  }

  void _showSortSheet(BuildContext context, Color primary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text('Sort by', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
            ...ProductData.sortOptions.map((opt) => ListTile(
              dense: true,
              title: Text(opt, style: const TextStyle(fontSize: 14)),
              leading: Radio<String>(
                value: opt, groupValue: _ctrl.sortBy,
                activeColor: primary,
                onChanged: (v) { _ctrl.setSortBy(v!); Navigator.pop(context); },
              ),
              onTap: () { _ctrl.setSortBy(opt); Navigator.pop(context); },
            )),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, Color primary) {
    double tempMin = _ctrl.minPrice;
    double tempMax = _ctrl.maxPrice == double.infinity ? 200000 : _ctrl.maxPrice;
    double tempRating = _ctrl.minRating;
    int tempDiscount = _ctrl.minDiscount;
    bool tempInStock = _ctrl.inStockOnly;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (_, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollCtrl) => Column(children: [
            // Handle
            Center(child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(children: [
                const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () => setSheet(() {
                    tempMin = 0; tempMax = 200000; tempRating = 0;
                    tempDiscount = 0; tempInStock = false;
                  }),
                  child: Text('Clear All', style: TextStyle(color: primary)),
                ),
              ]),
            ),
            const Divider(height: 1),
            Expanded(child: SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  _filterSection('Price Range'),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _filterValueChip('₹${tempMin.toInt()}'),
                    Text('to', style: TextStyle(color: Colors.grey.shade500)),
                    _filterValueChip('₹${tempMax.toInt()}${tempMax >= 200000 ? '+' : ''}'),
                  ]),
                  RangeSlider(
                    values: RangeValues(tempMin, tempMax),
                    min: 0, max: 200000, divisions: 40,
                    activeColor: primary,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (v) => setSheet(() { tempMin = v.start; tempMax = v.end; }),
                  ),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _quickPriceBtn('Under ₹1K', 0, 1000, tempMin, tempMax, primary, setSheet),
                    _quickPriceBtn('₹1K–10K', 1000, 10000, tempMin, tempMax, primary, setSheet),
                    _quickPriceBtn('₹10K–50K', 10000, 50000, tempMin, tempMax, primary, setSheet),
                    _quickPriceBtn('₹50K+', 50000, 200000, tempMin, tempMax, primary, setSheet),
                  ]),
                  const SizedBox(height: 24),

                  // Rating
                  _filterSection('Minimum Rating'),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [1, 2, 3, 4].map((r) {
                    final sel = tempRating == r.toDouble();
                    return GestureDetector(
                      onTap: () => setSheet(() => tempRating = sel ? 0 : r.toDouble()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? primary : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: sel ? primary : Colors.grey.shade300),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.star, size: 14,
                              color: sel ? Colors.white : Colors.amber.shade600),
                          const SizedBox(width: 4),
                          Text('$r+', style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : Colors.grey.shade700)),
                        ]),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 24),

                  // Discount
                  _filterSection('Minimum Discount'),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [10, 20, 30, 40, 50].map((d) {
                    final sel = tempDiscount == d;
                    return GestureDetector(
                      onTap: () => setSheet(() => tempDiscount = sel ? 0 : d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? Colors.red.shade600 : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: sel ? Colors.red.shade600 : Colors.grey.shade300),
                        ),
                        child: Text('$d%+', style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : Colors.grey.shade700)),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 24),

                  // In Stock
                  _filterSection('Availability'),
                  Row(children: [
                    Switch(value: tempInStock, activeColor: primary,
                        onChanged: (v) => setSheet(() => tempInStock = v)),
                    const SizedBox(width: 8),
                    const Text('In Stock Only', style: TextStyle(fontSize: 14)),
                  ]),
                  const SizedBox(height: 16),
                ],
              ),
            )),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    _ctrl.setFilters(
                      minPrice: tempMin > 0 ? tempMin : null,
                      maxPrice: tempMax < 200000 ? tempMax : null,
                      minRating: tempRating,
                      minDiscount: tempDiscount,
                      inStockOnly: tempInStock,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters',
                    style: TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _filterSection(String title) => Text(title,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));

  Widget _filterValueChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _quickPriceBtn(String label, double min, double max,
      double curMin, double curMax, Color primary, StateSetter setSheet) {
    final sel = curMin >= min && curMax <= max;
    return GestureDetector(
      onTap: () => setSheet(() { }),
      child: GestureDetector(
        onTap: () => setSheet(() {}),
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
      ),
    );
  }
}
