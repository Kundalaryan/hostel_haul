import 'product_model.dart';

// 1. Internal Model (For UI)
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// 2. API Model (For Backend Request)
class OrderRequest {
  final List<OrderItem> items;

  OrderRequest({required this.items});

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int productId;
  final int quantity;

  OrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}