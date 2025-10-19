import 'package:flutter/material.dart';
import 'package:feedia/core/configs/theme/app_color.dart';
import 'package:feedia/data/model/food_model.dart';
import 'package:feedia/presentation/home/widgets/food_item_card.dart';

class FoodListSection extends StatelessWidget {
  final List<FoodModel> foods;
  final VoidCallback? onSeeAllTap;
  final Function(FoodModel)? onFoodTap;

  const FoodListSection({
    super.key,
    required this.foods,
    this.onSeeAllTap,
    this.onFoodTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hôm nay có gì ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: onSeeAllTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Xem thêm',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Food List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return FoodItemCard(
                food: food,
                onTap: () => onFoodTap?.call(food),
              );
            },
          ),
        ],
      ),
    );
  }
}
