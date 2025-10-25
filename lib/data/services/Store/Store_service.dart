import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
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

    // Thêm cache interceptor
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403, 500],
      maxStale: const Duration(days: 7),
      priority: CachePriority.normal,
      keyBuilder: (request) {
        return request.uri.toString();
      },
      allowPostMethod: false,
    );
    
    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    
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
    bool forceRefresh = false,
  }) async {
    try {
      print('🌐 API Call: GET /stores/$storeId/products?page=$page&pageSize=$pageSize');
      
      final response = await _dio.get(
        '/stores/$storeId/products',
        queryParameters: {
          if (categoryId != null) 'categoryId': categoryId,
          'page': page,
          'pageSize': pageSize,
        },
        options: CacheOptions(
          store: MemCacheStore(),
          policy: forceRefresh ? CachePolicy.refresh : CachePolicy.request,
          hitCacheOnErrorExcept: [401, 403, 500],
          maxStale: const Duration(minutes: 30), // Cache 30 phút
          priority: CachePriority.normal,
          keyBuilder: (request) {
            return '${request.uri.toString()}_${forceRefresh ? DateTime.now().millisecondsSinceEpoch : ''}';
          },
          allowPostMethod: false,
        ).toOptions(),
      );
      
      print('✅ API Response Status: ${response.statusCode}');
      print('📦 API Response Data Type: ${response.data.runtimeType}');
      
      final list = _ensureList(response.data);
      print('📋 Parsed ${list.length} items from API');
      
      final products = list.map((json) => FoodModel.fromJson(json)).toList();
      print('✅ Successfully created ${products.length} FoodModel objects');
      
      return products;
    } catch (e) {
      print('❌ API Error for store $storeId, page $page: $e');
      if (e is DioException) {
        print('🔍 DioException Details:');
        print('  - Type: ${e.type}');
        print('  - Message: ${e.message}');
        print('  - Response: ${e.response?.data}');
        print('  - Status Code: ${e.response?.statusCode}');
      }
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


