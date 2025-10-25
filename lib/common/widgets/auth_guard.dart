import 'package:flutter/material.dart';
import 'package:savefood/data/services/Auth/auth_service.dart';
import 'package:savefood/presentation/auth/pages/login_page.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? message;

  const AuthGuard({super.key, required this.child, this.title, this.message});

  @override
  Widget build(BuildContext context) {
    if (AuthService.isSignedIn) {
      return child;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.black54),
                const SizedBox(height: 16),
                Text(
                  title ?? 'Yêu cầu đăng nhập',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  message ?? 'Vui lòng đăng nhập để sử dụng tính năng này.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Đến trang đăng nhập',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


