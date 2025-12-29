import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../core/api_response.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiClient _apiClient = ApiClient();

  // Added optional named parameters
  Future<List<ProductModel>> getProducts({String? search, String? category}) async {
    try {
      // Build the query map dynamically
      final Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty && category != "All") queryParams['category'] = category;

      Response response = await _apiClient.client.get(
        '/products',
        queryParameters: queryParams, // Dio handles ?search=abc&category=xyz
      );

      final apiResponse = ApiResponse<List<ProductModel>>.fromJson(
        response.data,
            (json) => (json as List).map((item) => ProductModel.fromJson(item)).toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        return [];
      }
    } catch (e) {
      print("Get Products Error: $e");
      return [];
    }
  }
}