import 'order_model.dart'; // Import for TimelineStep if you want to reuse it

class OrderDetail {
  final int orderId;
  final String status;
  final double totalAmount;
  final String createdAt;
  final List<OrderItemDetail> items;
  final List<TimelineStep> timeline;

  OrderDetail({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
    required this.timeline,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderId: json['orderId'] ?? 0,
      status: json['status'] ?? "UNKNOWN",
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] ?? "",
      items: (json['items'] as List?)
          ?.map((i) => OrderItemDetail.fromJson(i))
          .toList() ?? [],
      timeline: (json['timeline'] as List?)
          ?.map((t) => TimelineStep.fromJson(t))
          .toList() ?? [],
    );
  }
}

class OrderItemDetail {
  final int id;
  final String productName;
  final int quantity;
  final double priceAtPurchase;

  OrderItemDetail({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      id: json['id'] ?? 0,
      productName: json['productName'] ?? "Unknown Item",
      quantity: json['quantity'] ?? 1,
      priceAtPurchase: (json['priceAtPurchase'] as num?)?.toDouble() ?? 0.0,
    );
  }
}