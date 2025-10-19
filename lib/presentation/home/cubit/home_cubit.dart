import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feedia/data/model/food_model.dart';
import 'package:feedia/data/model/promo_model.dart';
import 'package:feedia/data/repositories/promotion_repository_impl.dart';
import 'package:feedia/data/services/Store/Store_service.dart';
import 'package:feedia/data/services/featured_product_service.dart';
import 'package:feedia/domain/entities/promotion_entity.dart';

class HomeCubit extends Cubit<HomeState> {
  final StoreService _storeService;
  final PromotionRepositoryImpl _promotionRepository;
  final FeaturedService _featuredService;

  HomeCubit({
    StoreService? storeService,
    PromotionRepositoryImpl? promotionRepository,
    FeaturedService? featuredService,
  }) : _storeService = storeService ?? StoreService(),
       _promotionRepository = promotionRepository ?? PromotionRepositoryImpl(),
       _featuredService = featuredService ?? FeaturedService(),
       super(HomeInitial()) {
    _loadHomeData();
  }

  void _loadHomeData() async {
    emit(HomeLoading());

    try {
      // Lấy promos từ API
      final promosFuture = _promotionRepository
          .getAllPromotions()
          .catchError((_) => <PromotionEntity>[])
          .then((entities) => entities.map((entity) => _mapEntityToModel(entity)).toList());
      
      // Lấy 5 sản phẩm đầu tiên từ store ID '1' (cho phần "Hôm nay có gì?")
      final foodsFuture = _storeService
          .getStoreProducts('1', page: 1, pageSize: 5)
          .catchError((_) => <FoodModel>[]);

      // Lấy 4 sản phẩm nổi bật từ API riêng
      final featuredFuture = _featuredService
          .getFeaturedProducts(pageSize: 4)
          .catchError((_) => <FoodModel>[]);

      final results = await Future.wait([
        promosFuture,
        foodsFuture,
        featuredFuture,
      ]);

      final promos = results[0] as List<PromoModel>;
      final storeFoods = results[1] as List<FoodModel>;
      final featuredItems = results[2] as List<FoodModel>;

      print('Promos fetched: ${promos.length}');
      print('Foods fetched: ${storeFoods.length}');
      print('Featured items fetched: ${featuredItems.length}');

      // Emit với dữ liệu từ các API riêng biệt
      emit(HomeLoaded(
        promos: promos,
        foods: storeFoods,
        featuredItems: featuredItems,
      ));
    } catch (e) {
      print('Error in _loadHomeData: $e');
      // Nếu có lỗi, emit với empty lists
      emit(HomeLoaded(
        promos: [],
        foods: [],
        featuredItems: [],
      ));
    }
  }

  void onSearchChanged(String query) {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final filteredFoods = currentState.foods
          .where((food) =>
              food.name.toLowerCase().contains(query.toLowerCase()) ||
              food.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      emit(currentState.copyWith(searchQuery: query, filteredFoods: filteredFoods));
    }
  }

  void onCategorySelected(String categoryName) {
    // Handle category selection
    print('Selected category: $categoryName');
  }

  void onPromoSelected(PromoModel promo) {
    // Handle promo selection
    print('Selected promo: ${promo.title}');
  }

  void reloadData() {
    _loadHomeData();
  }

  void onFoodSelected(FoodModel food) {
    // Handle food selection
    print('Selected food: ${food.name}');
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



}

// States
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeLoaded extends HomeState {
  final List<PromoModel> promos;
  final List<FoodModel> foods;
  final List<FoodModel> featuredItems;
  final String searchQuery;
  final List<FoodModel> filteredFoods;

  HomeLoaded({
    required this.promos,
    required this.foods,
    required this.featuredItems,
    this.searchQuery = '',
    List<FoodModel>? filteredFoods,
  }) : filteredFoods = filteredFoods ?? foods;

  HomeLoaded copyWith({
    List<PromoModel>? promos,
    List<FoodModel>? foods,
    List<FoodModel>? featuredItems,
    String? searchQuery,
    List<FoodModel>? filteredFoods,
  }) {
    return HomeLoaded(
      promos: promos ?? this.promos,
      foods: foods ?? this.foods,
      featuredItems: featuredItems ?? this.featuredItems,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredFoods: filteredFoods ?? this.filteredFoods,
    );
  }
}
