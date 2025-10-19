import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/configs/api_config.dart';
import '../model/food_model.dart';

class FeaturedService {
  final Dio _dio;

  FeaturedService({Dio? dio}) : _dio = dio ?? _createDio();

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

  /// Lấy danh sách sản phẩm nổi bật
  Future<List<FoodModel>> getFeaturedProducts({
    int page = 1,
    int pageSize = 4,
  }) async {
    try {
      final response = await _dio.get(
        '/featured/products',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      final list = _ensureList(response.data);
      return list.map((json) => FoodModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  /// Lấy tất cả sản phẩm nổi bật (cho trang xem tất cả)
  Future<List<FoodModel>> getAllFeaturedProducts({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/featured/products/all',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      final list = _ensureList(response.data);
      return list.map((json) => FoodModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all featured products: $e');
    }
  }

  // Helpers to normalize response types (String vs decoded JSON)
  List<dynamic> _ensureList(dynamic data) {
    if (data is List) return data;
    if (data is String) return jsonDecode(data) as List<dynamic>;
    throw Exception('Unexpected response type for List: ${data.runtimeType}');
  }
}
