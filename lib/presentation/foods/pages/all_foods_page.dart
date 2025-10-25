import 'package:flutter/material.dart';
import 'package:savefood/presentation/foods/pages/food_detail_page.dart';
import 'package:savefood/presentation/home/widgets/food_item_card.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/core/services/product_data_manager.dart';
import 'package:savefood/core/widgets/pagination_list_view.dart';
import 'package:savefood/data/model/food_model.dart';

class AllFoodsPage extends StatelessWidget {
  final String storeId;
  
  const AllFoodsPage({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    final dataManager = ProductDataManager();
    
    // Cache được quản lý tự động bởi dio_cache_interceptor
    // Không cần clear cache thủ công nữa
    final paginationService = dataManager.getStoreProductsPagination(storeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tất cả món ăn',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Lọc',
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: PaginationListView<FoodModel>(
        paginationService: paginationService,
        itemBuilder: (context, food, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FoodItemCard(
              food: food,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodDetailPage(
                      food: food,
                    ),
                  ),
                );
              },
            ),
          );
        },
        loadingWidget: const Center(
          child: CircularProgressIndicator(
            color: AppColor.primary,
          ),
        ),
        errorWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải món ăn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng kiểm tra kết nối mạng',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => paginationService.loadFirstPage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        emptyWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Không có món ăn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Hãy thử lại sau',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
