import 'package:flutter/material.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/data/model/store_model.dart';
import 'package:savefood/data/services/Store/top_stores_service.dart';
import 'package:savefood/core/services/pagination_service.dart';
import 'package:savefood/domain/entities/store_entity.dart';
import 'package:savefood/presentation/store/pages/store_page.dart';

class AllTopStoresPage extends StatefulWidget {
  const AllTopStoresPage({super.key});

  @override
  State<AllTopStoresPage> createState() => _AllTopStoresPageState();
}

class _AllTopStoresPageState extends State<AllTopStoresPage> {
  final TopStoresService _topStoresService = TopStoresService();
  final ScrollController _scrollController = ScrollController();
  late PaginationService<StoreModel> _paginationService;
  
  List<StoreModel> _topStores = [];
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
    _paginationService = PaginationService<StoreModel>(
      cacheKey: 'top_stores',
      fetchData: (page, pageSize, {bool forceRefresh = false}) => _topStoresService.getAllTopStores(
        page: page,
        pageSize: pageSize,
      ),
      cacheTTL: const Duration(minutes: 30),
    );

    // Listen to streams
    _paginationService.itemsStream.listen((items) {
      if (mounted) {
        setState(() {
          _topStores = items;
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

  // Convert StoreModel to StoreEntity
  StoreEntity _convertToStoreEntity(StoreModel store) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tất cả quán hot',
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
    if (_topStores.isEmpty && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColor.primary,
        ),
      );
    }

    if (_topStores.isEmpty && _error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải quán hot',
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

    if (_topStores.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có quán hot',
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
        itemCount: _topStores.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _topStores.length) {
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

          final store = _topStores[index];
          return _buildStoreCard(store);
        },
      ),
    );
  }

  Widget _buildStoreCard(StoreModel store) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          // Navigate to store detail page
          final storeEntity = _convertToStoreEntity(store);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StorePage(
                store: storeEntity,
                foods: [], // Empty list for now, will be loaded in StorePage
              ),
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
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
              // Store Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(store.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const SizedBox.shrink(),
              ),
              
              // Store Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Store Name - Limited to 2 lines
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Store Description
                      Text(
                        store.description,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Rating and Distance (no delivery time)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.rating.toString(),
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on,
                            size: 10,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.distance,
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
