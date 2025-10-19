import 'package:flutter/material.dart';
import 'package:feedia/data/model/food_model.dart';
import 'package:feedia/core/services/product_data_manager.dart';
import 'package:feedia/core/widgets/pagination_list_view.dart';

class ProductListWidget extends StatelessWidget {
  final String storeId;
  final String? categoryId;

  const ProductListWidget({
    Key? key,
    required this.storeId,
    this.categoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataManager = ProductDataManager();
    final paginationService = categoryId != null
        ? dataManager.getCategoryProductsPagination(storeId, categoryId!)
        : dataManager.getStoreProductsPagination(storeId);

    return PaginationListView<FoodModel>(
      paginationService: paginationService,
      itemBuilder: (context, product, index) {
        return _buildProductItem(context, product, index);
      },
      loadingWidget: const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải sản phẩm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng kiểm tra kết nối mạng',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => paginationService.loadFirstPage(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      emptyWidget: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có sản phẩm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy thử lại sau',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, FoodModel product, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(
                      i < product.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    )),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    if (product.discountPercentage != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${(product.price * (1 + product.discountPercentage! / 100)).toStringAsFixed(0)}đ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
