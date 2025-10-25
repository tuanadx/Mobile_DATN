import 'package:flutter/material.dart';
import 'package:savefood/common/widgets/auth_guard.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      title: 'Xem đơn hàng',
      message: 'Vui lòng đăng nhập để xem lịch sử đơn hàng của bạn.',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có đơn hàng nào',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy đặt món nào',
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
