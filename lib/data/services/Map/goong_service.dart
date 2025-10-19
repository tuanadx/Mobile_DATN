import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:feedia/core/configs/goong_config.dart';

class GoongService {
  static final GoongService _instance = GoongService._internal();
  factory GoongService() => _instance;
  GoongService._internal();

  // Gọi Autocomplete API
  Future<List<dynamic>> getAutocompleteSuggestions(String input, {double? lat, double? lng}) async {
    try {
      // Sử dụng vị trí mặc định nếu lat/lng không được cung cấp
      final location = (lat != null && lng != null)
          ? '$lat%2C%20$lng'
          : '${GoongConfig.defaultLatitude}%2C%20${GoongConfig.defaultLongitude}';

      final url = Uri.parse(
        '${GoongConfig.baseUrl}${GoongConfig.autocompleteEndpoint}?location=$location&input=${Uri.encodeComponent(input)}&api_key=${GoongConfig.apiKey}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse != null && jsonResponse['predictions'] != null) {
          return List<dynamic>.from(jsonResponse['predictions']);
        } else {
          // Trả về danh sách rỗng nếu không có predictions
          return [];
        }
      } else {
        print('Failed to load autocomplete suggestions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching autocomplete data: $e');
      return [];
    }
  }

  // Lấy chi tiết địa điểm từ place_id
  Future<Map<String, dynamic>?> getPlaceDetail(String placeId) async {
    try {
      final url = Uri.parse(
        '${GoongConfig.baseUrl}${GoongConfig.placeDetailEndpoint}?place_id=${Uri.encodeComponent(placeId)}&api_key=${GoongConfig.apiKey}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse != null && jsonResponse['result'] != null) {
          return Map<String, dynamic>.from(jsonResponse['result']);
        } else {
          // Trả về null nếu không có result
          return null;
        }
      } else {
        print('Failed to load place detail: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting place detail: $e');
      return null;
    }
  }
}
