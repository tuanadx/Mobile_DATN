import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feedia/presentation/home/cubit/home_cubit.dart';
import 'package:feedia/presentation/home/widgets/home_header.dart';
import 'package:feedia/presentation/home/widgets/category_section.dart';
import 'package:feedia/presentation/home/widgets/promo_section.dart';
import 'package:feedia/presentation/home/widgets/featured_section.dart';
import 'package:feedia/presentation/home/widgets/food_list_section.dart';
import 'package:feedia/presentation/foods/pages/all_foods_page.dart';
import 'package:feedia/presentation/foods/pages/all_featured_products_page.dart';
import 'package:feedia/presentation/foods/pages/food_detail_page.dart';
import 'package:feedia/data/model/category_model_fix.dart';
import 'package:feedia/data/services/Auth/auth_service.dart';
import 'package:feedia/data/services/Map/location_service.dart';
import 'package:feedia/presentation/delivery/pages/delivery_address_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _currentLocation = 'Đang lấy vị trí...';
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      print('🏠 HomePage: Starting to get current location...');
      setState(() {
        _currentLocation = 'Đang lấy vị trí...';
      });
      
      String? address = await _locationService.getCurrentAddress();
      print('🏠 HomePage: Got address from service: $address');
      
      if (mounted) {
        setState(() {
          _currentLocation = address ?? 'Không thể lấy vị trí';
        });
        print('🏠 HomePage: Updated location display to: $_currentLocation');
      }
    } catch (e) {
      print('❌ HomePage: Error getting current location: $e');
      if (mounted) {
        setState(() {
          _currentLocation = 'Lỗi: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Màu nền trắng
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeCubit>().reloadData();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          
          if (state is HomeLoaded) {
            return CustomScrollView(
              slivers: [
                // Header Section
                SliverToBoxAdapter(
                  child: HomeHeader(
                    userName: AuthService.getCurrentUser()?.name ?? 'Khách',
                    userLocation: _currentLocation,
                    onLocationTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveryAddressPage(
                            currentLocation: _currentLocation,
                          ),
                        ),
                      );
                      if (result != null && result is String) {
                        setState(() {
                          _currentLocation = result;
                        });
                      }
                    },
                    onSearchChanged: (query) {
                      context.read<HomeCubit>().onSearchChanged(query);
                    },
                  ),
                ),
                
                // Spacing before Promo Section
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                
                // Promo Section
                SliverToBoxAdapter(
                  child: PromoSection(
                    promos: state.promos,
                    showHeader: false,
                    onPromoTap: (promo) {
                      context.read<HomeCubit>().onPromoSelected(promo);
                    },
                  ),
                ),
                
                // Category Section
                SliverToBoxAdapter(
                  child: CategorySection(
                    categories: _getFixedCategories(),
                    onSeeAllTap: () {
                      // Handle see all categories
                    },
                    onCategoryTap: (category) {
                      context.read<HomeCubit>().onCategorySelected(category.name);
                    },
                  ),
                ),
                
                // Featured Section
                SliverToBoxAdapter(
                  child: FeaturedSection(
                    featuredItems: state.featuredItems,
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllFeaturedProductsPage(),
                        ),
                      );
                    },
                    onItemTap: (item) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailPage(
                            food: item,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Food List Section
                SliverToBoxAdapter(
                  child: FoodListSection(
                    foods: state.filteredFoods.take(5).toList(),
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllFoodsPage(storeId: '1'),
                        ),
                      );
                    },
                    onFoodTap: (food) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailPage(
                            food: food,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            );
          }
          
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }

  List<CategoryModel> _getFixedCategories() {
    return [
      const CategoryModel(
        id: '1',
        name: 'SữaSữa',
        iconPath: 'assets/icons/categories/milk-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '2',
        name: 'Bánh Kẹo',
        iconPath: 'assets/icons/categories/fries-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '3',
        name: 'Đồ Hộp',
        iconPath: 'assets/icons/categories/canned-food-tuna-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '4',
        name: 'Phụ Gia',
        iconPath: 'assets/icons/categories/pepper-spice-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '5',
        name: 'Rau Củ',
        iconPath: 'assets/icons/categories/leafy-green-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '6',
        name: 'Trái Cây',
        iconPath: 'assets/icons/categories/watermelon-1-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '7',
        name: 'Hải Sản',
        iconPath: 'assets/icons/categories/fish-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '8',
        name: 'Thịt',
        iconPath: 'assets/icons/categories/steak-svgrepo-com.svg',
      ),
      // Thêm categories cho trang thứ 2
      const CategoryModel(
        id: '9',
        name: 'Đông Lạnh',
        iconPath: 'assets/icons/categories/winter-ice-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '10',
        name: 'Trái Cây',
        iconPath: 'assets/icons/categories/watermelon-1-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '11',
        name: 'Thịt Nướng',
        iconPath: 'assets/icons/categories/steak-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '12',
        name: 'Hải Sản',
        iconPath: 'assets/icons/categories/fish-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '13',
        name: 'Rau Xanh',
        iconPath: 'assets/icons/categories/leafy-green-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '14',
        name: 'Gia Vị',
        iconPath: 'assets/icons/categories/pepper-spice-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '15',
        name: 'Đồ Hộp',
        iconPath: 'assets/icons/categories/canned-food-tuna-svgrepo-com.svg',
      ),
      const CategoryModel(
        id: '16',
        name: 'Kem Lạnh',
        iconPath: 'assets/icons/categories/winter-ice-svgrepo-com.svg',
      ),
    ];
  }
}
