import 'package:flutter/material.dart';
import 'package:savefood/core/configs/theme/app_color.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String userLocation;
  final VoidCallback? onLocationTap;
  final Function(String)? onSearchChanged;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.userLocation,
    this.onLocationTap,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColor.primary, Color(0xFFA4C3A2)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting
          Text(
            'Hi $userName!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          
          // Delivery text
          const Text(
            'Giao đến:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // Location
          GestureDetector(
            onTap: onLocationTap,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    userLocation,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Search Bar
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm món ăn hoặc quán ăn',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 16,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
