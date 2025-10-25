import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savefood/presentation/home/cubit/home_cubit.dart';
import 'package:savefood/presentation/home/widgets/home_header.dart';
import 'package:savefood/presentation/home/widgets/category_section.dart';
import 'package:savefood/presentation/home/widgets/promo_section.dart';
import 'package:savefood/presentation/home/widgets/featured_section.dart';
import 'package:savefood/presentation/home/widgets/food_list_section.dart';
import 'package:savefood/presentation/home/widgets/top_stores_section.dart';
import 'package:savefood/presentation/foods/pages/all_foods_page.dart';
import 'package:savefood/presentation/foods/pages/all_featured_products_page.dart';
import 'package:savefood/presentation/foods/pages/food_detail_page.dart';
import 'package:savefood/presentation/store/pages/all_top_stores_page.dart';
import 'package:savefood/presentation/store/pages/store_page.dart';
import 'package:savefood/domain/entities/store_entity.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/data/model/category_model_fix.dart';
import 'package:savefood/data/model/store_model.dart';
import 'package:savefood/data/model/food_model.dart';
import 'package:savefood/data/services/Auth/auth_service.dart';
import 'package:savefood/data/services/Map/location_service.dart';
import 'package:savefood/presentation/delivery/pages/delivery_address_page.dart';

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

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  String _currentLocation = 'Đang lấy vị trí...';
  final LocationService _locationService = LocationService();
  late TabController _tabController;
  
  // Track last load time to prevent too frequent calls
  DateTime? _lastLoadTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _getCurrentLocation();
    
    // Load initial data for first tab after HomeCubit is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialTabData();
    });
  }

  void _loadInitialTabData() {
    final homeCubit = context.read<HomeCubit>();
    print('🏠 HomePage: Loading initial tab data for nearby products');
    // Ensure we load the nearby products for the first tab
    homeCubit.loadTabData('nearby');
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    
    final context = this.context;
    final homeCubit = context.read<HomeCubit>();
    
    switch (_tabController.index) {
      case 0:
        homeCubit.loadTabData('nearby');
        break;
      case 1:
        homeCubit.loadTabData('popular');
        break;
      case 2:
        homeCubit.loadTabData('rating');
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      print('🏠 HomePage: Starting to get current location...');
      setState(() {
        _currentLocation = 'Đang lấy vị trí...';
      });
      
      // Lấy address
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
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
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
                  child: SizedBox(height: 8),
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
                
                // Top Stores Section
                SliverToBoxAdapter(
                  child: TopStoresSection(
                    stores: state.topStores,
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllTopStoresPage(),
                        ),
                      );
                    },
                    onStoreTap: (store) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StorePage(
                            store: _convertStoreModelToEntity(store),
                            foods: [], // Empty list for now, will be loaded in StorePage
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                ];
              },
              body: Column(
                children: [
                  // Sticky TabBar
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TabBar(
                      controller: _tabController,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 2,
                          color: AppColor.primary,
                        ),
                      ),
                      labelColor: AppColor.primary,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Gần tôi'),
                        Tab(text: 'Bán chạy'),
                        Tab(text: 'Đánh giá'),
                      ],
                    ),
                  ),
                  
                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProductsList(state.nearbyProducts, 'nearby'),
                        _buildProductsList(state.popularProducts, 'popular'),
                        _buildProductsList(state.topRatedProducts, 'rating'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }

  StoreEntity _convertStoreModelToEntity(StoreModel store) {
    return StoreEntity(
                        id: store.id,
                        name: store.name,
                        description: store.description,
                        imageUrl: store.imageUrl,
                        rating: store.rating,
                        reviewCount: store.reviewCount,
                        deliveryTime: store.deliveryTime,
                        deliveryAddress: store.deliveryAddress,
                        distance: store.distance,
                        tags: store.tags,
                        isFavorite: store.isFavorite,
                        phoneNumber: store.phoneNumber,
                        address: store.address,
                        workingHours: store.workingHours,
                        deliveryFee: store.deliveryFee,
                        minOrderAmount: store.minOrderAmount,
                      );
  }

  Widget _buildProductsList(List<FoodModel> foods, String filterType) {
    if (foods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Đang tải dữ liệu...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Check if user has scrolled to the bottom (with some threshold)
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          // Debounce: only load if last load was more than 1 second ago
          final now = DateTime.now();
          if (_lastLoadTime == null || now.difference(_lastLoadTime!).inSeconds > 1) {
            print('🏠 HomePage: Near bottom, loading more $filterType data');
            _lastLoadTime = now;
            context.read<HomeCubit>().loadMoreTabData(filterType);
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return _buildProductCard(food);
        },
      ),
    );
  }

  Widget _buildProductCard(FoodModel food) {
    return GestureDetector(
      onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
            builder: (context) => FoodDetailPage(
              food: food,
                          ),
                        ),
                      );
                    },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Food Image
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      food.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Rating Badge
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          food.rating.toString(),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Food Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name and Discount
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (food.discountPercentage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${food.discountPercentage!.toInt()}%',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    food.description,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Distance and Time
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 10,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        food.distance,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        color: Colors.grey,
                        size: 10,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        food.deliveryTime,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: food.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CategoryModel> _getFixedCategories() {
    return [
      const CategoryModel(
        id: '1',
        name: 'Sữa',
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


