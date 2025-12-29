import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../core/api_response.dart';
import '../models/order_model.dart';
import '../models/order_detail_model.dart';

class OrderRepository {
  final ApiClient _apiClient = ApiClient();

  // 1. Get All Orders
  Future<List<OrderModel>> getOrders() async {
    try {
      Response response = await _apiClient.client.get('/orders/my');

      final apiResponse = ApiResponse<List<OrderModel>>.fromJson(
        response.data,
            (json) => (json as List).map((item) => OrderModel.fromJson(item)).toList(),
      );

      return apiResponse.data ?? [];
    } catch (e) {
      print("Get Orders Error: $e");
      return [];
    }
  }

  // 2. Get Timeline for a specific Order
  Future<List<TimelineStep>> getOrderTimeline(int orderId) async {
    try {
      Response response = await _apiClient.client.get('/orders/$orderId/timeline');

      final apiResponse = ApiResponse<List<TimelineStep>>.fromJson(
        response.data,
            (json) => (json as List).map((item) => TimelineStep.fromJson(item)).toList(),
      );

      return apiResponse.data ?? [];
    } catch (e) {
      print("Timeline Error: $e");
      return [];
    }
  }

  // 3. Cancel Order
  Future<bool> cancelOrder(int orderId) async {
    try {
      Response response = await _apiClient.client.patch('/orders/$orderId/cancel');

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
            (json) => null, // We don't need data, just success status
      );

      return apiResponse.success;
    } catch (e) {
      print("Cancel Order Error: $e");
      return false;
    }
  }
  Future<OrderDetail?> getOrderDetails(int orderId) async {
    try {
      Response response = await _apiClient.client.get('/orders/$orderId');

      final apiResponse = ApiResponse<OrderDetail>.fromJson(
        response.data,
            (json) => OrderDetail.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse.data;
    } catch (e) {
      print("Get Order Detail Error: $e");
      return null;
    }
  }
}