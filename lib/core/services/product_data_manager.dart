import 'package:savefood/data/model/food_model.dart';
import 'package:savefood/data/services/Store/Store_service.dart';
import 'package:savefood/core/services/pagination_service.dart';

class ProductDataManager {
  static final ProductDataManager _instance = ProductDataManager._internal();
  factory ProductDataManager() => _instance;
  ProductDataManager._internal();

  final StoreService _storeService = StoreService();
  
  // Pagination services cho các danh sách khác nhau
  final Map<String, PaginationService<FoodModel>> _paginationServices = {};

  /// Lấy pagination service cho danh sách sản phẩm của store
  PaginationService<FoodModel> getStoreProductsPagination(String storeId) {
    final key = 'store_products_$storeId';
    
    print('🔍 Getting pagination service for store: $storeId');
    
    if (!_paginationServices.containsKey(key)) {
      print('🆕 Creating new pagination service for store: $storeId');
      _paginationServices[key] = PaginationService<FoodModel>(
        cacheKey: key,
        fetchData: (page, pageSize, {bool forceRefresh = false}) => _fetchStoreProducts(storeId, page, pageSize, forceRefresh: forceRefresh),
        cacheTTL: const Duration(minutes: 30),
      );
    } else {
      print('♻️ Reusing existing pagination service for store: $storeId');
    }
    
    return _paginationServices[key]!;
  }

  /// Force refresh cache cho store products
  void clearStoreProductsCache(String storeId) {
    print('🗑️ Clearing cache for store: $storeId');
    // Cache sẽ được quản lý bởi dio_cache_interceptor
    // Không cần xóa cache thủ công nữa
  }

  /// Lấy pagination service cho danh sách sản phẩm theo category
  PaginationService<FoodModel> getCategoryProductsPagination(String storeId, String categoryId) {
    final key = 'category_products_${storeId}_$categoryId';
    
    if (!_paginationServices.containsKey(key)) {
      _paginationServices[key] = PaginationService<FoodModel>(
        cacheKey: key,
        fetchData: (page, pageSize, {bool forceRefresh = false}) => _fetchCategoryProducts(storeId, categoryId, page, pageSize),
        cacheTTL: const Duration(minutes: 30),
      );
    }
    
    return _paginationServices[key]!;
  }

  /// Fetch sản phẩm của store với pagination
  Future<List<FoodModel>> _fetchStoreProducts(String storeId, int page, int pageSize, {bool forceRefresh = false}) async {
    try {
      print('🌐 Fetching data for store $storeId, page $page, forceRefresh: $forceRefresh');
      
      // Gọi API với forceRefresh parameter
      final products = await _storeService.getStoreProducts(
        storeId,
        page: page,
        pageSize: pageSize,
        forceRefresh: forceRefresh,
      );

      print('✅ Fetched ${products.length} products for store $storeId, page $page');
      
      return products;
    } catch (e) {
      print('❌ Error fetching store products for store $storeId: $e');
      throw Exception('Failed to fetch store products: $e');
    }
  }

  /// Fetch sản phẩm theo category với pagination
  Future<List<FoodModel>> _fetchCategoryProducts(String storeId, String categoryId, int page, int pageSize) async {
    try {
      print('🌐 Fetching category products for store $storeId, category $categoryId, page $page');
      
      // Gọi API - cache sẽ được quản lý bởi dio_cache_interceptor
      final products = await _storeService.getStoreProducts(
        storeId,
        categoryId: categoryId,
        page: page,
        pageSize: pageSize,
      );

      print('✅ Fetched ${products.length} category products for store $storeId, category $categoryId, page $page');
      
      return products;
    } catch (e) {
      print('❌ Error fetching category products for store $storeId, category $categoryId: $e');
      throw Exception('Failed to fetch category products: $e');
    }
  }


  /// Preload dữ liệu quan trọng khi app khởi động
  Future<void> preloadImportantData() async {
    try {
      // Preload danh sách sản phẩm của các store phổ biến
      final popularStoreIds = ['1', '2', '3'];
      
      for (final storeId in popularStoreIds) {
        final pagination = getStoreProductsPagination(storeId);
        await pagination.loadFirstPage();
      }
    } catch (e) {
      print('Error preloading data: $e');
    }
  }

  /// Làm sạch cache hết hạn
  void cleanExpiredCache() {
    // Cache được quản lý bởi dio_cache_interceptor
    print('🗑️ Cache is managed by dio_cache_interceptor');
  }

  /// Xóa tất cả cache
  void clearAllCache() {
    // Cache được quản lý bởi dio_cache_interceptor
    _paginationServices.clear();
    print('🗑️ Pagination services cleared, cache is managed by dio_cache_interceptor');
  }

  /// Dispose tất cả pagination services
  void dispose() {
    for (final service in _paginationServices.values) {
      service.dispose();
    }
    _paginationServices.clear();
  }

  /// Lấy thông tin cache
  Map<String, dynamic> getCacheInfo() {
    return {
      'cacheType': 'dio_cache_interceptor',
      'paginationServices': _paginationServices.length,
    };
  }
}
