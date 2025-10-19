import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:feedia/data/model/promo_model.dart';
import 'package:feedia/core/configs/api_config.dart';

class PromotionApiService {
  final Dio _dio;

  PromotionApiService({Dio? dio}) : _dio = dio ?? _createDio();

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

  Future<List<PromoModel>> getPromos() async {
    try {
      final response = await _dio.get('/promos');
      final raw = response.data;
      final List<dynamic> list = raw is String
          ? (jsonDecode(raw) as List)
          : (raw as List);
      return list
          .map((json) => PromoModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch promos: $e');
    }
  }

  Future<PromoModel> getPromoById(String id) async {
    try {
      final response = await _dio.get('/promos/$id');
      return PromoModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch promo: $e');
    }
  }
}
