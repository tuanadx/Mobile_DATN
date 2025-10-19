import 'package:feedia/domain/entities/store_entity.dart';
import 'package:feedia/domain/entities/food_entity.dart';
import 'package:feedia/domain/repositories/store_repository_interface.dart';
import 'package:feedia/data/services/Store/Store_service.dart';
import 'package:feedia/data/model/food_model.dart';

class StoreRepositoryImpl implements StoreRepositoryInterface {
  final StoreService _storeService;

  StoreRepositoryImpl({StoreService? storeService})
      : _storeService = storeService ?? StoreService();

  @override
  Future<StoreEntity> getStoreById(String storeId) async {
    final model = await _storeService.getStore(storeId);
    return model.toEntity();
  }

  @override
  Future<List<String>> getStoreCategories(String storeId) async {
    return _storeService.getStoreCategories(storeId);
  }

  @override
  Future<List<FoodEntity>> getStoreProducts(
    String storeId, {
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final models = await _storeService.getStoreProducts(
      storeId,
      categoryId: categoryId,
      page: page,
      pageSize: pageSize,
    );
    return models.map(_mapFoodToEntity).toList();
  }

  FoodEntity _mapFoodToEntity(FoodModel model) {
    return FoodEntity(
      id: model.id,
      idStore: model.idStore,
      name: model.name,
      description: model.description,
      imageUrl: model.imageUrl,
      rating: model.rating,
      distance: model.distance,
      deliveryTime: model.deliveryTime,
      tags: model.tags,
      discountPercentage: model.discountPercentage,
      price: model.price,
      category: model.category,
      expirationDate: model.expirationDate,
    );
  }
}


