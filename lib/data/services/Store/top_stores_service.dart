import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../core/configs/api_config.dart';
import '../../model/store_model.dart';

class TopStoresService {
  final Dio _dio;

  TopStoresService({Dio? dio}) : _dio = dio ?? _createDio();

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

  /// Lấy danh sách top stores
  Future<List<StoreModel>> getTopStores({
    int pageSize = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/stores/top',
        queryParameters: {
          'pageSize': pageSize,
        },
      );
      final list = _ensureList(response.data);
      return list.map((json) => StoreModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch top stores: $e');
    }
  }

  /// Lấy tất cả top stores (cho trang xem tất cả)
  Future<List<StoreModel>> getAllTopStores({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/stores/top/all',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      final list = _ensureList(response.data);
      return list.map((json) => StoreModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all top stores: $e');
    }
  }

  // Helpers to normalize response types (String vs decoded JSON)
  List<dynamic> _ensureList(dynamic data) {
    if (data is List) return data;
    if (data is String) return jsonDecode(data) as List<dynamic>;
    throw Exception('Unexpected response type for List: ${data.runtimeType}');
  }
}

