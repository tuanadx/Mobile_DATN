import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../model/auth_response.dart';
import '../../model/profile_data.dart';
import 'facebook_auth_service.dart';
import 'google_auth_service.dart';

class AuthService {
  static User? _currentUser;
  static ProfileData? _profile;
  static String? _accessToken;
  static String? _refreshToken;

  /// Lưu thông tin đăng nhập
  static Future<void> saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();

    // Lưu token nếu có, kể cả khi chưa có user
    if (authResponse.accessToken != null) {
      _accessToken = authResponse.accessToken;
      await prefs.setString('access_token', authResponse.accessToken!);
    }
    if (authResponse.refreshToken != null) {
      _refreshToken = authResponse.refreshToken;
      await prefs.setString('refresh_token', authResponse.refreshToken!);
    }

    // Lưu user nếu có
    if (authResponse.user != null) {
      _currentUser = authResponse.user;
      await prefs.setString('user_data', jsonEncode(authResponse.user!.toJson()));
    }
  }

  /// Lưu chỉ token
  static Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = accessToken;
    await prefs.setString('access_token', accessToken);
    if (refreshToken != null) {
      _refreshToken = refreshToken;
      await prefs.setString('refresh_token', refreshToken);
    }
  }

  /// Lưu user sau khi gọi profile
  static Future<void> saveUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  /// Lưu toàn bộ profile (user, địa chỉ, yêu thích...)
  static Future<void> saveProfile(ProfileData profile) async {
    _profile = profile;
    _currentUser = profile.user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(profile.user.toJson()));
    await prefs.setString('profile_data', jsonEncode(profile.toJson()));
  }

  /// Load thông tin đăng nhập từ local storage
  static Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    final profileData = prefs.getString('profile_data');
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    if (userData != null && accessToken != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
      _accessToken = accessToken;
      _refreshToken = refreshToken;
    }

    if (profileData != null) {
      try {
        _profile = ProfileData.fromJson(jsonDecode(profileData));
      } catch (_) {}
    }
  }

  /// Đăng xuất
  static Future<void> signOut() async {
    try {
      // Đăng xuất Facebook nếu đang đăng nhập bằng Facebook
      await FacebookAuthService.signOutFromFacebook();
      
      // Đăng xuất Google nếu đang đăng nhập bằng Google
      await GoogleAuthService.signOutFromGoogle();
      
      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    } catch (error) {
      print('Lỗi đăng xuất: $error');
      rethrow;
    }
  }

  /// Lấy thông tin user hiện tại
  static User? getCurrentUser() {
    return _currentUser;
  }

  /// Lấy access token
  static String? getAccessToken() {
    return _accessToken;
  }

  /// Lấy refresh token (nếu cần refresh)
  static String? getRefreshToken() {
    return _refreshToken;
  }

  /// Kiểm tra trạng thái đăng nhập
  static bool get isSignedIn {
    return _currentUser != null && _accessToken != null;
  }

  static ProfileData? getProfile() {
    return _profile;
  }
}
