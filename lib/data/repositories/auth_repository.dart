import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';
import '../../core/api_response.dart';
import '../models/login_model.dart';
import '../models/signup_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> signUp(SignUpRequest request) async {
    try {
      Response response = await _apiClient.client.post(
        '/auth/register',
        data: request.toJson(),
      );

      // 1. Use <dynamic> because data is null
      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
            (json) => null, // We don't care about parsing data since it is null
      );

      // 2. ONLY check if success is true. Do not check for data/token.
      if (apiResponse.success) {
        return true;
      } else {
        print("Backend Message: ${apiResponse.message}");
        return false;
      }
    } catch (e) {
      print("Sign Up Error: $e");
      return false;
    }
  }

  Future<bool> login(LoginRequest request) async {
    try {
      Response response = await _apiClient.client.post(
        '/auth/login', // Verify this matches your Spring Boot endpoint
        data: request.toJson(),
      );

      // 1. Parse Response
      // We expect 'data' to contain the token: { "token": "ey..." }
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );

      // 2. Check Success & Save Token
      if (apiResponse.success && apiResponse.data != null) {
        final token = apiResponse.data!['token'];

        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
          return true;
        }
      }

      print("Login Failed Message: ${apiResponse.message}");
      return false;

    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }
}