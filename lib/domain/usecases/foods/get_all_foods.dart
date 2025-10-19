import 'package:feedia/domain/entities/food_entity.dart';
import 'package:feedia/domain/repositories/food_repository_interface.dart';

class GetAllFoods {
  final FoodRepositoryInterface repository;

  GetAllFoods(this.repository);

  Future<List<FoodEntity>> call() async {
    return await repository.getAllFoods();
  }
}
