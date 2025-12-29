import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/cart_repository.dart';
import 'home_screen.dart'; // To navigate back to Shop
import 'cart_screen.dart'; // To navigate to Cart
import 'order_details_screen.dart'; // <--- IMPORT THE NEW SCREEN

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final OrderRepository _orderRepository = OrderRepository();

  List<OrderModel> _orders = [];
  bool _isLoading = true;

  // State for the Active Order (Top Card)
  OrderModel? _activeOrder;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);

    // 1. Get All Orders
    final orders = await _orderRepository.getOrders();

    // 2. Find the most recent active order to show in the Timeline Card
    OrderModel? topOrder;
    if (orders.isNotEmpty) {
      // Logic: Pick first order that is NOT Delivered or Cancelled
      topOrder = orders.firstWhere(
            (o) => o.status != 'DELIVERED' && o.status != 'CANCELLED',
        orElse: () => orders.first,
      );
    }

    if (mounted) {
      setState(() {
        _orders = orders;
        _activeOrder = topOrder;
        _isLoading = false;
      });
    }
  }

  void _handleCancelOrder() async {
    if (_activeOrder == null) return;

    final success = await _orderRepository.cancelOrder(_activeOrder!.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Cancelled Successfully")));
      _fetchData(); // Refresh list to show updated status
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to Cancel Order")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF34D186);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Account", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: TIMELINE CARD ---
            if (_activeOrder != null) ...[
              const Text("Timeline of Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildTimelineCard(primaryColor),
              const SizedBox(height: 32),
            ],

            // --- SECTION 2: MY ORDERS LIST ---
            const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),

            if (_orders.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No orders yet.")))
            else
              ListView.separated(
                shrinkWrap: true, // Important inside SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildOrderRow(_orders[index]);
                },
              ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // ACCOUNT IS SELECTED (Index 2)
        onTap: (index) {
          if (index == 0) {
            // Go to Shop (Home)
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 1) {
            // Go to Cart
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
          }
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: "Shop"),
          BottomNavigationBarItem(
              icon: Badge(label: Text('${CartRepository().itemCount}'), child: const Icon(Icons.shopping_cart_outlined)),
              label: "Cart"
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }

  // --- WIDGET: Top Timeline Card ---
  Widget _buildTimelineCard(Color primaryColor) {
    bool isCancelled = _activeOrder?.status == 'CANCELLED';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.store, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("FreshMart Grocery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Order #${_activeOrder?.id} • ₹${_activeOrder?.totalAmount}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCancelled ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                    _activeOrder?.status ?? "",
                    style: TextStyle(
                        color: isCancelled ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                    )
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Timeline Visuals (The Green Lines)
          if (!isCancelled) _buildTimelineVisuals(primaryColor),

          if (isCancelled)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("This order was cancelled.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),

          const SizedBox(height: 24),

          // Cancel Button
          if (!isCancelled && _activeOrder?.status != 'DELIVERED')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleCancelOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Cancel Order"),
              ),
            ),
        ],
      ),
    );
  }

  // Visual logic for drawing the line based on Status
  Widget _buildTimelineVisuals(Color color) {
    String status = _activeOrder?.status ?? "";
    int step = 0;
    // Map your backend status strings to steps
    if (status == "ORDER_PLACED") step = 1;
    if (status == "PACKED") step = 2;
    if (status == "ON_WAY" || status == "IN_TRANSIT") step = 3;
    if (status == "DELIVERED") step = 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDot("Placed", step >= 1, color),
        _buildLine(step >= 2, color),
        _buildDot("Packed", step >= 2, color),
        _buildLine(step >= 3, color),
        _buildDot("On Way", step >= 3, color),
        _buildLine(step >= 4, color),
        _buildDot("Delivered", step >= 4, color),
      ],
    );
  }

  Widget _buildDot(String label, bool isActive, Color color) {
    return Column(
      children: [
        Container(
          height: 16, width: 16,
          decoration: BoxDecoration(
              color: isActive ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [if(isActive) BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 2)]
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.black : Colors.grey, fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget _buildLine(bool isActive, Color color) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? color : Colors.grey.shade200,
      ),
    );
  }

  // --- UPDATED WIDGET: Simple Order Row ---
  Widget _buildOrderRow(OrderModel order) {
    bool isCancelled = order.status == 'CANCELLED';

    // 1. Wrap the entire Container with GestureDetector to handle clicks
    return GestureDetector(
      onTap: () {
        // 2. Navigate to OrderDetailsScreen with the orderId
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: order.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: isCancelled ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: Icon(
                  isCancelled ? Icons.close : Icons.shopping_bag_outlined,
                  color: isCancelled ? Colors.red : Colors.orange
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order #${order.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("₹${order.totalAmount}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Text(
                order.status,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isCancelled ? Colors.red : Colors.black)
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}