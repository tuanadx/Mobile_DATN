import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feedia/data/model/food_model.dart';
import 'package:feedia/data/repositories/food_repository_impl.dart';
import 'package:feedia/domain/entities/food_entity.dart';

class AllFoodsCubit extends Cubit<AllFoodsState> {
  final FoodRepositoryImpl _foodRepository;

  AllFoodsCubit({FoodRepositoryImpl? foodRepository}) 
      : _foodRepository = foodRepository ?? FoodRepositoryImpl(),
        super(AllFoodsInitial()) {
    _loadAllFoods();
  }

  void _loadAllFoods() async {
    emit(AllFoodsLoading());
    
    try {
      print('Loading all foods...');
      final entities = await _foodRepository.getAllMainCourseFoods();
      print('Received ${entities.length} entities from repository');
      final foods = entities.map((entity) => _mapEntityToModel(entity)).toList();
      print('Converted to ${foods.length} food models');
      emit(AllFoodsLoaded(foods: foods));
    } catch (e) {
      print('Error loading foods: $e');
      // Khi có lỗi (404, network error, etc.), chỉ hiển thị empty list
      emit(AllFoodsLoaded(foods: []));
    }
  }

  void reloadFoods() {
    _loadAllFoods();
  }

  void onFoodSelected(FoodModel food) {
    // Handle food selection
    print('Selected food: ${food.name}');
  }

  // Helper method to convert FoodEntity to FoodModel
  FoodModel _mapEntityToModel(FoodEntity entity) {
    return FoodModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      rating: entity.rating,
      distance: entity.distance,
      deliveryTime: entity.deliveryTime,
      tags: entity.tags,
      discountPercentage: entity.discountPercentage,
      price: entity.price,
      category: entity.category,
      idStore: entity.idStore,
      expirationDate: entity.expirationDate,
    );
  }
}

// States
abstract class AllFoodsState {}

class AllFoodsInitial extends AllFoodsState {}

class AllFoodsLoading extends AllFoodsState {}

class AllFoodsLoaded extends AllFoodsState {
  final List<FoodModel> foods;

  AllFoodsLoaded({required this.foods});
}
