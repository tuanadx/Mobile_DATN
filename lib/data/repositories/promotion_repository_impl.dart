import 'package:savefood/domain/entities/promotion_entity.dart';
import 'package:savefood/domain/repositories/promotion_repository_interface.dart';
import 'package:savefood/data/services/promotion_api_service.dart';
import 'package:savefood/data/model/promo_model.dart';

class PromotionRepositoryImpl implements PromotionRepositoryInterface {
  final PromotionApiService _apiService;

  PromotionRepositoryImpl({PromotionApiService? apiService}) 
      : _apiService = apiService ?? PromotionApiService();

  @override
  Future<List<PromotionEntity>> getAllPromotions() async {
    try {
      final promoModels = await _apiService.getPromos();
      return promoModels.map((model) => _mapToEntity(model)).toList();
    } catch (e) {
      throw Exception('Failed to fetch promotions: $e');
    }
  }

  @override
  Future<List<PromotionEntity>> getActivePromotions() async {
    try {
      final promoModels = await _apiService.getPromos();
      // Filter only active promotions based on validUntil date
      final activePromos = promoModels.where((promo) {
        // Simple validation - in real app, you'd parse validUntil properly
        return promo.validUntil.isNotEmpty;
      }).toList();
      return activePromos.map((model) => _mapToEntity(model)).toList();
    } catch (e) {
      throw Exception('Failed to fetch active promotions: $e');
    }
  }

  @override
  Future<List<PromotionEntity>> getPromotionsByCategory(String category) async {
    try {
      final promoModels = await _apiService.getPromos();
      final filteredPromos = promoModels.where((promo) => promo.category == category).toList();
      return filteredPromos.map((model) => _mapToEntity(model)).toList();
    } catch (e) {
      throw Exception('Failed to fetch promotions by category: $e');
    }
  }

  @override
  Future<PromotionEntity> getPromotionById(String id) async {
    try {
      final promoModel = await _apiService.getPromoById(id);
      return _mapToEntity(promoModel);
    } catch (e) {
      throw Exception('Failed to fetch promotion: $e');
    }
  }

  PromotionEntity _mapToEntity(PromoModel model) {
    return PromotionEntity(
      id: model.id,
      title: model.title,
      subtitle: model.subtitle,
      description: model.description,
      discountPercentage: model.discountPercentage,
      imageUrl: model.imageUrl,
      validUntil: model.validUntil,
      minimumPurchase: model.minimumPurchase,
      category: model.category,
    );
  }
}
