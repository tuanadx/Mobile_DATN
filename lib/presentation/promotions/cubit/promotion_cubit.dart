import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feedia/data/model/promo_model.dart';
import 'package:feedia/data/repositories/promotion_repository_impl.dart';
import 'package:feedia/domain/entities/promotion_entity.dart';

class PromotionCubit extends Cubit<PromotionState> {
  final PromotionRepositoryImpl _promotionRepository;

  PromotionCubit({PromotionRepositoryImpl? promotionRepository}) 
      : _promotionRepository = promotionRepository ?? PromotionRepositoryImpl(),
        super(PromotionInitial()) {
    _loadPromotions();
  }

  void _loadPromotions() async {
    emit(PromotionLoading());
    
    try {
      final entities = await _promotionRepository.getAllPromotions();
      final promotions = entities.map((entity) => _mapEntityToModel(entity)).toList();
      emit(PromotionLoaded(promotions: promotions));
    } catch (e) {
      emit(PromotionError('Failed to load promotions: $e'));
      _loadMockPromotions();
    }
  }

  void loadActivePromotions() async {
    emit(PromotionLoading());
    
    try {
      final entities = await _promotionRepository.getActivePromotions();
      final promotions = entities.map((entity) => _mapEntityToModel(entity)).toList();
      emit(PromotionLoaded(promotions: promotions));
    } catch (e) {
      emit(PromotionError('Failed to load active promotions: $e'));
      _loadMockPromotions();
    }
  }

  void loadPromotionsByCategory(String category) async {
    emit(PromotionLoading());
    
    try {
      final entities = await _promotionRepository.getPromotionsByCategory(category);
      final promotions = entities.map((entity) => _mapEntityToModel(entity)).toList();
      emit(PromotionLoaded(promotions: promotions));
    } catch (e) {
      emit(PromotionError('Failed to load promotions by category: $e'));
      _loadMockPromotions();
    }
  }

  void reloadPromotions() {
    _loadPromotions();
  }

  void onPromoSelected(PromoModel promo) {
    // Handle promo selection
    print('Selected promo: ${promo.title}');
  }

  // Helper method to convert PromotionEntity to PromoModel
  PromoModel _mapEntityToModel(PromotionEntity entity) {
    return PromoModel(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      description: entity.description,
      discountPercentage: entity.discountPercentage,
      imageUrl: entity.imageUrl,
      validUntil: entity.validUntil,
      minimumPurchase: entity.minimumPurchase,
      category: entity.category,
    );
  }

  void _loadMockPromotions() {
    final promotions = _getMockPromotions();
    emit(PromotionLoaded(promotions: promotions));
  }

  List<PromoModel> _getMockPromotions() {
    return [
      const PromoModel(
        id: '1',
        title: 'FAMILY PACKAGE PROMO',
        subtitle: 'DISC 70%',
        description: 'Special family package',
        discountPercentage: 70,
        imageUrl: 'https://img1.kienthucvui.vn/uploads/2019/10/30/hinh-anh-rau-cu-qua-sach_112153720.jpg',
        validUntil: 'ALL DAY AT 7AM',
        category: 'family',
      ),
      const PromoModel(
        id: '2',
        title: 'FREE DELIVERY',
        subtitle: '1-31 JAN',
        description: 'Free delivery promotion',
        discountPercentage: 100,
        imageUrl: 'assets/images/free_delivery.png',
        validUntil: '1-31 JAN',
        minimumPurchase: 'MINIMUM PURCHASE',
        category: 'delivery',
      ),
    ];
  }
}

// States
abstract class PromotionState {}

class PromotionInitial extends PromotionState {}

class PromotionLoading extends PromotionState {}

class PromotionError extends PromotionState {
  final String message;
  PromotionError(this.message);
}

class PromotionLoaded extends PromotionState {
  final List<PromoModel> promotions;

  PromotionLoaded({required this.promotions});
}
