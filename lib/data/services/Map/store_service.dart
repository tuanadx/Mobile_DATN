import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:savefood/core/configs/api_config.dart';
import 'package:savefood/data/model/map/store_model.dart';

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
  /// Lấy danh sách các quán gần vị trí người dùng
  Future<List<Store>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radius = 5.0, // bán kính tìm kiếm (km)
  }) async {
    try {
      print('🔍 StoreService: Gọi API /stores/nearby với params: lat=$latitude, lng=$longitude, radius=$radius');
      
      final response = await _dio.get('/stores/nearby', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      });

      print('📡 StoreService: Response status: ${response.statusCode}');
      print('📦 StoreService: Response data type: ${response.data.runtimeType}');
      print('📦 StoreService: Response data: ${response.data}');

      // Hỗ trợ cả 2 dạng: [ ... ] hoặc { data: { stores: [...] } }
      dynamic body = response.data;
      List<dynamic> storesJson = const [];
      
      // Xử lý trường hợp response là String (JSON chưa parse)
      if (body is String) {
        print('📋 StoreService: Response là String, cần parse JSON');
        try {
          body = jsonDecode(body);
          print('📋 StoreService: Đã parse JSON thành công, type: ${body.runtimeType}');
        } catch (e) {
          print('❌ StoreService: Lỗi parse JSON: $e');
          throw Exception('Failed to parse JSON response: $e');
        }
      }
      
      if (body is List) {
        print('📋 StoreService: Response là List, có ${body.length} items');
        storesJson = body;
      } else if (body is Map) {
        print('📋 StoreService: Response là Map, keys: ${body.keys}');
        final dynamic data = body['data'];
        if (data is Map && data['stores'] is List) {
          storesJson = data['stores'] as List;
          print('📋 StoreService: Tìm thấy stores trong data.stores: ${storesJson.length} items');
        } else if (body['stores'] is List) {
          storesJson = body['stores'] as List;
          print('📋 StoreService: Tìm thấy stores trong root: ${storesJson.length} items');
        }
      }
      
      print('🏪 StoreService: Sẽ parse ${storesJson.length} stores');
      final stores = storesJson.map((e) {
        print('🏪 StoreService: Parsing store: $e');
        return Store.fromJson(Map<String, dynamic>.from(e));
      }).toList();
      
      print('✅ StoreService: Trả về ${stores.length} stores');
      return stores;
    } catch (e) {
      print('❌ StoreService: Error fetching nearby stores: $e');
      throw Exception('Failed to fetch nearby stores: $e');
    }
  }

  /// Lấy chi tiết một quán
  Future<Store?> getStoreDetail(String storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId');
      return Store.fromJson(response.data['store'] ?? response.data['data']);
    } catch (e) {
      print('Error fetching store detail: $e');
      throw Exception('Failed to fetch store detail: $e');
    }
  }

  /// Tìm kiếm quán theo tên
  Future<List<Store>> searchStores({
    required String keyword,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'keyword': keyword,
      };
      
      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
      }

      final response = await _dio.get('/stores/search', queryParameters: queryParams);
      final List<dynamic> storesJson = response.data['stores'] ?? response.data['data'] ?? [];
      
      return storesJson.map((json) => Store.fromJson(json)).toList();
    } catch (e) {
      print('Error searching stores: $e');
      throw Exception('Failed to search stores: $e');
    }
  }
}