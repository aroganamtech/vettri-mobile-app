import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/ecommerce_controller.dart';
import '../models/product_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;
  final EcommerceController controller;

  const OrderTrackingScreen({super.key, required this.order, required this.controller});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkAnim;
  late AnimationController _pulseAnim;
  late Animation<double> _checkScale;
  Timer? _autoAdvance;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pulseAnim = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _checkAnim, curve: Curves.elasticOut));
    _checkAnim.forward();

    _autoAdvance = Timer.periodic(const Duration(seconds: 6), (_) {
      if (widget.order.status != OrderStatus.delivered) {
        widget.controller.advanceOrderStatus(widget.order.orderId);
        if (mounted) setState(() {});
      } else {
        _autoAdvance?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    _pulseAnim.dispose();
    _autoAdvance?.cancel();
    super.dispose();
  }

  String _fmt(double p) {
    if (p >= 100000) return '${(p / 100000).toStringAsFixed(1)}L';
    if (p >= 1000) {
      final s = p.toStringAsFixed(0);
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return p.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final primary = Theme.of(context).primaryColor;
    final currentIdx = OrderStatus.values.indexOf(order.status);
    final isDelivered = order.status == OrderStatus.delivered;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: primary, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order Tracking',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Hero card ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDelivered
                    ? [Colors.green.shade600, Colors.teal.shade600]
                    : [primary, Colors.orange.shade600],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              ScaleTransition(
                scale: _checkScale,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                  child: Center(child: Icon(
                    isDelivered ? Icons.done_all : Icons.check_circle_outline,
                    color: Colors.white, size: 40)),
                ),
              ),
              const SizedBox(height: 16),
              Text(isDelivered ? 'Order Delivered!' : 'Order Confirmed!',
                style: const TextStyle(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(isDelivered
                  ? 'Your order has been delivered successfully'
                  : 'Expected delivery: ${order.expectedDelivery}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.receipt_outlined, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text('Order ID: ${order.orderId}',
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Live Tracking ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Live Tracking',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                if (!isDelivered) ...[
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.5 + _pulseAnim.value * 0.5),
                          shape: BoxShape.circle)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('LIVE', style: TextStyle(color: Colors.green,
                        fontSize: 10, fontWeight: FontWeight.bold))),
                ],
              ]),
              const SizedBox(height: 20),
              ...List.generate(OrderStatus.values.length, (i) {
                final status = OrderStatus.values[i];
                final done = i <= currentIdx;
                final isCurrent = i == currentIdx;
                final isLast = i == OrderStatus.values.length - 1;
                return _trackStep(status: status, done: done, isCurrent: isCurrent,
                    isLast: isLast, primary: primary);
              }),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Delivery Info ──────────────────────────────────────────────────
          _infoCard(icon: Icons.location_on_outlined, color: Colors.orange.shade600,
              title: 'Delivery Address', content: order.deliveryAddress),
          const SizedBox(height: 10),
          _infoCard(icon: Icons.payment_outlined, color: Colors.blue.shade600,
              title: 'Payment Method', content: order.paymentMethod),
          const SizedBox(height: 10),

          // ── Order Items ────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${order.items.length} Item${order.items.length != 1 ? 's' : ''} in this Order',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              ...order.items.map((item) => Padding(
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
                    Text('Qty ${item.quantity} x ₹${_fmt(item.product.price)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ])),
                  Text('₹${_fmt(item.totalPrice)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
              )),
            ]),
          ),
          const SizedBox(height: 10),

          // ── Payment Summary ────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Payment Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              _priceRow('Order Total', '₹${_fmt(order.total + order.savings)}'),
              const SizedBox(height: 6),
              _priceRow('Discount', '-₹${_fmt(order.savings)}',
                  valueColor: Colors.green.shade700),
              const SizedBox(height: 6),
              _priceRow('Delivery', 'FREE', valueColor: Colors.green.shade700),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1)),
              _priceRow('Amount Paid', '₹${_fmt(order.total)}', bold: true, fontSize: 15),
              if (order.savings > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(Icons.savings_outlined, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text('You saved ₹${_fmt(order.savings)} on this order!',
                      style: TextStyle(color: Colors.green.shade800,
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  ]),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 20),

          // ── Actions ────────────────────────────────────────────────────────
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('Invoice'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary, side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 13)),
            )),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.support_agent_outlined, size: 18),
              label: const Text('Help'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 13)),
            )),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: const Text('Continue Shopping', style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0),
            )),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _trackStep({required OrderStatus status, required bool done,
      required bool isCurrent, required bool isLast, required Color primary}) {
    final dotColor = done
        ? (isCurrent ? primary : Colors.green.shade600)
        : Colors.grey.shade300;

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 34, child: Column(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: isCurrent ? 30 : 24, height: isCurrent ? 30 : 24,
          decoration: BoxDecoration(
            color: done ? dotColor : Colors.transparent,
            border: Border.all(color: done ? dotColor : Colors.grey.shade300,
                width: isCurrent ? 3 : 2),
            shape: BoxShape.circle,
            boxShadow: isCurrent ? [BoxShadow(color: primary.withValues(alpha: 0.3),
                blurRadius: 8, spreadRadius: 1)] : [],
          ),
          child: done ? Center(child: Icon(
            isCurrent ? _statusIcon(status) : Icons.check,
            color: Colors.white, size: isCurrent ? 15 : 13)) : null,
        ),
        if (!isLast) AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 2, height: 52,
          color: done && !isCurrent ? Colors.green.shade400 : Colors.grey.shade200),
      ])),
      const SizedBox(width: 14),
      Expanded(child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(status.label, style: TextStyle(fontSize: 14,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: done ? Colors.black : Colors.grey.shade400)),
          const SizedBox(height: 3),
          Text(status.subtitle, style: TextStyle(fontSize: 12,
              color: isCurrent ? Colors.grey.shade700
                  : done ? Colors.green.shade700 : Colors.grey.shade400)),
          if (isCurrent) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200)),
              child: Text('IN PROGRESS', style: TextStyle(fontSize: 9,
                  fontWeight: FontWeight.bold, color: Colors.orange.shade800,
                  letterSpacing: 0.5)),
            ),
          ],
        ]),
      )),
    ]);
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed: return Icons.check_circle_outline;
      case OrderStatus.processing: return Icons.inventory_2_outlined;
      case OrderStatus.shipped: return Icons.local_shipping_outlined;
      case OrderStatus.outForDelivery: return Icons.delivery_dining;
      case OrderStatus.delivered: return Icons.home_outlined;
    }
  }

  Widget _infoCard({required IconData icon, required Color color,
      required String title, required String content}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 2),
          Text(content, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
        ])),
      ]),
    );
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
}
