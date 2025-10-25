import 'package:flutter/material.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/data/model/store_model.dart';

class TopStoresSection extends StatelessWidget {
  final List<StoreModel> stores;
  final VoidCallback? onSeeAllTap;
  final Function(StoreModel)? onStoreTap;

  const TopStoresSection({
    super.key,
    required this.stores,
    this.onSeeAllTap,
    this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top quán hot',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (onSeeAllTap != null)
                GestureDetector(
                  onTap: onSeeAllTap,
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stores List - Vertical List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return _buildStoreCard(store);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(StoreModel store) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => onStoreTap?.call(store),
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
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
              // Store Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(store.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const SizedBox.shrink(),
              ),
              
              // Store Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Store Name - Limited to 2 lines
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Store Description
                      Text(
                        store.description,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Rating, Distance and Delivery Time
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.rating.toString(),
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on,
                            size: 10,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.distance,
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[600],
                            ),
                          ),
                          // removed delivery time per request
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
