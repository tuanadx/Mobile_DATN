import 'package:flutter/material.dart';
import 'package:savefood/presentation/foods/pages/food_detail_page.dart';
import 'package:savefood/presentation/home/widgets/food_item_card.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/data/model/food_model.dart';
import 'package:savefood/data/services/Food/featured_product_service.dart';
import 'package:savefood/core/services/pagination_service.dart';

class AllFeaturedProductsPage extends StatefulWidget {
  const AllFeaturedProductsPage({super.key});

  @override
  State<AllFeaturedProductsPage> createState() => _AllFeaturedProductsPageState();
}

class _AllFeaturedProductsPageState extends State<AllFeaturedProductsPage> {
  final FeaturedService _featuredService = FeaturedService();
  final ScrollController _scrollController = ScrollController();
  late PaginationService<FoodModel> _paginationService;
  
  List<FoodModel> _featuredProducts = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePaginationService();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _paginationService.dispose();
    super.dispose();
  }

  void _initializePaginationService() {
    _paginationService = PaginationService<FoodModel>(
      cacheKey: 'featured_products',
      fetchData: (page, pageSize, {bool forceRefresh = false}) => _featuredService.getAllFeaturedProducts(
        page: page,
        pageSize: pageSize,
      ),
      cacheTTL: const Duration(minutes: 30),
    );

    // Listen to streams
    _paginationService.itemsStream.listen((items) {
      if (mounted) {
        setState(() {
          _featuredProducts = items;
        });
      }
    });

    _paginationService.loadingStream.listen((loading) {
      if (mounted) {
        setState(() {
          _isLoading = loading;
        });
      }
    });

    _paginationService.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _error = error;
        });
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    // Load first page
    _paginationService.loadFirstPage();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _paginationService.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tất cả món nổi bật',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Lọc',
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_featuredProducts.isEmpty && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColor.primary,
        ),
      );
    }

    if (_featuredProducts.isEmpty && _error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải món nổi bật',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng kiểm tra kết nối mạng',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _paginationService.refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_featuredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có món nổi bật',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy thử lại sau',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _paginationService.refresh(),
      color: AppColor.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _featuredProducts.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _featuredProducts.length) {
            // Loading indicator at the bottom
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: AppColor.primary,
                ),
              ),
            );
          }

          final food = _featuredProducts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: FoodItemCard(
              food: food,
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
            ),
          );
        },
      ),
    );
  }
}
