import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../core/configs/api_config.dart';
import '../../model/food_model.dart';

class ProductsTabService {
  final Dio _dio;

  ProductsTabService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio();
    dio.options.baseUrl = ApiConfig.baseUrl;
    dio.options.connectTimeout = ApiConfig.connectTimeout;
    dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    dio.options.headers = ApiConfig.defaultHeaders;

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    return dio;
  }

  /// Lấy sản phẩm gần tôi (theo khoảng cách)
  Future<List<FoodModel>> getNearbyProducts({
    int page = 1,
    int pageSize = 10,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/products/nearby',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
      final list = _ensureList(response.data);
      return list.map((json) => FoodModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby products: $e');
    }
  }

  /// Lấy sản phẩm bán chạy (theo số lượng đơn hàng)
  Future<List<FoodModel>> getPopularProducts({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/products/popular',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      final list = _ensureList(response.data);
      return list.map((json) => FoodModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch popular products: $e');
    }
  }

  /// Lấy sản phẩm đánh giá cao (theo rating)
  Future<List<FoodModel>> getTopRatedProducts({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/products/top-rated',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      final list = _ensureList(response.data);
      return list.map((json) => FoodModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch top rated products: $e');
    }
  }

  // Helpers to normalize response types (String vs decoded JSON)
  List<dynamic> _ensureList(dynamic data) {
    if (data is List) return data;
    if (data is String) return jsonDecode(data) as List<dynamic>;
    throw Exception('Unexpected response type for List: ${data.runtimeType}');
  }
}
