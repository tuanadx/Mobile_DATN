import 'package:flutter/material.dart';
import '../../home/pages/home_page.dart';
import '../../orders/pages/orders_page.dart';
import '../../nearMe/pages/store_map_page.dart';
import '../../notifications/pages/notifications_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../cart/widgets/mini_cart_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const OrdersPage(),
    const StoreMapPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini cart widget
          const MiniCartWidget(),
          // Bottom navigation bar
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFFA4C3A2),
              unselectedItemColor: Colors.grey[600],
              selectedLabelStyle: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag),
                  label: 'Đơn hàng',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  activeIcon: Icon(Icons.map),
                  label: 'Gần tôi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_none),
                  activeIcon: Icon(Icons.notifications),
                  label: 'Thông báo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Tôi',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
