import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savefood/data/model/food_model.dart';
import 'package:savefood/data/model/promo_model.dart';
import 'package:savefood/data/model/store_model.dart';
import 'package:savefood/data/repositories/promotion_repository_impl.dart';
import 'package:savefood/data/services/Store/Store_service.dart';
import 'package:savefood/data/services/Food/featured_product_service.dart';
import 'package:savefood/data/services/Store/top_stores_service.dart';
import 'package:savefood/data/services/Food/products_tab_service.dart';
import 'package:savefood/domain/entities/promotion_entity.dart';

class HomeCubit extends Cubit<HomeState> {
  final StoreService _storeService;
  final PromotionRepositoryImpl _promotionRepository;
  final FeaturedService _featuredService;
  final TopStoresService _topStoresService;
  final ProductsTabService _productsTabService;
  
  // Track loading states for pagination
  bool _isLoadingMore = false;

  HomeCubit({
    StoreService? storeService,
    PromotionRepositoryImpl? promotionRepository,
    FeaturedService? featuredService,
    TopStoresService? topStoresService,
    ProductsTabService? productsTabService,
  }) : _storeService = storeService ?? StoreService(),
       _promotionRepository = promotionRepository ?? PromotionRepositoryImpl(),
       _featuredService = featuredService ?? FeaturedService(),
       _topStoresService = topStoresService ?? TopStoresService(),
       _productsTabService = productsTabService ?? ProductsTabService(),
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

      // Lấy 5 top stores
      final topStoresFuture = _topStoresService
          .getTopStores(pageSize: 5)
          .catchError((_) => <StoreModel>[]);

      final results = await Future.wait([
        promosFuture,
        foodsFuture,
        featuredFuture,
        topStoresFuture,
      ]);

      final promos = results[0] as List<PromoModel>;
      final storeFoods = results[1] as List<FoodModel>;
      final featuredItems = results[2] as List<FoodModel>;
      final topStores = results[3] as List<StoreModel>;

      print('Promos fetched: ${promos.length}');
      print('Foods fetched: ${storeFoods.length}');
      print('Featured items fetched: ${featuredItems.length}');
      print('Top stores fetched: ${topStores.length}');

      // Emit với dữ liệu từ các API riêng biệt
      emit(HomeLoaded(
        promos: promos,
        foods: storeFoods,
        featuredItems: featuredItems,
        topStores: topStores,
        nearbyProducts: [], // Initialize empty
        popularProducts: [], // Initialize empty
        topRatedProducts: [], // Initialize empty
      ));
      
      // Auto-load nearby products for the first tab after main data is loaded
      print('🔄 HomeCubit: Auto-loading nearby products after main data loaded');
      loadTabData('nearby');
    } catch (e) {
      print('Error in _loadHomeData: $e');
      // Nếu có lỗi, emit với empty lists
      emit(HomeLoaded(
        promos: [],
        foods: [],
        featuredItems: [],
        topStores: [],
        nearbyProducts: [],
        popularProducts: [],
        topRatedProducts: [],
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

  // Load data for specific tab
  void loadTabData(String tabType, {bool isLoadMore = false}) async {
    final currentState = state;
    if (currentState is! HomeLoaded) {
      print('❌ HomeCubit: Cannot load tab data, state is not HomeLoaded: ${currentState.runtimeType}');
      return;
    }

    print('🔄 HomeCubit: Loading $tabType data... (isLoadMore: $isLoadMore)');
    
    // Set loading state for pagination
    if (isLoadMore) {
      _isLoadingMore = true;
    }
    
    try {
      List<FoodModel> newData = [];
      List<FoodModel> currentData = [];
      int currentPage = 1;
      
      // Get current data and calculate next page
      switch (tabType) {
        case 'nearby':
          currentData = currentState.nearbyProducts;
          currentPage = (currentData.length ~/ 10) + 1;
          newData = await _productsTabService.getNearbyProducts(page: currentPage, pageSize: 10);
          break;
        case 'popular':
          currentData = currentState.popularProducts;
          currentPage = (currentData.length ~/ 10) + 1;
          newData = await _productsTabService.getPopularProducts(page: currentPage, pageSize: 10);
          break;
        case 'rating':
          currentData = currentState.topRatedProducts;
          currentPage = (currentData.length ~/ 10) + 1;
          newData = await _productsTabService.getTopRatedProducts(page: currentPage, pageSize: 10);
          break;
        default:
          print('❌ HomeCubit: Unknown tab type: $tabType');
          return;
      }
      
      // Combine with existing data if loading more, otherwise replace
      List<FoodModel> finalData = isLoadMore ? [...currentData, ...newData] : newData;
      
      print('✅ HomeCubit: Loaded ${newData.length} new $tabType products (total: ${finalData.length})');
      
      switch (tabType) {
        case 'nearby':
          emit(currentState.copyWith(nearbyProducts: finalData));
          break;
        case 'popular':
          emit(currentState.copyWith(popularProducts: finalData));
          break;
        case 'rating':
          emit(currentState.copyWith(topRatedProducts: finalData));
          break;
      }
    } catch (e) {
      print('❌ HomeCubit: Error loading $tabType data: $e');
      // Keep current state if error occurs
    } finally {
      // Reset loading state
      if (isLoadMore) {
        _isLoadingMore = false;
      }
    }
  }

  // Load more data for specific tab (pagination)
  void loadMoreTabData(String tabType) {
    if (_isLoadingMore) {
      print('🔄 HomeCubit: Already loading more data, skipping...');
      return;
    }
    loadTabData(tabType, isLoadMore: true);
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
  final List<StoreModel> topStores;
  final String searchQuery;
  final List<FoodModel> filteredFoods;
  
  // Tab data
  final List<FoodModel> nearbyProducts;
  final List<FoodModel> popularProducts;
  final List<FoodModel> topRatedProducts;

  HomeLoaded({
    required this.promos,
    required this.foods,
    required this.featuredItems,
    required this.topStores,
    this.searchQuery = '',
    List<FoodModel>? filteredFoods,
    this.nearbyProducts = const [],
    this.popularProducts = const [],
    this.topRatedProducts = const [],
  }) : filteredFoods = filteredFoods ?? foods;

  HomeLoaded copyWith({
    List<PromoModel>? promos,
    List<FoodModel>? foods,
    List<FoodModel>? featuredItems,
    List<StoreModel>? topStores,
    String? searchQuery,
    List<FoodModel>? filteredFoods,
    List<FoodModel>? nearbyProducts,
    List<FoodModel>? popularProducts,
    List<FoodModel>? topRatedProducts,
  }) {
    return HomeLoaded(
      promos: promos ?? this.promos,
      foods: foods ?? this.foods,
      featuredItems: featuredItems ?? this.featuredItems,
      topStores: topStores ?? this.topStores,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredFoods: filteredFoods ?? this.filteredFoods,
      nearbyProducts: nearbyProducts ?? this.nearbyProducts,
      popularProducts: popularProducts ?? this.popularProducts,
      topRatedProducts: topRatedProducts ?? this.topRatedProducts,
    );
  }
}
