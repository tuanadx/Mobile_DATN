import 'package:flutter/material.dart';
import 'package:savefood/common/widgets/auth_guard.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      title: 'Thông báo',
      message: 'Vui lòng đăng nhập để xem thông báo và cập nhật mới nhất.',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 66,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có thông báo nào',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bạn hãy quay lại sau nhé',
              style: TextStyle(
                fontSize: 12,
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
