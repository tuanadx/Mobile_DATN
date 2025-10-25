import 'package:savefood/domain/entities/food_entity.dart';
import 'package:savefood/domain/repositories/food_repository_interface.dart';

class GetFoodsByCategory {
  final FoodRepositoryInterface repository;

  GetFoodsByCategory(this.repository);

  Future<List<FoodEntity>> call(String category) async {
    return await repository.getFoodsByCategory(category);
  }
}
