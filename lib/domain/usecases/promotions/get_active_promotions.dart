import 'package:savefood/domain/entities/promotion_entity.dart';
import 'package:savefood/domain/repositories/promotion_repository_interface.dart';

class GetActivePromotions {
  final PromotionRepositoryInterface repository;

  GetActivePromotions(this.repository);

  Future<List<PromotionEntity>> call() async {
    return await repository.getActivePromotions();
  }
}
