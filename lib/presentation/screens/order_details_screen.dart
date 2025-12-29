import 'package:flutter/material.dart';
import '../../data/models/order_detail_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/cart_repository.dart'; // For Reorder Logic

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  OrderDetail? _orderDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() async {
    final detail = await _orderRepository.getOrderDetails(widget.orderId);
    if (mounted) {
      setState(() {
        _orderDetail = detail;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF34D186);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Order Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {}, // Help Logic
            child: Text("Help", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _orderDetail == null
          ? const Center(child: Text("Order not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card (Status & Date)
            _buildHeaderCard(primaryColor),
            const SizedBox(height: 24),

            // 2. Items List
            Text("Items in Order (${_orderDetail!.items.length})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orderDetail!.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildItemRow(_orderDetail!.items[index]),
            ),

            const SizedBox(height: 32),

            // 3. Payment Summary
            const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildSummarySection(),

            const SizedBox(height: 32),

            // 4. Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reorder feature coming soon!")),
                  );
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text("Reorder Items", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.receipt_long, color: Colors.black),
                label: const Text("Download Invoice", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.store, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("FreshMart Grocery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Order #${_orderDetail!.orderId}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_orderDetail!.status, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 10)),
              )
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("DATE", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(_orderDetail!.createdAt.split('T')[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItemDetail item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 40, width: 40,
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Qty: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text("\$${item.priceAtPurchase}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          // Since API only gives Total, we just show Total.
          // If you calculate subtotal manually, you can add rows here.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("\$${_orderDetail!.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF34D186))),
            ],
          ),
        ],
      ),
    );
  }
}