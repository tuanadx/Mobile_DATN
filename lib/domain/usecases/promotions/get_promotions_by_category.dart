import 'package:feedia/domain/entities/promotion_entity.dart';
import 'package:feedia/domain/repositories/promotion_repository_interface.dart';

class GetPromotionsByCategory {
  final PromotionRepositoryInterface repository;

  GetPromotionsByCategory(this.repository);

  Future<List<PromotionEntity>> call(String category) async {
    return await repository.getPromotionsByCategory(category);
  }
}
