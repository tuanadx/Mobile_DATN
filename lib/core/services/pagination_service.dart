import 'dart:async';

class PaginationService<T> {
  final Future<List<T>> Function(int page, int pageSize, {bool forceRefresh}) fetchData;
  final String cacheKey;
  final Duration cacheTTL;
  
  List<T> _items = [];
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoading = false;
  String? _error;
  
  // Stream controllers để notify UI
  final StreamController<List<T>> _itemsController = StreamController<List<T>>.broadcast();
  final StreamController<bool> _loadingController = StreamController<bool>.broadcast();
  final StreamController<String?> _errorController = StreamController<String?>.broadcast();
  
  // Getters
  List<T> get items => List.unmodifiable(_items);
  int get currentPage => _currentPage;
  bool get hasMoreData => _hasMoreData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Streams
  Stream<List<T>> get itemsStream => _itemsController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;
  
  PaginationService({
    required this.fetchData,
    required this.cacheKey,
    this.cacheTTL = const Duration(minutes: 30),
  });

  /// Load trang đầu tiên
  Future<void> loadFirstPage({bool forceRefresh = false}) async {
    if (_isLoading) return;
    
    _currentPage = 1;
    _hasMoreData = true;
    _error = null;
    
    await _loadPage(_currentPage, isFirstPage: true, forceRefresh: forceRefresh);
  }

  /// Load trang tiếp theo
  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMoreData) return;
    
    _currentPage++;
    await _loadPage(_currentPage, isFirstPage: false);
  }

  /// Load trang cụ thể
  Future<void> loadPage(int page) async {
    if (_isLoading) return;
    
    _currentPage = page;
    await _loadPage(_currentPage, isFirstPage: page == 1);
  }

  /// Refresh dữ liệu
  Future<void> refresh() async {
    _items.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _error = null;
    
    print('🔄 Refresh: Cleared items, loading fresh data...');
    await loadFirstPage(forceRefresh: true);
  }

  /// Load dữ liệu cho trang
  Future<void> _loadPage(int page, {required bool isFirstPage, bool forceRefresh = false}) async {
    _isLoading = true;
    _loadingController.add(_isLoading);
    
    print('📡 Loading page $page, isFirstPage: $isFirstPage, forceRefresh: $forceRefresh');
    
    try {
      // Tạo một function signature mới để truyền forceRefresh
      final newItems = await _fetchDataWithForceRefresh(page, 20, forceRefresh);
      
      print('📦 Received ${newItems.length} items from fetchData');
      
      if (isFirstPage) {
        _items = newItems;
        print('🔄 First page: Set _items to ${_items.length} items');
      } else {
        _items.addAll(newItems);
        print('➕ Next page: Added ${newItems.length} items, total: ${_items.length}');
      }
      
      // Kiểm tra còn dữ liệu không
      _hasMoreData = newItems.length >= 20;
      
      _error = null;
      print('📤 Notifying UI with ${_items.length} items');
      _itemsController.add(_items);
      _errorController.add(_error);
      
    } catch (e) {
      _error = e.toString();
      _errorController.add(_error);
      print('❌ Error in _loadPage: $e');
    } finally {
      _isLoading = false;
      _loadingController.add(_isLoading);
    }
  }

  /// Wrapper function để truyền forceRefresh parameter
  Future<List<T>> _fetchDataWithForceRefresh(int page, int pageSize, bool forceRefresh) async {
    // Truyền forceRefresh parameter cho fetchData
    return await fetchData(page, pageSize, forceRefresh: forceRefresh);
  }

  /// Thêm item mới vào đầu danh sách
  void addItemAtBeginning(T item) {
    _items.insert(0, item);
    _itemsController.add(_items);
  }

  /// Cập nhật item
  void updateItem(int index, T item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
      _itemsController.add(_items);
    }
  }

  /// Xóa item
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _itemsController.add(_items);
    }
  }

  /// Xóa item theo điều kiện
  void removeItemWhere(bool Function(T) test) {
    _items.removeWhere(test);
    _itemsController.add(_items);
  }

  /// Dispose resources
  void dispose() {
    _itemsController.close();
    _loadingController.close();
    _errorController.close();
  }
}
