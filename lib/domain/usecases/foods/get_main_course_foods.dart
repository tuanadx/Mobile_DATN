import 'package:savefood/domain/entities/food_entity.dart';
import 'package:savefood/domain/repositories/food_repository_interface.dart';

class GetMainCourseFoods {
  final FoodRepositoryInterface repository;

  GetMainCourseFoods(this.repository);

  Future<List<FoodEntity>> call() async {
    return await repository.getMainCourseFoods();
  }
}
