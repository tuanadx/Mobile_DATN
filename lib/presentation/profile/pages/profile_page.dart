import 'package:flutter/material.dart';
import 'package:feedia/core/configs/theme/app_color.dart';
import 'package:feedia/data/services/Auth/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSignedIn = AuthService.isSignedIn;
    final user = AuthService.getCurrentUser();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: AppColor.primary, // App primary color
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: AppColor.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Login / User Info
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isSignedIn) {
                            Navigator.pushNamed(context, '/login');
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Text(
                            isSignedIn
                                ? (user?.name ?? 'Người dùng')
                                : 'Đăng nhập / Đăng ký',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // First Group
                  _buildMenuItem(
                    icon: Icons.card_giftcard,
                    title: 'Ví Voucher',
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.pushNamed(context, '/voucher-wallet');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.payment,
                    title: 'Thanh toán',
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/payment');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Địa chỉ',
                    iconColor: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(context, '/addresses');
                    },
                  ),
                  
                  const Divider(height: 32),
                  
                  // Second Group
                  _buildMenuItem(
                    icon: Icons.share,
                    title: 'Mời bạn bè',
                    iconColor: Colors.blue,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'Về chúng tôi',
                    iconColor: Colors.orange,
                    onTap: () {},
                  ),
                  
                  const Divider(height: 32),
                  
                  // Third Group
                  _buildMenuItem(
                    icon: Icons.help_center,
                    title: 'Trung tâm Trợ giúp',
                    iconColor: Colors.teal,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Cài đặt',
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
