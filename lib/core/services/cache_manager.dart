
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, CachedData> _cache = {};

  /// Lưu dữ liệu vào cache với TTL
  void setCache(String key, dynamic data, {Duration? ttl}) {
    final expiry = DateTime.now().add(ttl ?? const Duration(minutes: 30));
    _cache[key] = CachedData(
      data: data,
      expiry: expiry,
      createdAt: DateTime.now(),
    );
  }

  /// Lấy dữ liệu từ cache nếu chưa hết hạn
  T? getCache<T>(String key) {
    final cached = _cache[key];
    if (cached == null) return null;
    
    if (DateTime.now().isAfter(cached.expiry)) {
      _cache.remove(key);
      return null;
    }
    
    return cached.data as T?;
  }

  /// Kiểm tra cache có tồn tại và chưa hết hạn không
  bool hasValidCache(String key) {
    final cached = _cache[key];
    if (cached == null) return false;
    
    if (DateTime.now().isAfter(cached.expiry)) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }

  /// Xóa cache theo key
  void removeCache(String key) {
    _cache.remove(key);
  }

  /// Xóa tất cả cache
  void clearCache() {
    _cache.clear();
  }

  /// Xóa cache hết hạn
  void cleanExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) => now.isAfter(value.expiry));
  }

  /// Lấy thông tin cache
  Map<String, dynamic> getCacheInfo() {
    return {
      'totalItems': _cache.length,
      'keys': _cache.keys.toList(),
      'expiredItems': _cache.entries
          .where((entry) => DateTime.now().isAfter(entry.value.expiry))
          .length,
    };
  }
}

class CachedData {
  final dynamic data;
  final DateTime expiry;
  final DateTime createdAt;

  CachedData({
    required this.data,
    required this.expiry,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
  
  Duration get timeUntilExpiry => expiry.difference(DateTime.now());
}
