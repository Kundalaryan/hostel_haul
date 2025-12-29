import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../core/api_response.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartRepository {
  // --- 1. Singleton Setup (Makes this accessible everywhere) ---
  static final CartRepository _instance = CartRepository._internal();
  factory CartRepository() => _instance;
  CartRepository._internal();

  // --- 2. Local State (The Cart) ---
  final List<CartItem> _cartItems = [];
  final ApiClient _apiClient = ApiClient();

  // Getters
  List<CartItem> get items => _cartItems;

  int get itemCount => _cartItems.length;

  double get totalAmount {
    double total = 0;
    for (var item in _cartItems) {
      total += (item.product.price * item.quantity);
    }
    return total;
  }

  // --- 3. Local Logic (Add/Remove) ---

  void addToCart(ProductModel product) {
    // Check if already exists
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _cartItems[index].quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(int productId, int change) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cartItems[index].quantity += change;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
    }
  }

  void clearCart() {
    _cartItems.clear();
  }

  // --- 4. API Logic (Checkout) ---
  Future<bool> checkout() async {
    try {
      // Convert Local Cart to API Request
      final orderItems = _cartItems.map((item) => OrderItem(
        productId: item.product.id,
        quantity: item.quantity,
      )).toList();

      final request = OrderRequest(items: orderItems);

      Response response = await _apiClient.client.post(
        '/orders', // Change to your actual endpoint
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
              (json) => null
      );

      if (apiResponse.success) {
        clearCart(); // Clear local cart on success
        return true;
      }
      return false;

    } catch (e) {
      print("Checkout Error: $e");
      return false;
    }
  }
}