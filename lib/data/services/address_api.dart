import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/configs/api_config.dart';
import '../model/address.dart';
import 'Auth/auth_service.dart';

class AddressApi {
  static Dio _createDio() {
    final dio = Dio();
    dio.options.baseUrl = ApiConfig.baseUrl;
    dio.options.connectTimeout = ApiConfig.connectTimeout;
    dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    dio.options.headers = {
      ...ApiConfig.defaultHeaders,
      if (AuthService.getAccessToken() != null)
        'Authorization': 'Bearer ${AuthService.getAccessToken()}',
    };
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    return dio;
  }

  /// Tạo địa chỉ mới trên server
  static Future<AddressItem> createAddress(AddressItem address) async {
    final dio = _createDio();
    final res = await dio.post('/addresses', data: address.toJson());

    dynamic data = res.data;
    if (data is String) {
      data = jsonDecode(data);
    }

    // Chấp nhận 2 dạng: { address: {...} } hoặc trả trực tiếp {...}
    if (data is Map<String, dynamic>) {
      final map = data['address'] is Map<String, dynamic> ? data['address'] : data;
      return AddressItem.fromJson(Map<String, dynamic>.from(map));
    }
    throw Exception('Phản hồi tạo địa chỉ không hợp lệ');
  }
}


