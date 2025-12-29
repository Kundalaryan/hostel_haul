import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_screen.dart';
import 'account_screen.dart'; // <--- NEW IMPORT

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _productRepository = ProductRepository();
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> _products = [];
  bool _isLoading = true;

  // State for Filters
  int _selectedIndex = 0;
  String _selectedCategory = "All";

  final List<String> _categories = ["All", "Vegetables", "Fruits", "Dairy", "Essentials"];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _refreshUI() {
    if (mounted) setState(() {});
  }

  void _fetchProducts() async {
    setState(() => _isLoading = true);

    final products = await _productRepository.getProducts(
      search: _searchController.text,
      category: _selectedCategory,
    );

    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
    });
    _fetchProducts();
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _selectedCategory = "All";
    });
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF34D186);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _searchController,
                onSubmitted: _onSearchSubmitted,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search for milk, bread...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchSubmitted("");
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Categories
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Results Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchController.text.isNotEmpty
                        ? "Search Results"
                        : "$_selectedCategory Items",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Grid
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : _products.isEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 50, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("No items found", style: TextStyle(color: Colors.grey)),
                  TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _onCategorySelected("All");
                      },
                      child: Text("Clear Filters", style: TextStyle(color: primaryColor))
                  )
                ],
              )
                  : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) => _buildProductCard(_products[index], primaryColor),
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION UPDATED ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          // 1. SHOP (Index 0) - Already here

          // 2. CART (Index 1)
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ).then((_) => _refreshUI());
          }

          // 3. ACCOUNT (Index 2) - Navigate to Account Screen
          if (index == 2) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen())
            );
          }
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: "Shop"),
          BottomNavigationBarItem(
              icon: Badge(
                label: Text('${CartRepository().itemCount}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              label: "Cart"
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Account"),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, Color primaryColor) {
    // Check if product is active
    bool isAvailable = product.active;

    return Opacity(
      // 1. Fade out the item if it is not active
      opacity: isAvailable ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, spreadRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: product.imageUrl != null
                    ? Image.network(product.imageUrl!)
                    : Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(product.unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("₹${product.price}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

                // 2. Button Logic
                GestureDetector(
                  onTap: isAvailable
                      ? () {
                    // NORMAL LOGIC: Add to cart
                    CartRepository().addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${product.name} added to cart"),
                        backgroundColor: primaryColor,
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                    setState(() {});
                  }
                      : () {
                    // INACTIVE LOGIC: Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Item is currently unavailable"),
                        backgroundColor: Colors.grey,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    height: 32, width: 32,
                    decoration: BoxDecoration(
                      // Grey if inactive, Green if active
                        color: isAvailable ? primaryColor : Colors.grey,
                        shape: BoxShape.circle
                    ),
                    child: Icon(
                      // Change Icon to imply unavailable
                        isAvailable ? Icons.add : Icons.block,
                        color: Colors.white,
                        size: 20
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}