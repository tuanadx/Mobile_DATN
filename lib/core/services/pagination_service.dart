import 'dart:async';

class PaginationService<T> {
  final Future<List<T>> Function(int page, int pageSize) fetchData;
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
  Future<void> loadFirstPage() async {
    if (_isLoading) return;
    
    _currentPage = 1;
    _hasMoreData = true;
    _error = null;
    
    await _loadPage(_currentPage, isFirstPage: true);
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
    
    await loadFirstPage();
  }

  /// Load dữ liệu cho trang
  Future<void> _loadPage(int page, {required bool isFirstPage}) async {
    _isLoading = true;
    _loadingController.add(_isLoading);
    
    try {
      final newItems = await fetchData(page, 20); // Default page size = 20
      
      if (isFirstPage) {
        _items = newItems;
      } else {
        _items.addAll(newItems);
      }
      
      // Kiểm tra còn dữ liệu không
      _hasMoreData = newItems.length >= 20;
      
      _error = null;
      _itemsController.add(_items);
      _errorController.add(_error);
      
    } catch (e) {
      _error = e.toString();
      _errorController.add(_error);
    } finally {
      _isLoading = false;
      _loadingController.add(_isLoading);
    }
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
