import 'package:savefood/domain/entities/food_entity.dart';

abstract class FoodRepositoryInterface {
  Future<List<FoodEntity>> getAllFoods();
  Future<List<FoodEntity>> getMainCourseFoods();
  Future<FoodEntity> getFoodById(String id);
  Future<List<FoodEntity>> getFoodsByCategory(String category);
}
