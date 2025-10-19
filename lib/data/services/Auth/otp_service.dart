import 'package:dio/dio.dart';
import 'dart:convert';
import '../../model/otp_request.dart';
import '../../model/otp_verify_request.dart';
import '../../model/auth_response.dart';
import '../../../core/configs/api_config.dart';

class OtpService {
  static final Dio _dio = _createDio();

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

  /// Gửi OTP đến số điện thoại
  static Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final request = OtpRequest(phoneNumber: phoneNumber);
      
      final response = await _dio.post(
        '/auth/send-otp',
        data: request.toJson(),
      );

      // Xử lý response có thể là String hoặc Map
      if (response.data is String) {
        return {
          'success': true,
          'message': response.data,
        };
      } else {
        return {
          'success': true,
          'data': response.data,
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['message'] ?? 'Lỗi gửi OTP',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  /// Xác thực OTP
  static Future<AuthResponse> verifyOtp(String phoneNumber, String otpCode) async {
    try {
      final request = OtpVerifyRequest(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );
      
      final response = await _dio.post(
        '/auth/verify-otp',
        data: request.toJson(),
      );

      // Một số backend trả JSON dưới dạng String (content-type text/plain)
      // Cần parse lại để lấy user, token...
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AuthResponse.fromJson(data);
      }
      if (data is String) {
        try {
          final parsed = data.trim();
          final decoded = parsed.isNotEmpty ? jsonDecode(parsed) : null;
          if (decoded is Map<String, dynamic>) {
            return AuthResponse.fromJson(decoded);
          }
        } catch (_) {
          // ignore parse errors and fall through
        }
        // Nếu không parse được, trả về message ngắn gọn thay vì toàn bộ JSON
        return AuthResponse(
          success: false,
          message: 'Không đọc được phản hồi từ máy chủ',
        );
      }
      // Trường hợp dữ liệu không mong đợi
      return AuthResponse(
        success: false,
        message: 'Phản hồi không hợp lệ',
      );
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Lỗi xác thực OTP',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Lỗi kết nối: ${e.toString()}',
      );
    }
  }
}
