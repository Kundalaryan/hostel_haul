import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // <--- 1. NEW IMPORT
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/cart_repository.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'order_details_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // <--- 2. NEW INSTANCE

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  OrderModel? _activeOrder;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    final orders = await _orderRepository.getOrders();

    OrderModel? topOrder;
    if (orders.isNotEmpty) {
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
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to Cancel Order")));
    }
  }

  // --- 3. NEW LOGOUT FUNCTION ---
  void _handleLogout() async {
    // Show confirmation dialog (Optional but good UX)
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Log Out", style: TextStyle(color: Colors.red))),
          ],
        )
    ) ?? false;

    if (confirm) {
      // 1. Delete Token
      await _storage.delete(key: 'jwt_token');

      // 2. Clear Cart (Optional, but clean)
      CartRepository().clearCart();

      if (!mounted) return;

      // 3. Navigate to Login and destroy history
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
        actions: [
          // Option A: Logout Icon in Top Right
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _handleLogout,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_activeOrder != null) ...[
              const Text("Timeline of Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildTimelineCard(primaryColor),
              const SizedBox(height: 32),
            ],

            const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),

            if (_orders.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No orders yet.")))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildOrderRow(_orders[index]);
                },
              ),

            const SizedBox(height: 40),

            // Option B: Big Logout Button at Bottom
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton.icon(
                onPressed: _handleLogout,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 1) {
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

  // ... (Keep _buildTimelineCard, _buildTimelineVisuals, _buildDot, _buildLine, _buildOrderRow exactly the same as before) ...

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
          if (!isCancelled) _buildTimelineVisuals(primaryColor),
          if (isCancelled)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("This order was cancelled.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 24),
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

  Widget _buildTimelineVisuals(Color color) {
    String status = _activeOrder?.status ?? "";
    int step = 0;
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

  Widget _buildOrderRow(OrderModel order) {
    bool isCancelled = order.status == 'CANCELLED';
    return GestureDetector(
      onTap: () {
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