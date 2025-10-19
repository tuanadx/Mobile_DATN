import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/configs/api_config.dart';
import '../model/profile_data.dart';
import 'Auth/auth_service.dart';

class ProfileService {
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
    
    // Thêm LogInterceptor để debug
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    return dio;
  }

  static Future<ProfileData> fetchProfile() async {
    print('ProfileService: Fetching profile with token: ${AuthService.getAccessToken()}');
    final dio = _createDio();
    try {
      final res = await dio.get('/me');
      print('ProfileService: Response received: ${res.data}');
      print('ProfileService: Response type: ${res.data.runtimeType}');
      
      dynamic data = res.data;
      
      // Nếu response là String, parse thành Map
      if (data is String) {
        print('ProfileService: Parsing String response...');
        try {
          data = jsonDecode(data);
          print('ProfileService: Parsed to Map: $data');
        } catch (e) {
          print('ProfileService: Failed to parse String: $e');
          throw Exception('Không thể parse JSON từ String');
        }
      }
      
      if (data is Map<String, dynamic>) {
        print('ProfileService: Data is Map, attempting to parse...');
        try {
          final profile = ProfileData.fromJson(data);
          print('ProfileService: Profile parsed successfully!');
          return profile;
        } catch (parseError) {
          print('ProfileService: Parse error: $parseError');
          rethrow;
        }
      }
      print('ProfileService: Data is not Map, type: ${data.runtimeType}');
      throw Exception('Phản hồi hồ sơ không hợp lệ');
    } catch (e) {
      print('ProfileService: Error fetching profile: $e');
      rethrow;
    }
  }
}


