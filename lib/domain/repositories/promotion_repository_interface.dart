import 'package:feedia/domain/entities/promotion_entity.dart';

abstract class PromotionRepositoryInterface {
  Future<List<PromotionEntity>> getAllPromotions();
  Future<List<PromotionEntity>> getActivePromotions();
  Future<List<PromotionEntity>> getPromotionsByCategory(String category);
  Future<PromotionEntity> getPromotionById(String id);
}
