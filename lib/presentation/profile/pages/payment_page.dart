import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thanh toán',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 12),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildItem(
            context,
            title: 'Ví điện tử',
            onTap: () {},
          ),
          _buildItem(
            context,
            title: 'Thẻ Tín dụng/ Ghi nợ',
            onTap: () {
              Navigator.pushNamed(context, '/add-card');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, {required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


