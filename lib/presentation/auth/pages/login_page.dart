import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/data/services/Auth/auth_service.dart';
import 'package:savefood/data/services/Auth/otp_service.dart';
import 'package:savefood/data/services/Auth/facebook_auth_service.dart';
import 'package:savefood/data/services/Auth/google_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _phoneController.text.length >= 10;
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Đăng nhập với Google
      final authResponse = await GoogleAuthService.signInWithGoogle();
      
      // Lưu thông tin đăng nhập
      await AuthService.saveAuthData(authResponse);
      
      // Đóng loading dialog
      if (mounted) Navigator.pop(context);

      // Đăng nhập thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập Google thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Chuyển đến trang chính
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (error) {
      // Đóng loading dialog nếu còn mở
      if (mounted) Navigator.pop(context);
      
      // Chỉ hiển thị lỗi nếu không phải do người dùng hủy
      if (mounted && !error.toString().toLowerCase().contains('cancelled') && 
          !error.toString().toLowerCase().contains('hủy') &&
          !error.toString().toLowerCase().contains('cancel')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng nhập Google: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Đăng nhập với Facebook
      final authResponse = await FacebookAuthService.signInWithFacebook();
      
      // Lưu thông tin đăng nhập
      await AuthService.saveAuthData(authResponse);
      
      // Đóng loading dialog
      if (mounted) Navigator.pop(context);

      // Đăng nhập thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập Facebook thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Chuyển đến trang chính
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (error) {
      // Đóng loading dialog nếu còn mở
      if (mounted) Navigator.pop(context);
      
      // Chỉ hiển thị lỗi nếu không phải do người dùng hủy
      if (mounted && !error.toString().toLowerCase().contains('cancelled') && 
          !error.toString().toLowerCase().contains('hủy') &&
          !error.toString().toLowerCase().contains('cancel')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng nhập Facebook: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePhoneLogin() async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Gửi OTP đến số điện thoại
      final result = await OtpService.sendOtp(_phoneController.text);
      
      // Đóng loading dialog
      if (mounted) Navigator.pop(context);

      if (result['success']) {
        // Chuyển đến trang nhập OTP
        if (mounted) {
          Navigator.pushNamed(
            context, 
            '/otp-verification',
            arguments: _phoneController.text,
          );
        }
      } else {
        // Hiển thị lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Lỗi gửi OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      // Đóng loading dialog nếu còn mở
      if (mounted) Navigator.pop(context);
      
      // Hiển thị lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColor.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đăng nhập / Đăng ký',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: AppColor.primary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom -
                         kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 1),
                    
                    // Logo
                    SvgPicture.asset(
                      'assets/icons/logov2.svg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Phone Input
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.phone,
                            color: Colors.grey,
                            size: 18,
                          ),
                          hintText: 'Số điện thoại',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPhoneValid ? _handlePhoneLogin : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPhoneValid 
                              ? AppColor.primary 
                              : Colors.grey[300],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Tiếp tục',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 5),
                    
                    // Password Login Link
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/password-login');
                      },
                      child: const Text(
                        'Đăng nhập bằng Mật khẩu',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Divider with OR
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'HOẶC',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Social Login Buttons
                    _buildSocialButton(
                      iconPath: 'assets/icons/google-svgrepo-com.svg',
                      text: 'Tiếp tục với Google',
                      onTap: _signInWithGoogle,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSocialButton(
                      iconPath: 'assets/icons/facebook-svgrepo-com.svg',
                      text: 'Tiếp tục với Facebook',
                      onTap: _signInWithFacebook,
                    ),
                    
                    // Thay Spacer() bằng Expanded
                    Expanded(
                      child: Container(),
                    ),
                    
                    // Terms and Conditions
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                          children: [
                            TextSpan(text: 'Bằng cách đăng nhập hoặc đăng ký, bạn đồng ý với '),
                            TextSpan(
                              text: 'Chính sách quy định của SaveFood.',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String iconPath,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}