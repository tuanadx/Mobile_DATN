import 'package:savefood/domain/entities/promotion_entity.dart';
import 'package:savefood/domain/repositories/promotion_repository_interface.dart';

class GetAllPromotions {
  final PromotionRepositoryInterface repository;

  GetAllPromotions(this.repository);

  Future<List<PromotionEntity>> call() async {
    return await repository.getAllPromotions();
  }
}
