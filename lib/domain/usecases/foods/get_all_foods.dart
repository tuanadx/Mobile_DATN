import 'package:savefood/domain/entities/food_entity.dart';
import 'package:savefood/domain/repositories/food_repository_interface.dart';

class GetAllFoods {
  final FoodRepositoryInterface repository;

  GetAllFoods(this.repository);

  Future<List<FoodEntity>> call() async {
    return await repository.getAllFoods();
  }
}
