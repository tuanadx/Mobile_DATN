import 'package:feedia/domain/entities/store_entity.dart';
import 'package:feedia/domain/entities/food_entity.dart';

abstract class StoreRepositoryInterface {
  Future<StoreEntity> getStoreById(String storeId);

  Future<List<String>> getStoreCategories(String storeId);

  Future<List<FoodEntity>> getStoreProducts(
    String storeId, {
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  });
}


