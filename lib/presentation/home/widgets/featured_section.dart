import 'package:flutter/material.dart';

class FeaturedSection extends StatelessWidget {
  final List<dynamic> featuredItems;
  final VoidCallback? onSeeAllTap;
  final Function(dynamic)? onItemTap;

  const FeaturedSection({
    super.key,
    required this.featuredItems,
    this.onSeeAllTap,
    this.onItemTap,
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
                'Nổi bật',
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
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA4C3A2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Featured Items List
          if (featuredItems.isEmpty)
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chưa có món nổi bật',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredItems.length,
                itemBuilder: (context, index) {
                  final item = featuredItems[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildFeaturedItem(item, context),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedItem(dynamic item, BuildContext context) {
    return GestureDetector(
      onTap: () => onItemTap?.call(item),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.restaurant,
                                size: 40,
                                color: Colors.grey,
                              );
                            },
                          )
                        : const Icon(
                            Icons.restaurant,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                  // Rating overlay
                  if (item.rating != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.rating.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name ?? 'Món nổi bật',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA4C3A2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Nổi bật',
                            style: TextStyle(
                              fontSize: 8,
                              color: Color(0xFFA4C3A2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (item.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category!,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
