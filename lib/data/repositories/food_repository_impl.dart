import 'package:feedia/domain/entities/food_entity.dart';
import 'package:feedia/domain/repositories/food_repository_interface.dart';
import 'package:feedia/data/services/api_service.dart';
import 'package:feedia/data/model/food_model.dart';

class FoodRepositoryImpl implements FoodRepositoryInterface {
  final ApiService _apiService;

  FoodRepositoryImpl({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  @override
  Future<List<FoodEntity>> getAllFoods() async {
    try {
      final foodModels = await _apiService.getFoods();
      return foodModels.map((model) => _mapToEntity(model)).toList();
    } catch (e) {
      throw Exception('Failed to fetch foods: $e');
    }
  }

  @override
  Future<List<FoodEntity>> getMainCourseFoods() async {
    try {
      final foodModels = await _apiService.getMainCourseFoods();
      // Sắp xếp theo rating giảm dần và lấy 5 sản phẩm đầu tiên
      foodModels.sort((a, b) => b.rating.compareTo(a.rating));
      final topFoods = foodModels.take(5).toList();
      return topFoods.map((model) => _mapToEntity(model)).toList();
    } catch (e) {
      throw Exception('Failed to fetch main course foods: $e');
    }
  }

  // Method để lấy tất cả foods (không giới hạn 5)
  Future<List<FoodEntity>> getAllMainCourseFoods() async {
    try {
      final foodModels = await _apiService.getMainCourseFoods();
      // Sắp xếp theo rating giảm dần nhưng không giới hạn số lượng
      foodModels.sort((a, b) => b.rating.compareTo(a.rating));
      return foodModels.map((model) => _mapToEntity(model)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all main course foods: $e');
    }
  }

  @override
  Future<FoodEntity> getFoodById(String id) async {
    try {
      // Giả sử API có endpoint này, nếu không có thể implement khác
      final foods = await _apiService.getFoods();
      final food = foods.firstWhere((f) => f.id == id);
      return _mapToEntity(food);
    } catch (e) {
      throw Exception('Failed to fetch food by id: $e');
    }
  }

  @override
  Future<List<FoodEntity>> getFoodsByCategory(String category) async {
    try {
      final foods = await _apiService.getFoods();
      final filteredFoods = foods.where((food) => food.category == category).toList();
      return filteredFoods.map((model) => _mapToEntity(model)).toList();
    } catch (e) {
      throw Exception('Failed to fetch foods by category: $e');
    }
  }

  FoodEntity _mapToEntity(FoodModel model) {
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
