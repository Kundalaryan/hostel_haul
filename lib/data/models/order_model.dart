class OrderModel {
  final int id;
  final String status;      // e.g., ORDER_PLACED, PACKED, ON_WAY, DELIVERED
  final double totalAmount;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  // Parse the Order JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? "UNKNOWN",
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] ?? "",
    );
  }
}

// Model for the timeline steps (placed, packed, etc.)
class TimelineStep {
  final String status;
  final String timestamp;

  TimelineStep({required this.status, required this.timestamp});

  factory TimelineStep.fromJson(Map<String, dynamic> json) {
    return TimelineStep(
      status: json['status'] ?? "",
      timestamp: json['timestamp'] ?? "",
    );
  }
}