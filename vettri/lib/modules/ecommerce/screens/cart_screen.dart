import 'package:flutter/material.dart';
import '../controllers/ecommerce_controller.dart';
import '../models/product_model.dart';
import 'order_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  final EcommerceController controller;
  const CartScreen({super.key, required this.controller});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _step = 0; // 0=cart 1=address 2=payment 3=review
  String? _selectedAddressId;
  String _selectedPayment = 'UPI';
  String _upiId = 'user@paytm';
  bool _placingOrder = false;

  // Card fields
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedAddressId = widget.controller.defaultAddress?.id;
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
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

  UserAddress? get _selectedAddress => widget.controller.addresses
      .cast<UserAddress?>()
      .firstWhere((a) => a?.id == _selectedAddressId, orElse: () => null);

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final items = ctrl.cartItems;
    final primary = Theme.of(context).primaryColor;
    final subtotal = ctrl.cartTotal;
    final savings = items.fold<double>(
        0, (s, i) => s + (i.product.originalPrice - i.product.price) * i.quantity);

    return WillPopScope(
      onWillPop: () async {
        if (_step > 0) { setState(() => _step--); return false; }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: _buildAppBar(items.length, primary),
        body: items.isEmpty && _step == 0
            ? _emptyCart(context, primary)
            : _step == 0
                ? _cartBody(context, items, ctrl, primary, subtotal, savings)
                : _step == 1
                    ? _addressBody(context, ctrl, primary)
                    : _step == 2
                        ? _paymentBody(context, primary)
                        : _reviewBody(context, items, ctrl, primary, subtotal, savings),
        bottomNavigationBar: (items.isEmpty && _step == 0)
            ? null
            : _bottomBar(context, ctrl, primary, subtotal, savings),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int count, Color primary) {
    const titles = ['Shopping Cart', 'Delivery Address', 'Payment', 'Review Order'];
    return AppBar(
      backgroundColor: primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () { if (_step > 0) setState(() => _step--); else Navigator.pop(context); },
      ),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titles[_step],
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        if (_step == 0)
          Text('$count item${count != 1 ? 's' : ''}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
      bottom: _step > 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: _stepIndicator(primary))
          : null,
    );
  }

  Widget _stepIndicator(Color primary) {
    final steps = ['Address', 'Payment', 'Review'];
    return Container(
      color: primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(child: Container(height: 2,
              color: (_step - 1) > i ~/ 2 ? Colors.white : Colors.white38));
        }
        final si = i ~/ 2 + 1;
        final active = _step >= si;
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
                color: active ? Colors.white : Colors.white24, shape: BoxShape.circle),
            child: Center(child: active
                ? Icon(Icons.check, size: 14, color: primary)
                : Text('$si', style: const TextStyle(color: Colors.white,
                    fontSize: 11, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 2),
          Text(steps[si - 1], style: TextStyle(
              color: active ? Colors.white : Colors.white60, fontSize: 9,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ]);
      })),
    );
  }

  // ── Step 0: Cart ───────────────────────────────────────────────────────────
  Widget _cartBody(BuildContext ctx, List<CartItem> items,
      EcommerceController ctrl, Color primary, double subtotal, double savings) {
    return ListView(padding: const EdgeInsets.all(12), children: [
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(children: [
          Icon(Icons.local_shipping, color: Colors.green.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('FREE delivery on this order! Arrives tomorrow.',
            style: TextStyle(color: Colors.green.shade800, fontSize: 12,
                fontWeight: FontWeight.w500))),
        ]),
      ),
      ...items.map((item) => _cartItemCard(ctx, item, ctrl, primary)),
      const SizedBox(height: 12),
      _priceSummaryCard(items, subtotal, savings),
      const SizedBox(height: 80),
    ]);
  }

  Widget _cartItemCard(BuildContext ctx, CartItem item,
      EcommerceController ctrl, Color primary) {
    final p = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Padding(padding: const EdgeInsets.all(12), child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10),
            child: Container(width: 88, height: 88, color: Colors.grey.shade50,
              child: Image.network(p.image, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported,
                      color: Colors.grey.shade300)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (p.brand.isNotEmpty)
              Text(p.brand, style: TextStyle(color: primary, fontSize: 11,
                  fontWeight: FontWeight.w600)),
            Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3)),
            const SizedBox(height: 6),
            Row(children: [
              Text('₹${_fmt(p.price)}', style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              if (p.originalPrice > p.price)
                Text('₹${_fmt(p.originalPrice)}', style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade400,
                    decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 6),
              if (p.discountPercent > 0)
                Text('${p.discountPercent}% off', style: TextStyle(
                    color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _qtyBtn(Icons.remove, () { ctrl.updateQuantity(p.id, item.quantity - 1); setState(() {}); }),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  _qtyBtn(Icons.add, () { ctrl.updateQuantity(p.id, item.quantity + 1); setState(() {}); }),
                ]),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () { ctrl.removeFromCart(p.id); setState(() {}); },
                child: Row(children: [
                  Icon(Icons.delete_outline, color: Colors.red.shade300, size: 16),
                  const SizedBox(width: 3),
                  Text('Remove', style: TextStyle(color: Colors.red.shade400,
                      fontSize: 12, fontWeight: FontWeight.w500)),
                ]),
              ),
            ]),
          ])),
        ],
      )),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: Colors.grey.shade700)));

  Widget _priceSummaryCard(List<CartItem> items, double subtotal, double savings) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Price Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 14),
        _priceRow('Price (${items.length} item${items.length != 1 ? 's' : ''})',
            '₹${_fmt(subtotal + savings)}'),
        const SizedBox(height: 8),
        _priceRow('Discount', '-₹${_fmt(savings)}', valueColor: Colors.green.shade700),
        const SizedBox(height: 8),
        _priceRow('Delivery Charges', 'FREE', valueColor: Colors.green.shade700),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
        _priceRow('Total Amount', '₹${_fmt(subtotal)}', bold: true, fontSize: 16),
        if (savings > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200)),
            child: Row(children: [
              Icon(Icons.celebration, color: Colors.green.shade700, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('You will save ₹${_fmt(savings)} on this order!',
                style: TextStyle(color: Colors.green.shade800,
                    fontWeight: FontWeight.w600, fontSize: 13))),
            ]),
          ),
        ],
      ]),
    );
  }

  // ── Step 1: Address ────────────────────────────────────────────────────────
  Widget _addressBody(BuildContext ctx, EcommerceController ctrl, Color primary) {
    final addrs = ctrl.addresses;
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Choose Delivery Address',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 14),
      ...addrs.map((a) => _addressCard(a, primary)),
      const SizedBox(height: 12),
      // Add New Address button
      GestureDetector(
        onTap: () => _showAddAddressSheet(ctx, ctrl, primary),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary, width: 1.5),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_location_alt_outlined, color: primary, size: 20),
            const SizedBox(width: 10),
            Text('Add New Address',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 15)),
          ]),
        ),
      ),
      const SizedBox(height: 80),
    ]);
  }

  Widget _addressCard(UserAddress addr, Color primary) {
    final selected = _selectedAddressId == addr.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressId = addr.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? primary : Colors.grey.shade200,
              width: selected ? 2 : 1),
          boxShadow: [if (selected)
            BoxShadow(color: primary.withValues(alpha: 0.12), blurRadius: 8)],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Radio<String>(
            value: addr.id,
            groupValue: _selectedAddressId,
            activeColor: primary,
            onChanged: (v) => setState(() => _selectedAddressId = v!),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4)),
                child: Text(addr.label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                      color: selected ? primary : Colors.grey.shade600)),
              ),
              if (addr.isDefault) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Text('Default', style: TextStyle(fontSize: 10,
                      color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                ),
              ],
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, color: primary, size: 16),
              ],
            ]),
            const SizedBox(height: 6),
            Text(addr.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(addr.phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 3),
            Text(addr.fullAddress,
              style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.black87)),
          ])),
        ]),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext ctx, EcommerceController ctrl, Color primary) {
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
      context: ctx,
      isScrollControlled: true,
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
              const SizedBox(height: 16),
              // Address type
              Row(children: ['Home', 'Office', 'Other'].map((t) {
                final sel = labelCtrl.text == t;
                return GestureDetector(
                  onTap: () { setSheet(() => labelCtrl.text = t); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? primary : Colors.grey.shade300),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(t == 'Home' ? Icons.home_outlined
                          : t == 'Office' ? Icons.business_outlined : Icons.location_on_outlined,
                          size: 16, color: sel ? Colors.white : Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : Colors.grey.shade700)),
                    ]),
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),
              _addressField(nameCtrl, 'Full Name', Icons.person_outline),
              _addressField(phoneCtrl, 'Phone Number', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              _addressField(line1Ctrl, 'Address Line 1', Icons.home_outlined),
              _addressField(line2Ctrl, 'Address Line 2 (Optional)', Icons.location_on_outlined),
              Row(children: [
                Expanded(child: _addressField(cityCtrl, 'City', Icons.location_city)),
                const SizedBox(width: 12),
                Expanded(child: _addressField(pincodeCtrl, 'Pincode', Icons.pin_outlined,
                    keyboardType: TextInputType.number)),
              ]),
              _addressField(stateCtrl, 'State', Icons.map_outlined),
              Row(children: [
                Switch(value: setDefault, activeColor: primary,
                    onChanged: (v) => setSheet(() => setDefault = v)),
                const Text('Set as default address', style: TextStyle(fontSize: 14)),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || line1Ctrl.text.isEmpty ||
                        cityCtrl.text.isEmpty || pincodeCtrl.text.isEmpty) return;
                    final newAddr = UserAddress(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      label: labelCtrl.text,
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      line1: line1Ctrl.text,
                      line2: line2Ctrl.text,
                      city: cityCtrl.text,
                      state: stateCtrl.text,
                      pincode: pincodeCtrl.text,
                      isDefault: setDefault,
                    );
                    ctrl.addAddress(newAddr);
                    setState(() => _selectedAddressId = newAddr.id);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Address',
                      style: TextStyle(color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          )),
        ),
      ),
    );
  }

  Widget _addressField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  // ── Step 2: Payment ────────────────────────────────────────────────────────
  Widget _paymentBody(BuildContext ctx, Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Choose Payment Method',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 14),

        // UPI
        _paymentTile('UPI', Icons.account_balance_wallet_outlined,
            'PhonePe, GPay, Paytm & more', primary,
            child: _selectedPayment == 'UPI'
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: TextField(
                      onChanged: (v) => _upiId = v,
                      decoration: InputDecoration(
                        labelText: 'UPI ID',
                        hintText: 'example@paytm',
                        prefixIcon: Icon(Icons.tag, size: 18, color: Colors.grey.shade500),
                        filled: true, fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200)),
                      ),
                    ))
                : null),

        // Credit/Debit Card
        _paymentTile('Credit / Debit Card', Icons.credit_card_outlined,
            'Visa, Mastercard, RuPay', primary,
            child: _selectedPayment == 'Credit / Debit Card'
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Column(children: [
                      _cardField(_cardNumberCtrl, 'Card Number', Icons.credit_card,
                          TextInputType.number),
                      const SizedBox(height: 10),
                      _cardField(_cardNameCtrl, 'Name on Card', Icons.person_outline),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _cardField(_cardExpiryCtrl, 'MM/YY',
                            Icons.calendar_today_outlined, TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _cardField(_cardCvvCtrl, 'CVV',
                            Icons.lock_outline, TextInputType.number)),
                      ]),
                    ]))
                : null),

        // Net Banking
        _paymentTile('Net Banking', Icons.account_balance_outlined,
            'All major banks supported', primary),

        // Wallets
        _paymentTile('Wallets', Icons.wallet_outlined,
            'Paytm, PhonePe, Amazon Pay', primary),

        // EMI
        _paymentTile('EMI', Icons.calendar_month_outlined,
            'No Cost EMI available on select cards', primary),

        // COD
        _paymentTile('Cash on Delivery', Icons.money_outlined,
            'Pay when your order arrives', primary),

        // Security badge
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200)),
          child: Row(children: [
            Icon(Icons.security, color: Colors.green.shade700, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('100% Secure Payments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                    color: Colors.green.shade800)),
              Text('All transactions are encrypted and secure',
                style: TextStyle(fontSize: 12, color: Colors.green.shade600)),
            ])),
          ]),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _paymentTile(String method, IconData icon, String subtitle, Color primary,
      {Widget? child}) {
    final selected = _selectedPayment == method;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: selected ? primary : Colors.grey.shade200, width: selected ? 2 : 1),
        boxShadow: [if (selected)
          BoxShadow(color: primary.withValues(alpha: 0.1), blurRadius: 8)],
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _selectedPayment = method),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Radio<String>(
                value: method, groupValue: _selectedPayment, activeColor: primary,
                onChanged: (v) => setState(() => _selectedPayment = v!),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected ? primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: selected ? primary : Colors.grey.shade500, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(method, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ])),
              if (selected)
                Icon(Icons.check_circle, color: primary, size: 20),
            ]),
          ),
        ),
        if (child != null && selected) child,
      ]),
    );
  }

  Widget _cardField(TextEditingController ctrl, String label, IconData icon,
      [TextInputType? type]) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        filled: true, fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  // ── Step 3: Review ─────────────────────────────────────────────────────────
  Widget _reviewBody(BuildContext ctx, List<CartItem> items,
      EcommerceController ctrl, Color primary, double subtotal, double savings) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Order Items
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Order Summary (${items.length} item${items.length != 1 ? 's' : ''})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(8),
                child: Container(width: 54, height: 54, color: Colors.grey.shade50,
                  child: Image.network(item.product.image, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text('Qty: ${item.quantity}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ])),
              Text('₹${_fmt(item.totalPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          )),
        ]),
      ),
      const SizedBox(height: 12),

      // Delivery address
      _reviewInfoTile(icon: Icons.location_on, color: Colors.orange.shade600,
          title: 'Delivering to ${_selectedAddress?.label ?? ""}',
          subtitle: _selectedAddress?.fullAddress ?? '', primary: primary),
      const SizedBox(height: 10),

      // Payment
      _reviewInfoTile(icon: Icons.payment, color: Colors.blue.shade600,
          title: _selectedPayment,
          subtitle: _selectedPayment == 'UPI' ? 'UPI ID: $_upiId' : 'Secure payment',
          primary: primary),
      const SizedBox(height: 10),

      // Delivery
      _reviewInfoTile(icon: Icons.local_shipping_outlined, color: Colors.green.shade600,
          title: 'Standard Delivery',
          subtitle: 'FREE · Estimated delivery by tomorrow', primary: primary),
      const SizedBox(height: 12),

      _priceSummaryCard(items, subtotal, savings),
      const SizedBox(height: 80),
    ]);
  }

  Widget _reviewInfoTile({required IconData icon, required Color color,
      required String title, required String subtitle, required Color primary}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500,
                height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
      ]),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _bottomBar(BuildContext ctx, EcommerceController ctrl, Color primary,
      double subtotal, double savings) {
    final labels = ['Proceed to Address', 'Proceed to Payment', 'Review Order', 'Place Order'];
    final isLastStep = _step == 3;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12,
            offset: const Offset(0, -3))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total: ₹${_fmt(subtotal)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (savings > 0)
            Text('Save ₹${_fmt(savings)}',
              style: TextStyle(color: Colors.green.shade700,
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLastStep ? Colors.green.shade600 : primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _placingOrder ? null : () async {
              if (_step < 3) { setState(() => _step++); }
              else { await _placeOrder(ctx, ctrl, subtotal, savings); }
            },
            child: _placingOrder
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (isLastStep)
                      const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(labels[_step], style: const TextStyle(color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.bold)),
                    if (!isLastStep)
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  ]),
          ),
        ),
      ]),
    );
  }

  Future<void> _placeOrder(BuildContext ctx, EcommerceController ctrl,
      double subtotal, double savings) async {
    setState(() => _placingOrder = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final order = ctrl.placeOrder(
      items: ctrl.cartItems,
      total: subtotal,
      savings: savings,
      address: _selectedAddress?.fullAddress ?? '',
      paymentMethod: _selectedPayment,
    );
    setState(() => _placingOrder = false);

    if (mounted) {
      Navigator.pushReplacement(ctx, MaterialPageRoute(
        builder: (_) => OrderTrackingScreen(order: order, controller: ctrl)));
    }
  }

  Widget _priceRow(String label, String value,
      {Color? valueColor, bool bold = false, double fontSize = 13}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: fontSize, color: Colors.grey.shade700)),
      Text(value, style: TextStyle(fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: valueColor ?? Colors.grey.shade900)),
    ]);
  }

  Widget _emptyCart(BuildContext ctx, Color primary) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text('Your cart is empty',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Add items to start shopping', style: TextStyle(color: Colors.grey.shade500)),
      const SizedBox(height: 24),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Continue Shopping',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ]));
  }
}
