import 'package:google_sign_in/google_sign_in.dart';
import 'package:feedia/data/model/auth_response.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Sử dụng serverClientId thay vì clientId để tránh cảnh báo
    serverClientId: '611971545779-rnghkiel93hjgl43ajqgb6rd1nkdaetb.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
    ],
  );

  /// Đăng nhập với Google
  static Future<AuthResponse> signInWithGoogle() async {
    try {
      // Đăng xuất trước để đảm bảo clean state
      await _googleSignIn.signOut();
      
      // Thực hiện đăng nhập
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Người dùng hủy đăng nhập');
      }

      // Lấy thông tin authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null) {
        throw Exception('Không thể lấy access token từ Google');
      }

      // Tạo User object từ thông tin Google
      final user = User(
        id: googleUser.id,
        phoneNumber: '', // Google không cung cấp số điện thoại, để trống
        name: googleUser.displayName,
        email: googleUser.email,
        avatar: googleUser.photoUrl,
      );

      // Tạo AuthResponse
      final authResponse = AuthResponse(
        success: true,
        message: 'Đăng nhập Google thành công',
        user: user,
        accessToken: googleAuth.accessToken,
        refreshToken: googleAuth.idToken, // Sử dụng idToken làm refresh token
      );

      return authResponse;
    } catch (error) {
      print('Lỗi đăng nhập Google: $error');
      throw Exception('Lỗi đăng nhập Google: ${error.toString()}');
    }
  }

  /// Đăng xuất khỏi Google
  static Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print('Lỗi đăng xuất Google: $error');
      // Không throw error vì có thể user chưa đăng nhập Google
    }
  }

  /// Kiểm tra trạng thái đăng nhập Google
  static Future<bool> isSignedInWithGoogle() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      print('Lỗi kiểm tra trạng thái Google: $error');
      return false;
    }
  }

  /// Lấy thông tin user hiện tại từ Google
  static Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (error) {
      print('Lỗi lấy thông tin Google user: $error');
      return null;
    }
  }

  /// Disconnect hoàn toàn khỏi Google (xóa khỏi device)
  static Future<void> disconnectFromGoogle() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      print('Lỗi disconnect Google: $error');
    }
  }
}
