import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../core/configs/api_config.dart';
import '../../model/store_model.dart';
import '../../model/food_model.dart';

class StoreService {
  final Dio _dio;

  StoreService({Dio? dio}) : _dio = dio ?? _createDio();

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

  Future<StoreModel> getStore(String storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId');
      final data = _ensureMap(response.data);
      return StoreModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch store: $e');
    }
  }

  Future<List<String>> getStoreCategories(String storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/categories');
      final list = _ensureList(response.data);
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      throw Exception('Failed to fetch store categories: $e');
    }
  }

  Future<List<FoodModel>> getStoreProducts(
    String storeId, {
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/stores/$storeId/products',
        queryParameters: {
          if (categoryId != null) 'categoryId': categoryId,
          'page': page,
          'pageSize': pageSize,
        },
      );
      final list = _ensureList(response.data);
      return list.map((json) => FoodModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch store products: $e');
    }
  }

  // Helpers to normalize response types (String vs decoded JSON)
  Map<String, dynamic> _ensureMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    throw Exception('Unexpected response type for Map: ${data.runtimeType}');
  }

  List<dynamic> _ensureList(dynamic data) {
    if (data is List) return data;
    if (data is String) return jsonDecode(data) as List<dynamic>;
    throw Exception('Unexpected response type for List: ${data.runtimeType}');
  }
}


