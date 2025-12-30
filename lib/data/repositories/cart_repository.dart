import 'dart:math'; // Import for Random
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../core/api_response.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartRepository {
  // --- 1. Singleton Setup ---
  static final CartRepository _instance = CartRepository._internal();
  factory CartRepository() => _instance;
  CartRepository._internal();

  // --- 2. Local State ---
  final List<CartItem> _cartItems = [];
  final ApiClient _apiClient = ApiClient();

  List<CartItem> get items => _cartItems;

  int get itemCount {
    // Sum of all quantities (e.g., 2 Apples + 1 Bread = 3 items)
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    double total = 0;
    for (var item in _cartItems) {
      total += (item.product.price * item.quantity);
    }
    return total;
  }

  // --- 3. Local Logic ---

  void addToCart(ProductModel product) {
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

  // --- 4. API Logic (Checkout with Idempotency) ---
  Future<bool> checkout() async {
    try {
      if (_cartItems.isEmpty) return false;

      // A. Generate Unique Idempotency Key
      // Format: "ORDER-timestamp-random"
      String idempotencyKey = "ORDER-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}";

      // B. Prepare Request Body
      final orderItems = _cartItems.map((item) => OrderItem(
        productId: item.product.id,
        quantity: item.quantity,
      )).toList();

      final request = OrderRequest(items: orderItems);

      // C. Send Request with Header
      Response response = await _apiClient.client.post(
        '/orders',
        data: request.toJson(),
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey, // <--- THE NEW HEADER
          },
        ),
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
              (json) => null
      );

      if (apiResponse.success) {
        clearCart();
        return true;
      }
      return false;

    } catch (e) {
      print("Checkout Error: $e");
      return false;
    }
  }
}