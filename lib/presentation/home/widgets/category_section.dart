import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/data/model/category_model_fix.dart';

class CategorySection extends StatefulWidget {
  final List<CategoryModel> categories;
  final VoidCallback? onSeeAllTap;
  final Function(CategoryModel)? onCategoryTap;

  const CategorySection({
    super.key,
    required this.categories,
    this.onSeeAllTap,
    this.onCategoryTap,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // Category Grid with horizontal scroll
          Container(
            height: 210, // Increased to prevent overflow with 2 rows
            child: PageView.builder(
              itemCount: (widget.categories.length / 8).ceil(), // 8 items per page (2 rows x 4 columns)
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 8;
                final endIndex = (startIndex + 8).clamp(0, widget.categories.length);
                final pageCategories = widget.categories.sublist(startIndex, endIndex);
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // First row
                      Row(
                        children: pageCategories.take(4).map((category) {
                          return Expanded(
                            child: _buildCategoryItem(category),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Second row
                      Row(
                        children: pageCategories.skip(4).take(4).map((category) {
                          return Expanded(
                            child: _buildCategoryItem(category),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Page indicator
          if ((widget.categories.length / 8).ceil() > 1) ...[
            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                (widget.categories.length / 8).ceil(),
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index 
                        ? AppColor.primary 
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return GestureDetector(
      onTap: () => widget.onCategoryTap?.call(category),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            child: SvgPicture.asset(
              category.iconPath,
              width: 45,
              height: 45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
