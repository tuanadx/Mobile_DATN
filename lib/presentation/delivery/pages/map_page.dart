import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:http/http.dart' as http;
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/core/configs/goong_config.dart';
import 'package:savefood/data/services/Map/location_service.dart';

class MapPage extends StatefulWidget {
  final String currentLocation;
  final double? latitude;
  final double? longitude;

  const MapPage({
    super.key,
    required this.currentLocation,
    this.latitude,
    this.longitude,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MaplibreMapController? mapController;
  final LocationService _locationService = LocationService();
  double? _currentLat;
  double? _currentLng;
  bool _isLoading = true;
  bool _styleLoaded = false;
  String _selectedAddress = '';
  Symbol? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.currentLocation;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentLat = position.latitude;
          _currentLng = position.longitude;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentLat = widget.latitude ?? GoongConfig.defaultLatitude;
          _currentLng = widget.longitude ?? GoongConfig.defaultLongitude;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentLat = widget.latitude ?? GoongConfig.defaultLatitude;
        _currentLng = widget.longitude ?? GoongConfig.defaultLongitude;
        _isLoading = false;
      });
    }
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
          'Chọn vị trí',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColor.primary),
            onPressed: _centerOnCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
              ),
            )
          : Stack(
              children: [
                // Map
                MaplibreMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentLat!, _currentLng!),
                    zoom: 15.0,
                  ),
                  styleString: GoongConfig.mapStyleUrl,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  onStyleLoadedCallback: _onStyleLoaded,
                  // Thêm callback khi click vào map
                  onMapClick: _onMapClick,
                ),
                
                // Selected Location Info Card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColor.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedAddress.isEmpty 
                                ? 'Nhấn vào bản đồ để chọn vị trí'
                                : _selectedAddress,
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedAddress.isEmpty 
                                  ? Colors.grey 
                                  : Colors.black,
                            ),
                          ),
                        ),
                        if (_selectedAddress.isNotEmpty)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColor.primary
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Confirm Location Button
                Positioned(
                  bottom: 32,
                  left: 16,
                  right: 16,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedAddress.isEmpty 
                          ? null 
                          : () {
                              Navigator.pop(context, {
                                'address': _selectedAddress,
                                'latitude': _currentLat,
                                'longitude': _currentLng,
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xác nhận vị trí',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _onMapCreated(MaplibreMapController controller) {
    mapController = controller;
  }

  Future<void> _onStyleLoaded() async {
    _styleLoaded = true;
    await _addPlaceholderImages();
    
    if (_currentLat != null && _currentLng != null) {
      await _addMarkerAtLocation(_currentLat!, _currentLng!);
      _centerOnCurrentLocation();
    }
  }

  // Xử lý khi click vào map
  Future<void> _onMapClick(math.Point<double> point, LatLng coordinates) async {
    debugPrint('📍 Map clicked at: ${coordinates.latitude}, ${coordinates.longitude}');
    
    // Cập nhật tọa độ hiện tại
    setState(() {
      _currentLat = coordinates.latitude;
      _currentLng = coordinates.longitude;
      _selectedAddress = 'Đang tải địa chỉ...';
    });

    // Xóa marker cũ và thêm marker mới
    await _addMarkerAtLocation(coordinates.latitude, coordinates.longitude);

    // Lấy địa chỉ từ tọa độ (Reverse Geocoding)
    await _getAddressFromCoordinates(coordinates.latitude, coordinates.longitude);
  }

  // Thêm marker tại vị trí được chọn
  Future<void> _addMarkerAtLocation(double lat, double lng) async {
    if (mapController == null || !_styleLoaded) return;

    try {
      // Xóa marker cũ nếu có
      if (_selectedMarker != null) {
        await mapController!.removeSymbol(_selectedMarker!);
      }

      // Thêm marker mới
      _selectedMarker = await mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(lat, lng),
          iconImage: 'marker-15',
          iconSize: 1.5,
        ),
      );

      debugPrint('✅ Marker added at: $lat, $lng');
    } catch (e) {
      debugPrint('❌ Error adding marker: $e');
    }
  }

  // Lấy địa chỉ từ tọa độ sử dụng Goong Geocoding API
  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      // Goong Geocoding API: https://rsapi.goong.io/Geocode?latlng={lat},{lng}&api_key={api_key}
      final url = Uri.parse(
        'https://rsapi.goong.io/Geocode?latlng=$lat,$lng&api_key=${GoongConfig.apiKey}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['results'] != null && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'] ?? 'Không tìm thấy địa chỉ';
          
          setState(() {
            _selectedAddress = address;
          });
          
          debugPrint('✅ Address found: $address');
        } else {
          setState(() {
            _selectedAddress = 'Không tìm thấy địa chỉ';
          });
        }
      } else {
        debugPrint('❌ Geocoding API error: ${response.statusCode}');
        setState(() {
          _selectedAddress = 'Lỗi khi tải địa chỉ';
        });
      }
    } catch (e) {
      debugPrint('❌ Error getting address: $e');
      setState(() {
        _selectedAddress = 'Lỗi khi tải địa chỉ';
      });
    }
  }

  Future<void> _addPlaceholderImages() async {
    if (mapController == null) return;
    
    final Uint8List bytes = _createTransparentImage();
    
    try {
      await mapController!.addImage('mountain-15', bytes);
      await mapController!.addImage('square', bytes);
      
      // Tạo marker icon đẹp hơn
      final markerBytes = await _createCustomMarkerIcon();
      await mapController!.addImage('marker-15', markerBytes);
      
      debugPrint('✅ Icons added successfully');
    } catch (e) {
      debugPrint('❌ Error adding images: $e');
    }
  }

  Uint8List _createTransparentImage() {
    return base64.decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAuMBgTFWkXQAAAAASUVORK5CYII='
    );
  }

  // Tạo custom marker icon (màu xanh lá cây)
  Future<Uint8List> _createCustomMarkerIcon() async {
    // Base64 của một marker icon đơn giản (30x40 px)
    const markerSvg = '''
      <svg width="30" height="40" xmlns="http://www.w3.org/2000/svg">
        <path d="M15 0C8.373 0 3 5.373 3 12c0 9 12 28 12 28s12-19 12-28c0-6.627-5.373-12-12-12z" 
              fill="#A4C3A2" stroke="#fff" stroke-width="2"/>
        <circle cx="15" cy="12" r="5" fill="#fff"/>
      </svg>
    ''';
    
    // Encode SVG to base64
    final bytes = utf8.encode(markerSvg);
    return Uint8List.fromList(bytes);
  }

  void _centerOnCurrentLocation() {
    if (mapController != null && _currentLat != null && _currentLng != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLat!, _currentLng!),
          16.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
