import 'package:flutter/material.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/domain/entities/food_entity.dart';
import 'package:savefood/domain/entities/store_entity.dart';
import 'package:savefood/data/model/food_model.dart';
import 'package:savefood/data/model/category_model_fix.dart';
import 'package:savefood/data/services/Store/Store_service.dart';
import 'package:savefood/presentation/foods/pages/food_detail_page.dart';
import 'package:savefood/presentation/foods/pages/all_foods_page.dart';

class StorePage extends StatefulWidget {
  final StoreEntity store;
  final List<FoodEntity> foods;

  const StorePage({
    super.key,
    required this.store,
    required this.foods,
  });

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool _isFavorite = false;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = false;
  late List<FoodEntity> _popularFoods;
  late List<FoodEntity> _flashSaleFoods;
  List<CategoryModel> _categories = [];
  String _selectedCategoryId = '';
  final StoreService _storeService = StoreService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _isFavorite = widget.store.isFavorite;
    _filterFoods();
    _loadStoreCategories();
    _loadPopularFoods();
  }

  void _filterFoods() {
    // Lọc món ăn theo idStore
    final storeFoods = widget.foods.where((food) => food.idStore == widget.store.id).toList();
    
    // Sắp xếp theo rating để lấy món phổ biến
    _popularFoods = List.from(storeFoods)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    
    // Lấy món có discount để làm flash sale
    _flashSaleFoods = storeFoods.where((food) => food.discountPercentage != null && food.discountPercentage! > 0).toList();
  }

  Future<void> _loadStoreCategories() async {
    try {
      // Lấy categories từ API của cửa hàng
      final categoryNames = await _storeService.getStoreCategories(widget.store.id);
      
      // Tạo CategoryModel từ danh sách tên categories
      final categories = [
        const CategoryModel(id: 'all', name: 'Tất cả', iconPath: ''),
        ...categoryNames.map((name) => CategoryModel(
          id: name.toLowerCase().replaceAll(' ', '_'),
          name: name,
          iconPath: '',
        )),
      ];
      
      setState(() {
        _categories = categories;
        _selectedCategoryId = 'all';
      });
    } catch (e) {
      print('Error loading store categories: $e');
      // Fallback với mock data nếu API lỗi
      final mockCategories = [
        const CategoryModel(id: 'all', name: 'Tất cả', iconPath: ''),
        const CategoryModel(id: '1', name: 'Món chính', iconPath: ''),
        const CategoryModel(id: '2', name: 'Món phụ', iconPath: ''),
        const CategoryModel(id: '3', name: 'Đồ uống', iconPath: ''),
        const CategoryModel(id: '4', name: 'Tráng miệng', iconPath: ''),
      ];
      
      setState(() {
        _categories = mockCategories;
        _selectedCategoryId = 'all';
      });
    }
  }

  Future<void> _loadPopularFoods() async {
    try {
      // Lấy 5 sản phẩm phổ biến từ API của cửa hàng
      final popularFoods = await _storeService.getStoreProducts(
        widget.store.id,
        page: 1,
        pageSize: 5,
      );
      
      // Convert FoodModel to FoodEntity
      final foodEntities = popularFoods.map((food) => FoodEntity(
        id: food.id,
        idStore: food.idStore,
        name: food.name,
        description: food.description,
        imageUrl: food.imageUrl,
        rating: food.rating,
        distance: food.distance,
        deliveryTime: food.deliveryTime,
        tags: food.tags,
        discountPercentage: food.discountPercentage,
        price: food.price,
        category: food.category,
        expirationDate: food.expirationDate,
      )).toList();
      
      setState(() {
        _popularFoods = foodEntities;
      });
    } catch (e) {
      print('Error loading popular foods: $e');
      // Fallback với dữ liệu hiện có
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 200) {
      if (!_showAppBar) {
        setState(() {
          _showAppBar = true;
        });
      }
    } else {
      if (_showAppBar) {
        setState(() {
          _showAppBar = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper method to convert FoodEntity to FoodModel
  FoodModel _convertToFoodModel(FoodEntity entity) {
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

  // Helper method to get product count for each category
  int _getProductCountForCategory(String categoryId) {
    if (categoryId == 'all') {
      return _popularFoods.length;
    }
    
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => const CategoryModel(id: '', name: '', iconPath: ''),
    );
    
    if (category.id.isEmpty) return 0;
    
    return _popularFoods.where((food) => food.category == category.name).length;
  }

  // Show categories modal overlay
  void _showCategoriesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'TẤT CẢ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Categories List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final productCount = _getProductCountForCategory(category.id);
                  final isSelected = category.id == _selectedCategoryId;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.primary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColor.primary : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category.id;
                        });
                        Navigator.pop(context);
                      },
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColor.primary : Colors.black,
                        ),
                      ),
                      trailing: productCount > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColor.primary.withOpacity(0.2)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '($productCount)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColor.primary : Colors.grey[600],
                                ),
                              ),
                            )
                          : null,
                      leading: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColor.primary,
                              size: 20,
                            )
                          : Icon(
                              Icons.radio_button_unchecked,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Section với ảnh quán
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  maxWidth: 32,
                  minHeight: 32,
                  maxHeight: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  maxWidth: 32,
                  minHeight: 32,
                  maxHeight: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.store.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
              ),
            ),
          ),
          
          // Store Info Section - Tên quán và số sao
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store name (giới hạn 2 dòng)
                  Text(
                    widget.store.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating and reviews
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < widget.store.rating.floor() ? Colors.amber : Colors.grey[300],
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.store.rating} (${widget.store.reviewCount}+ Bình luận)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Popular Items Section
          SliverToBoxAdapter(
            child: _buildPopularItemsSection(),
          ),
          
          // Categories Section
          SliverToBoxAdapter(
            child: _buildCategoriesSection(),
          ),
          
          // Category Products Sections
          ..._buildCategoryProductsSections(),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
                'TẤT CẢ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
              GestureDetector(
                onTap: () {
                  _showCategoriesModal(context);
                },
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
          
          // Horizontal scrollable categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category.id == _selectedCategoryId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColor.primary : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
        ],
      ),
    );
  }


  Widget _buildPopularItemsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Món phổ biến',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _popularFoods.take(5).length,
              itemBuilder: (context, index) {
                final food = _popularFoods[index];
                return _buildFoodItemCard(
                  name: food.name,
                  image: food.imageUrl,
                  originalPrice: food.price,
                  discountedPrice: food.discountPercentage != null 
                      ? food.price * (1 - food.discountPercentage! / 100)
                      : food.price,
                  soldCount: 10000, // Có thể thêm field này vào FoodEntity sau
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFlashSaleItem(FoodEntity food) {
    final discountedPrice = food.discountPercentage != null 
        ? food.price * (1 - food.discountPercentage! / 100)
        : food.price;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              food.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  food.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${food.rating}⭐ | ${food.deliveryTime} | Còn ${(10 + food.id.hashCode % 5)} phần',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${discountedPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                    if (food.discountPercentage != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${food.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'GIẢM ${food.discountPercentage?.toInt() ?? 0}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemCard({
    required String name,
    required String image,
    required double originalPrice,
    required double discountedPrice,
    required int soldCount,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image,
                  width: 160,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 160,
                      height: 140,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(soldCount / 1000).toStringAsFixed(0)}K+ đã bán',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${discountedPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              if (discountedPrice < originalPrice) ...[
                const SizedBox(width: 4),
                Text(
                  '${originalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryProductsSections() {
    return _categories.where((category) => category.id != 'all').map((category) {
      return SliverToBoxAdapter(
        child: _buildCategorySection(category),
      );
    }).toList();
  }

  Widget _buildCategorySection(CategoryModel category) {
    // Lọc sản phẩm theo category từ danh sách hiện có
    final categoryFoods = _popularFoods.where((food) => 
      food.category == category.name
    ).take(5).toList();

    if (categoryFoods.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllFoodsPage(storeId: widget.store.id),
                    ),
                  );
                },
                child: Text(
                  'Xem tất cả >',
                  style: TextStyle(color: AppColor.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...categoryFoods.map((food) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          food.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ...List.generate(5, (i) => Icon(
                                  i < food.rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                )),
                                const SizedBox(width: 4),
                                Text(
                                  '${food.rating}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${food.price.toStringAsFixed(0)}đ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                if (food.discountPercentage != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(food.price * (1 + food.discountPercentage! / 100)).toStringAsFixed(0)}đ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodDetailPage(
                          food: _convertToFoodModel(food),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColor.primary, Color(0xFFA4C3A2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
          )).toList(),
        ],
      ),
    );
  }
}
