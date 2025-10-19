import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:feedia/data/model/food_model.dart';
import 'package:feedia/core/configs/api_config.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? _createDio();

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

  Future<List<FoodModel>> getFoods() async {
    try {
      final response = await _dio.get('/foods');
      return (response.data as List)
          .map((json) => FoodModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch foods: $e');
    }
  }

  Future<List<FoodModel>> getMainCourseFoods() async {
    try {
      final response = await _dio.get('/foods/main-course');
      // Parse JSON string to List
      List<dynamic> data;
      if (response.data is String) {
        data = jsonDecode(response.data) as List<dynamic>;
      } else {
        data = response.data as List<dynamic>;
      }
      
      print('Parsed data length: ${data.length}');
      
      final foods = data
          .map((json) => FoodModel.fromJson(json))
          .toList();
      print('Parsed ${foods.length} food models');
      return foods;
    } catch (e) {
      print('API Error: $e');
      throw Exception('Failed to fetch main course foods: $e');
    }
  }


}
