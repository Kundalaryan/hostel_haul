import 'package:flutter/material.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartRepository _cartRepository = CartRepository();
  bool _isLoading = false;

  void _updateState() {
    setState(() {}); // Refreshes the UI when data changes
  }

  void _handleCheckout() async {
    setState(() => _isLoading = true);

    bool success = await _cartRepository.checkout();

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order Placed Successfully!")),
      );
      Navigator.pop(context); // Go back to Home
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checkout Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF34D186);
    final items = _cartRepository.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("My Cart (${items.length})", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: const BackButton(color: Colors.black),
        actions: [
          TextButton(
              onPressed: () {
                _cartRepository.clearCart();
                _updateState();
              },
              child: const Text("Clear All", style: TextStyle(color: Colors.grey))
          )
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          // 1. Delivery Tag (Visual)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text("Delivering to 94103", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. List of Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildCartItem(items[index], primaryColor),
            ),
          ),

          // 3. Order Summary & Checkout
          _buildBottomSection(primaryColor),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Image
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            child: item.product.imageUrl != null
                ? Image.network(item.product.imageUrl!)
                : const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("\$${item.product.price}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),

          // Quantity Controls
          Row(
            children: [
              _iconBtn(Icons.remove, () {
                _cartRepository.updateQuantity(item.product.id, -1);
                _updateState();
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _iconBtn(Icons.add, () {
                _cartRepository.updateQuantity(item.product.id, 1);
                _updateState();
              }, color: primaryColor, iconColor: Colors.white),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color color = const Color(0xFFF0F0F0), Color iconColor = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32, width: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  Widget _buildBottomSection(Color primaryColor) {
    final subtotal = _cartRepository.totalAmount;
    final delivery = 2.99;
    final total = subtotal + delivery;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _summaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          _summaryRow("Delivery Fee", "\$${delivery.toStringAsFixed(2)}"),
          const Divider(height: 32),
          _summaryRow("Total Amount", "\$${total.toStringAsFixed(2)}", isTotal: true),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Checkout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 24 : 14)),
      ],
    );
  }
}