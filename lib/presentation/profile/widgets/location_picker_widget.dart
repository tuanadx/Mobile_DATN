import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feedia/core/configs/theme/app_color.dart';
import 'package:feedia/data/services/Map/goong_service.dart';

class LocationPickerWidget extends StatefulWidget {
  final String title;
  final String? initialValue;
  final Function(String) onLocationSelected;

  const LocationPickerWidget({
    super.key,
    required this.title,
    this.initialValue,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  List<String> _filteredSearches = [];
  List<dynamic> _goongSuggestions = [];
  bool _isLoadingGoong = false;
  bool _showGoongSuggestions = false;
  static const String _storageKey = 'location_search_history';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialValue ?? '';
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search field
              _buildSearchField(),
              const SizedBox(height: 24),
              
              // Recent searches
              _buildRecentSearches(),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Nhập tên Phường hoặc Quận hoặc TP',
          hintStyle: TextStyle(
            color: AppColor.textLight,
          ),
          prefixIcon: Icon(
            Icons.location_on,
            color: AppColor.primary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: _isLoadingGoong
              ? Container(
                  padding: const EdgeInsets.all(12),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Goong Suggestions (hiển thị khi có kết quả từ API)
        if (_showGoongSuggestions && _goongSuggestions.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.search,
                color: AppColor.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Gợi ý từ Goong Map',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._goongSuggestions.map((place) => _buildGoongLocationItem(place)).toList(),
          const SizedBox(height: 24),
        ],
        
        // Recent searches (chỉ hiển thị khi không có Goong suggestions hoặc query rỗng)
        if (!_showGoongSuggestions || _searchController.text.isEmpty) ...[
          Row(
            children: [
              Text(
                'Tìm kiếm gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              if (_recentSearches.isNotEmpty)
                GestureDetector(
                  onTap: _clearSearchHistory,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Xóa lịch sử',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_filteredSearches.isEmpty && _searchController.text.isEmpty)
            Center(
              child: Text(
                'Nhập tên địa điểm để tìm kiếm',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            )
          else if (_filteredSearches.isEmpty && _searchController.text.isNotEmpty)
            Center(
              child: Text(
                'Không tìm thấy kết quả',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            )
          else
            ..._filteredSearches.map((location) => _buildLocationItem(location)).toList(),
        ],
      ],
    );
  }

  Widget _buildLocationItem(String location) {
    return GestureDetector(
      onTap: () => _selectLocation(location),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                color: AppColor.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                location,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoongLocationItem(Map<String, dynamic> place) {
    final description = place['description'] ?? '';
    final mainText = place['structured_formatting']?['main_text'] ?? '';
    final secondaryText = place['structured_formatting']?['secondary_text'] ?? '';
    
    return GestureDetector(
      onTap: () => _selectGoongLocation(place),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mainText.isNotEmpty)
                    Text(
                      mainText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                    color: Colors.black,
                      ),
                    ),
                  if (secondaryText.isNotEmpty)
                    Text(
                      secondaryText,
                      style: TextStyle(
                        fontSize: 14,
                    color: Colors.grey[600],
                      ),
                    ),
                  if (mainText.isEmpty && secondaryText.isEmpty)
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                    color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
          color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSearches = List.from(_recentSearches);
        _goongSuggestions = [];
        _showGoongSuggestions = false;
        _isLoadingGoong = false;
      } else {
        // Lọc lịch sử tìm kiếm
        _filteredSearches = _recentSearches
            .where((location) => location.toLowerCase().contains(query.toLowerCase()))
            .toList();
        
        // Gọi Goong API để lấy gợi ý
        _fetchGoongSuggestions(query);
      }
    });
  }

  // Gọi Goong Autocomplete API
  Future<void> _fetchGoongSuggestions(String input) async {
    if (input.length < 5) {
      setState(() {
        _goongSuggestions = [];
        _showGoongSuggestions = false;
        _isLoadingGoong = false;
      });
      return;
    }

    setState(() {
      _isLoadingGoong = true;
      _showGoongSuggestions = true;
    });

    try {
      final suggestions = await GoongService().getAutocompleteSuggestions(input);
      setState(() {
        _goongSuggestions = suggestions;
        _isLoadingGoong = false;
      });
    } catch (e) {
      setState(() {
        _goongSuggestions = [];
        _isLoadingGoong = false;
      });
      print('Error fetching Goong suggestions: $e');
    }
  }

  void _selectLocation(String location) {
    widget.onLocationSelected(location);
    _addToSearchHistory(location);
    Navigator.pop(context);
  }

  // Xử lý khi chọn địa điểm từ Goong suggestions
  Future<void> _selectGoongLocation(Map<String, dynamic> place) async {
    final placeId = place['place_id'] as String;
    
    try {
      final result = await GoongService().getPlaceDetail(placeId);
      
      if (result != null) {
        final address = result['formatted_address'] ?? place['description'] ?? '';
        _selectLocation(address);
      } else {
        // Fallback nếu không lấy được chi tiết
        final address = place['description'] ?? '';
        _selectLocation(address);
      }
    } catch (e) {
      print('Error getting place detail: $e');
      // Fallback nếu có lỗi
      final address = place['description'] ?? '';
      _selectLocation(address);
    }
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_storageKey) ?? [];
      setState(() {
        _recentSearches = history;
        _filteredSearches = List.from(_recentSearches);
      });
    } catch (e) {
      // Nếu có lỗi, sử dụng danh sách mặc định
      setState(() {
        _recentSearches = [
          'Q. Tây Hồ, TP. Hà Nội',
          'Ý Yên, Nam Định',
          'Q. Ba Đình, TP. Hà Nội',
          'Q. Hoàn Kiếm, TP. Hà Nội',
        ];
        _filteredSearches = List.from(_recentSearches);
      });
    }
  }

  Future<void> _addToSearchHistory(String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_storageKey) ?? [];
      
      // Loại bỏ location cũ nếu đã tồn tại
      history.remove(location);
      
      // Thêm location mới vào đầu danh sách
      history.insert(0, location);
      
      // Giới hạn số lượng lịch sử (tối đa 20 items)
      if (history.length > 20) {
        history = history.take(20).toList();
      }
      
      // Lưu vào local storage
      await prefs.setStringList(_storageKey, history);
      
      // Cập nhật UI
      setState(() {
        _recentSearches = history;
        _filteredSearches = List.from(_recentSearches);
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Error saving search history: $e');
    }
  }

  Future<void> _clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      
      setState(() {
        _recentSearches = [];
        _filteredSearches = [];
      });
      
      // Hiển thị thông báo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa lịch sử tìm kiếm'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }
} 