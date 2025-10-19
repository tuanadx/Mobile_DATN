import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../core/configs/api_config.dart';
import '../../model/auth_response.dart';

class FacebookAuthService {
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

  /// Đăng nhập bằng Facebook
  static Future<AuthResponse> signInWithFacebook() async {
    try {
      // 1. Đăng nhập với Facebook SDK
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        
        // 2. Lấy thông tin user từ Facebook
        final userData = await FacebookAuth.instance.getUserData();
        
        // 3. Gửi thông tin lên server để tạo/đăng nhập tài khoản
        final authResponse = await _authenticateWithServer(
          facebookToken: accessToken.tokenString,
          userData: userData,
        );
        
        return authResponse;
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception('Đăng nhập Facebook bị hủy');
      } else {
        throw Exception('Đăng nhập Facebook thất bại: ${result.message}');
      }
    } catch (e) {
      throw Exception('Lỗi đăng nhập Facebook: $e');
    }
  }

  /// Đăng xuất Facebook
  static Future<void> signOutFromFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print('Lỗi đăng xuất Facebook: $e');
    }
  }

  /// Gửi thông tin Facebook lên server để xác thực
  static Future<AuthResponse> _authenticateWithServer({
    required String facebookToken,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final dio = _createDio();
      
      // Chuẩn bị dữ liệu gửi lên server
      final requestData = {
        'provider': 'facebook',
        'access_token': facebookToken,
        'user_data': {
          'id': userData['id'] ?? '',
          'name': userData['name'] ?? '',
          'email': userData['email'] ?? '',
          'picture': _extractProfilePicture(userData),
        }
      };

      print('Facebook login request: $requestData');
      
      final response = await dio.post('/auth/facebook', data: requestData);
      
      print('Facebook login response: ${response.data}');
      
      // Parse response từ server
      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      
      return AuthResponse.fromJson(data);
    } catch (e) {
      print('Lỗi xác thực với server: $e');
      throw Exception('Không thể xác thực với server: $e');
    }
  }

  /// Kiểm tra trạng thái đăng nhập Facebook
  static Future<bool> isFacebookSignedIn() async {
    try {
      final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
      return accessToken != null;
    } catch (e) {
      return false;
    }
  }

  /// Lấy thông tin user hiện tại từ Facebook
  static Future<Map<String, dynamic>?> getCurrentFacebookUser() async {
    try {
      final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
      if (accessToken != null) {
        return await FacebookAuth.instance.getUserData();
      }
      return null;
    } catch (e) {
      print('Lỗi lấy thông tin Facebook user: $e');
      return null;
    }
  }

  /// Trích xuất URL ảnh profile từ dữ liệu Facebook
  static String _extractProfilePicture(Map<String, dynamic> userData) {
    try {
      final picture = userData['picture'];
      if (picture != null && picture is Map<String, dynamic>) {
        final data = picture['data'];
        if (data != null && data is Map<String, dynamic>) {
          return data['url'] ?? '';
        }
      }
      return '';
    } catch (e) {
      print('Lỗi trích xuất ảnh profile: $e');
      return '';
    }
  }
}
