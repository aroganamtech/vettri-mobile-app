import 'package:flutter/material.dart';
import '../controllers/ecommerce_controller.dart';
import '../models/product_model.dart';
import 'order_tracking_screen.dart';
import 'wishlist_screen.dart';
import 'product_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final EcommerceController controller;
  const UserProfileScreen({super.key, required this.controller});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  String _fmt(double price) {
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) {
      final s = price.toStringAsFixed(0);
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final user = ctrl.userProfile;
    final primary = Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => _showEditProfileSheet(context, ctrl, primary),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, Colors.orange.shade600],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Avatar
                      Stack(children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(child: user.avatarUrl.isNotEmpty
                              ? Image.network(user.avatarUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _defaultAvatar(user.name, primary))
                              : _defaultAvatar(user.name, primary)),
                        ),
                        Positioned(bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(Icons.camera_alt, size: 14, color: primary),
                          )),
                      ]),
                      const SizedBox(height: 10),
                      Text(user.name,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user.email,
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(user.phone,
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  )),
                ),
              ),
              bottom: TabBar(
                controller: _tabCtrl,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(icon: Icon(Icons.receipt_long_outlined, size: 20), text: 'Orders'),
                  Tab(icon: Icon(Icons.favorite_border, size: 20), text: 'Wishlist'),
                  Tab(icon: Icon(Icons.location_on_outlined, size: 20), text: 'Addresses'),
                  Tab(icon: Icon(Icons.person_outline, size: 20), text: 'Profile'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _ordersTab(context, ctrl, primary),
              _wishlistTab(context, ctrl, primary),
              _addressesTab(context, ctrl, primary),
              _profileTab(context, ctrl, primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar(String name, Color primary) {
    final initials = name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join();
    return Container(color: primary.withValues(alpha: 0.3),
      child: Center(child: Text(initials.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 26,
            fontWeight: FontWeight.bold))));
  }

  // ── Orders Tab ─────────────────────────────────────────────────────────────
  Widget _ordersTab(BuildContext ctx, EcommerceController ctrl, Color primary) {
    final orders = ctrl.orders;
    if (orders.isEmpty) {
      return _emptyState(Icons.receipt_long_outlined, 'No orders yet',
          'Your order history will appear here');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: orders.length,
      itemBuilder: (_, i) => _orderCard(ctx, orders[i], ctrl, primary),
    );
  }

  Widget _orderCard(BuildContext ctx, OrderModel order,
      EcommerceController ctrl, Color primary) {
    final statusColor = _statusColor(order.status);
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => OrderTrackingScreen(order: order, controller: ctrl))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(children: [
              Text('Order #${order.orderId}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(order.status.label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: statusColor)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Items preview
              Row(children: [
                ...order.items.take(3).map((item) => Container(
                  width: 50, height: 50,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(8),
                    child: Image.network(item.product.image, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.image,
                          color: Colors.grey.shade300))),
                )),
                if (order.items.length > 3)
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('+${order.items.length - 3}',
                      style: TextStyle(fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600))),
                  ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Text('${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const Spacer(),
                Text('₹${_fmt(order.total)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(_formatDate(order.placedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Wishlist Tab ───────────────────────────────────────────────────────────
  Widget _wishlistTab(BuildContext ctx, EcommerceController ctrl, Color primary) {
    final items = ctrl.wishlistProducts;
    if (items.isEmpty) {
      return _emptyState(Icons.favorite_border, 'No wishlisted items',
          'Save products you love for later');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      itemBuilder: (_, i) => _wishlistCard(ctx, items[i], ctrl, primary),
    );
  }

  Widget _wishlistCard(BuildContext ctx, Product p,
      EcommerceController ctrl, Color primary) {
    final inCart = ctrl.isInCart(p.id);
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: p, controller: ctrl)))
          .then((_) => setState(() {})),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Container(width: 100, height: 100, color: Colors.grey.shade50,
              child: Image.network(p.image, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.image_not_supported, color: Colors.grey.shade300)))),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (p.brand.isNotEmpty)
                Text(p.brand, style: TextStyle(color: primary, fontSize: 11,
                    fontWeight: FontWeight.w600)),
              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3)),
              const SizedBox(height: 6),
              Row(children: [
                Text('₹${_fmt(p.price)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                if (p.discountPercent > 0)
                  Text('${p.discountPercent}% off',
                    style: TextStyle(color: Colors.green.shade700, fontSize: 11)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: SizedBox(height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () { ctrl.addToCart(p); setState(() {}); },
                    icon: Icon(inCart ? Icons.check_circle : Icons.shopping_cart_outlined,
                        size: 14, color: Colors.white),
                    label: Text(inCart ? 'In Cart' : 'Add to Cart',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inCart ? Colors.green.shade600 : primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero, elevation: 0),
                  ))),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () { ctrl.toggleWishlist(p.id); setState(() {}); },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18))),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Addresses Tab ──────────────────────────────────────────────────────────
  Widget _addressesTab(BuildContext ctx, EcommerceController ctrl, Color primary) {
    final addrs = ctrl.addresses;
    return ListView(padding: const EdgeInsets.all(14), children: [
      ...addrs.map((a) => _addressManageCard(ctx, a, ctrl, primary)),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => _showAddAddressBottomSheet(ctx, ctrl, primary),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary, width: 1.5)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_location_alt_outlined, color: primary, size: 20),
            const SizedBox(width: 10),
            Text('Add New Address',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 15)),
          ]),
        ),
      ),
    ]);
  }

  Widget _addressManageCard(BuildContext ctx, UserAddress addr,
      EcommerceController ctrl, Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: addr.isDefault ? primary : Colors.grey.shade200,
            width: addr.isDefault ? 2 : 1),
        boxShadow: [if (addr.isDefault)
          BoxShadow(color: primary.withValues(alpha: 0.1), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(addr.label == 'Home' ? Icons.home_outlined
                : addr.label == 'Office' ? Icons.business_outlined
                : Icons.location_on_outlined,
                color: primary, size: 18),
            const SizedBox(width: 8),
            Text(addr.label, style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 14, color: primary)),
            if (addr.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                child: Text('Default', style: TextStyle(fontSize: 10,
                    color: Colors.green.shade700, fontWeight: FontWeight.w600))),
            ],
            const Spacer(),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade500, size: 20),
              onSelected: (v) {
                if (v == 'default') { ctrl.setDefaultAddress(addr.id); setState(() {}); }
                else if (v == 'delete') { ctrl.removeAddress(addr.id); setState(() {}); }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'default',
                    child: Row(children: [Icon(Icons.star_outline, size: 18),
                      SizedBox(width: 8), Text('Set as Default')])),
                const PopupMenuItem(value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ]),
          const SizedBox(height: 8),
          Text(addr.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(addr.phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 3),
          Text(addr.fullAddress,
              style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
        ]),
      ),
    );
  }

  // ── Profile Tab ────────────────────────────────────────────────────────────
  Widget _profileTab(BuildContext ctx, EcommerceController ctrl, Color primary) {
    final user = ctrl.userProfile;
    return ListView(padding: const EdgeInsets.all(14), children: [
      // Stats row
      Row(children: [
        _statCard(ctrl.orders.length.toString(), 'Orders', Icons.receipt_long_outlined, primary),
        const SizedBox(width: 12),
        _statCard(ctrl.wishlist.length.toString(), 'Wishlist', Icons.favorite_border, Colors.red),
        const SizedBox(width: 12),
        _statCard(ctrl.addresses.length.toString(), 'Addresses',
            Icons.location_on_outlined, Colors.orange),
      ]),
      const SizedBox(height: 20),

      // Personal Details
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: Column(children: [
          _profileListTile(Icons.person_outline, 'Full Name', user.name, primary),
          _divider(),
          _profileListTile(Icons.email_outlined, 'Email', user.email, primary),
          _divider(),
          _profileListTile(Icons.phone_outlined, 'Phone', user.phone, primary),
        ]),
      ),
      const SizedBox(height: 20),

      // Settings Section
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: Column(children: [
          _settingTile(Icons.notifications_outlined, 'Notifications', primary, () {}),
          _divider(),
          _settingTile(Icons.security_outlined, 'Security & Privacy', primary, () {}),
          _divider(),
          _settingTile(Icons.help_outline, 'Help & Support', primary, () {}),
          _divider(),
          _settingTile(Icons.info_outline, 'About', primary, () {}),
        ]),
      ),
      const SizedBox(height: 20),

      // Logout
      SizedBox(width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.logout, color: Colors.red.shade600, size: 18),
          label: Text('Sign Out', style: TextStyle(color: Colors.red.shade600,
              fontWeight: FontWeight.w600, fontSize: 15)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14)),
        )),
      const SizedBox(height: 30),
    ]);
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ]),
    ));
  }

  Widget _profileListTile(IconData icon, String label, String value, Color primary) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: primary, size: 18)),
      title: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      subtitle: Text(value, style: const TextStyle(fontSize: 13,
          fontWeight: FontWeight.w500, color: Colors.black87)),
      trailing: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
    );
  }

  Widget _settingTile(IconData icon, String title, Color primary, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: Colors.grey.shade600)),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _divider() => Divider(height: 1, indent: 56, endIndent: 16,
      color: Colors.grey.shade100);

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 80, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
          color: Colors.grey.shade600)),
      const SizedBox(height: 8),
      Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
    ]));
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed: return Colors.blue.shade600;
      case OrderStatus.processing: return Colors.orange.shade600;
      case OrderStatus.shipped: return Colors.purple.shade600;
      case OrderStatus.outForDelivery: return Colors.deepOrange.shade600;
      case OrderStatus.delivered: return Colors.green.shade600;
    }
  }

  String _formatDate(DateTime d) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  void _showEditProfileSheet(BuildContext ctx, EcommerceController ctrl, Color primary) {
    final nameCtrl = TextEditingController(text: ctrl.userProfile.name);
    final emailCtrl = TextEditingController(text: ctrl.userProfile.email);
    final phoneCtrl = TextEditingController(text: ctrl.userProfile.phone);

    showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ]),
          const SizedBox(height: 16),
          _addressFieldLocal(nameCtrl, 'Full Name', Icons.person_outline),
          const SizedBox(height: 12),
          _addressFieldLocal(emailCtrl, 'Email', Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _addressFieldLocal(phoneCtrl, 'Phone', Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0),
              onPressed: () {
                ctrl.userProfile.name = nameCtrl.text;
                ctrl.userProfile.email = emailCtrl.text;
                ctrl.userProfile.phone = phoneCtrl.text;
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Save Changes', style: TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold)),
            )),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _addressFieldLocal(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl, keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
        filled: true, fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  void _showAddAddressBottomSheet(BuildContext ctx, EcommerceController ctrl, Color primary) {
    final labelCtrl = TextEditingController(text: 'Home');
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final line1Ctrl = TextEditingController();
    final line2Ctrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController();
    bool setDefault = false;

    showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: SingleChildScrollView(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                const Text('Add New Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ]),
              const SizedBox(height: 14),
              Row(children: ['Home', 'Office', 'Other'].map((t) {
                final sel = labelCtrl.text == t;
                return GestureDetector(
                  onTap: () => setSheet(() => labelCtrl.text = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? primary : Colors.grey.shade300)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(t == 'Home' ? Icons.home_outlined
                          : t == 'Office' ? Icons.business_outlined
                          : Icons.location_on_outlined,
                          size: 15, color: sel ? Colors.white : Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : Colors.grey.shade700)),
                    ]),
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),
              _addressFieldLocal(nameCtrl, 'Full Name', Icons.person_outline),
              const SizedBox(height: 10),
              _addressFieldLocal(phoneCtrl, 'Phone', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _addressFieldLocal(line1Ctrl, 'Address Line 1', Icons.home_outlined),
              const SizedBox(height: 10),
              _addressFieldLocal(line2Ctrl, 'Address Line 2 (Optional)', Icons.location_on_outlined),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _addressFieldLocal(cityCtrl, 'City', Icons.location_city)),
                const SizedBox(width: 12),
                Expanded(child: _addressFieldLocal(pincodeCtrl, 'Pincode', Icons.pin_outlined,
                    keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 10),
              _addressFieldLocal(stateCtrl, 'State', Icons.map_outlined),
              Row(children: [
                Switch(value: setDefault, activeColor: primary,
                    onChanged: (v) => setSheet(() => setDefault = v)),
                const Text('Set as default address', style: TextStyle(fontSize: 14)),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || line1Ctrl.text.isEmpty) return;
                    ctrl.addAddress(UserAddress(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      label: labelCtrl.text, name: nameCtrl.text,
                      phone: phoneCtrl.text, line1: line1Ctrl.text,
                      line2: line2Ctrl.text, city: cityCtrl.text,
                      state: stateCtrl.text, pincode: pincodeCtrl.text,
                      isDefault: setDefault));
                    setState(() {});
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Address', style: TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.bold)),
                )),
              const SizedBox(height: 24),
            ],
          )),
        ),
      ),
    );
  }
}
