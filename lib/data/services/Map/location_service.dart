import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:feedia/core/configs/goong_config.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Kiểm tra quyền truy cập vị trí
  Future<bool> checkLocationPermission() async {
    print('🔍 LocationService: Checking location permission...');
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📍 LocationService: Location service enabled: $serviceEnabled');
    
    if (!serviceEnabled) {
      print('❌ LocationService: Location service is disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print('🔐 LocationService: Current permission: $permission');
    
    if (permission == LocationPermission.denied) {
      print('⚠️ LocationService: Permission denied, requesting...');
      permission = await Geolocator.requestPermission();
      print('🔐 LocationService: Permission after request: $permission');
      
      if (permission == LocationPermission.denied) {
        print('❌ LocationService: Permission still denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ LocationService: Permission denied forever');
      return false;
    }

    print('✅ LocationService: Permission granted');
    return true;
  }

  /// Lấy vị trí hiện tại
  Future<Position?> getCurrentPosition() async {
    try {
      print('🌍 LocationService: Getting current position...');
      bool hasPermission = await checkLocationPermission();
      
      if (!hasPermission) {
        print('❌ LocationService: No permission to get location');
        return null;
      }

      print('📍 LocationService: Requesting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      print('✅ LocationService: Got position - Lat: ${position.latitude}, Lng: ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ LocationService: Error getting current position: $e');
      return null;
    }
  }

  /// Chuyển đổi tọa độ thành địa chỉ bằng Goong API
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      print('🗺️ LocationService: Getting address from Goong API for lat: $lat, lng: $lng');
      
      final url = Uri.parse(
        'https://rsapi.goong.io/v2/geocode?latlng=$lat,$lng&limit=5&api_key=${GoongConfig.apiKey}&has_deprecated_administrative_unit=false'
      );
      
      print('🌐 LocationService: Calling Goong API: $url');
      
      final response = await http.get(url);
      print('📡 LocationService: Goong API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('📄 LocationService: Goong API response: $jsonResponse');
        
        if (jsonResponse != null && jsonResponse['results'] != null && jsonResponse['results'].isNotEmpty) {
          final result = jsonResponse['results'][0];
          final formattedAddress = result['formatted_address'] ?? '';
          print('✅ LocationService: Got address from Goong: $formattedAddress');
          return formattedAddress;
        } else {
          print('⚠️ LocationService: No results from Goong API');
          return null;
        }
      } else {
        print('❌ LocationService: Goong API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ LocationService: Error getting address from Goong API: $e');
      return null;
    }
  }

  /// Lấy vị trí hiện tại và chuyển thành địa chỉ bằng Goong API
  Future<String?> getCurrentAddress() async {
    try {
      print('🚀 LocationService: Getting current address...');
      Position? position = await getCurrentPosition();
      if (position == null) {
        print('❌ LocationService: Could not get current position');
        return null;
      }

      String? address = await getAddressFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      if (address != null) {
        print('✅ LocationService: Successfully got current address: $address');
      } else {
        print('❌ LocationService: Could not get address from coordinates');
      }
      
      return address;
    } catch (e) {
      print('❌ LocationService: Error getting current address: $e');
      return null;
    }
  }

  /// Tính khoảng cách giữa hai điểm (km)
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }
}
