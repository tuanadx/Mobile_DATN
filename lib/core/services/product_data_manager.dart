import 'package:feedia/data/model/food_model.dart';
import 'package:feedia/data/services/Store/Store_service.dart';
import 'package:feedia/core/services/cache_manager.dart';
import 'package:feedia/core/services/pagination_service.dart';

class ProductDataManager {
  static final ProductDataManager _instance = ProductDataManager._internal();
  factory ProductDataManager() => _instance;
  ProductDataManager._internal();

  final StoreService _storeService = StoreService();
  final CacheManager _cacheManager = CacheManager();
  
  // Pagination services cho các danh sách khác nhau
  final Map<String, PaginationService<FoodModel>> _paginationServices = {};

  /// Lấy pagination service cho danh sách sản phẩm của store
  PaginationService<FoodModel> getStoreProductsPagination(String storeId) {
    final key = 'store_products_$storeId';
    
    if (!_paginationServices.containsKey(key)) {
      _paginationServices[key] = PaginationService<FoodModel>(
        cacheKey: key,
        fetchData: (page, pageSize) => _fetchStoreProducts(storeId, page, pageSize),
        cacheTTL: const Duration(minutes: 30),
      );
    }
    
    return _paginationServices[key]!;
  }

  /// Lấy pagination service cho danh sách sản phẩm theo category
  PaginationService<FoodModel> getCategoryProductsPagination(String storeId, String categoryId) {
    final key = 'category_products_${storeId}_$categoryId';
    
    if (!_paginationServices.containsKey(key)) {
      _paginationServices[key] = PaginationService<FoodModel>(
        cacheKey: key,
        fetchData: (page, pageSize) => _fetchCategoryProducts(storeId, categoryId, page, pageSize),
        cacheTTL: const Duration(minutes: 30),
      );
    }
    
    return _paginationServices[key]!;
  }

  /// Fetch sản phẩm của store với pagination
  Future<List<FoodModel>> _fetchStoreProducts(String storeId, int page, int pageSize) async {
    try {
      // Kiểm tra cache trước
      final cacheKey = 'store_products_${storeId}_page_$page';
      final cachedData = _cacheManager.getCache<List<FoodModel>>(cacheKey);
      
      if (cachedData != null) {
        return cachedData;
      }

      // Gọi API nếu không có cache
      final products = await _storeService.getStoreProducts(
        storeId,
        page: page,
        pageSize: pageSize,
      );

      // Lưu vào cache
      _cacheManager.setCache(cacheKey, products, ttl: const Duration(minutes: 30));
      
      return products;
    } catch (e) {
      print('❌ Error fetching store products for store $storeId: $e');
      throw Exception('Failed to fetch store products: $e');
    }
  }

  /// Fetch sản phẩm theo category với pagination
  Future<List<FoodModel>> _fetchCategoryProducts(String storeId, String categoryId, int page, int pageSize) async {
    try {
      // Kiểm tra cache trước
      final cacheKey = 'category_products_${storeId}_${categoryId}_page_$page';
      final cachedData = _cacheManager.getCache<List<FoodModel>>(cacheKey);
      
      if (cachedData != null) {
        return cachedData;
      }

      // Gọi API nếu không có cache
      final products = await _storeService.getStoreProducts(
        storeId,
        categoryId: categoryId,
        page: page,
        pageSize: pageSize,
      );

      // Lưu vào cache
      _cacheManager.setCache(cacheKey, products, ttl: const Duration(minutes: 30));
      
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
    _cacheManager.cleanExpiredCache();
  }

  /// Xóa tất cả cache
  void clearAllCache() {
    _cacheManager.clearCache();
    _paginationServices.clear();
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
    return _cacheManager.getCacheInfo();
  }
}
