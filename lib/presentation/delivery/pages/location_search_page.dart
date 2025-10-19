import 'package:flutter/material.dart';
import 'package:feedia/core/configs/theme/app_color.dart';
import 'package:feedia/data/services/Map/goong_service.dart';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _goongSuggestions = [];
  bool _isLoadingGoong = false;

  @override
  void initState() {
    super.initState();
    // Focus vào search field khi mở trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tìm vị trí',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nhập tên địa điểm để tìm kiếm',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            ),
          ),

          // Search Results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nhập tên địa điểm để tìm kiếm',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingGoong) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
        ),
      );
    }

    if (_goongSuggestions.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _goongSuggestions.length,
      itemBuilder: (context, index) {
        final place = _goongSuggestions[index];
        return _buildGoongLocationItem(place);
      },
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
                color: AppColor.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: AppColor.primary,
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
                      style: const TextStyle(
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
                      style: const TextStyle(
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
        _goongSuggestions = [];
        _isLoadingGoong = false;
      } else {
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
        _isLoadingGoong = false;
      });
      return;
    }

    setState(() {
      _isLoadingGoong = true;
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

  void _selectLocation(String location) {
    // Trả về địa chỉ đã chọn và đóng trang
    Navigator.pop(context, location);
  }
}
