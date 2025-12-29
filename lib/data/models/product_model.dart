class ProductModel {
  final int id;
  final String name;
  final String category;
  final String unit;
  final double price;
  final int stock;
  final String? imageUrl;
  final bool active;// Nullable as per your JSON

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.active,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      unit: json['unit'],
      // Safely handle if backend sends 20 (int) or 20.0 (double)
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      imageUrl: json['imageUrl'],
      active: json['active'] ?? true,
    );
  }
}