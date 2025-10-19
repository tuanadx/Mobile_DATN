import 'package:flutter/material.dart';
import 'package:feedia/common/widgets/auth_guard.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      title: 'Danh sách yêu thích',
      message: 'Vui lòng đăng nhập để xem danh sách món ăn yêu thích của bạn.',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có món yêu thích',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy thêm món vào danh sách yêu thích',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
