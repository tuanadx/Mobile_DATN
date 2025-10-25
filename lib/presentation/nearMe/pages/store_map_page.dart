import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:savefood/data/services/Map/store_service.dart';

class StoreMapPage extends StatefulWidget {
  const StoreMapPage({super.key});

  @override
  State<StoreMapPage> createState() => _StoreMapPageState();
}

class _StoreMapPageState extends State<StoreMapPage> {
  MapLibreMapController? _mapController;
  bool _isStyleLoaded = false;
  List<Symbol> _markers = [];
  List<Map<String, dynamic>> _markerData = [];
  final StoreService _storeService = StoreService();
  bool _isModalShowing = false;

  final String _goongStyle =
      "https://tiles.goong.io/assets/goong_map_highlight.json?api_key=qvMPdcGtdYafE6X7iigYqCPNYPCydsucDIlX0QgS";

  @override
  void initState() {
    super.initState();
    _loadStoresFromAPI();
  }

  Future<void> _loadStoresFromAPI() async {
    try {
      // Lấy dữ liệu từ API
      final stores = await _storeService.getNearbyStores(
        latitude: 21.0263246, // Vị trí mặc định
        longitude: 105.8259997,
        radius: 10.0,
      );

      // Chuyển đổi dữ liệu Store thành format _markerData
      _markerData = stores.map((store) => {
        'id': store.id,
        'name': store.name,
        'lat': store.latitude,
        'lng': store.longitude,
        'description': store.address,
      }).toList();

      // Nếu đã load style thì thêm markers
      if (_isStyleLoaded) {
        await _addMarkers();
      }
    } catch (e) {
      // Không có fallback data, để trống nếu API lỗi
      _markerData = [];
    }
  }

  Future<void> _addCustomImage() async {
    if (_mapController == null || !_isStyleLoaded) return;

    final imageData = await _loadImageFromAssets('assets/pin.png');
    await _mapController!.addImage('custom-pin', imageData);
  }

  // Mở Google Maps chỉ đường đến tọa độ đã cho
  Future<void> _openGoogleMaps(double lat, double lng) async {
    final Uri googleUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở Google Maps')),
      );
    }
  }

  Future<Uint8List> _loadImageFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<void> _addMarkers() async {
    if (_mapController == null || !_isStyleLoaded) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Xóa markers cũ trước khi thêm mới
    for (var marker in _markers) {
      await _mapController!.removeSymbol(marker);
    }
    _markers.clear();

    for (var markerInfo in _markerData) {
      final marker = await _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(markerInfo['lat'], markerInfo['lng']),
          iconImage: 'custom-pin',
          iconSize: 0.1,
        ),
      );
      _markers.add(marker);
    }
    
    // Chỉ gán sự kiện click marker một lần
    if (_mapController!.onSymbolTapped.isEmpty) {
      _mapController!.onSymbolTapped.add(_onMarkerTapped);
    }
  }

  void _onMarkerTapped(Symbol symbol) {
    // Kiểm tra xem modal đã được hiển thị chưa
    if (_isModalShowing) {
      return;
    }
    
    // Map id của symbol về phần tử dữ liệu theo index tạo ra
    final index = _markers.indexWhere((m) => m.id == symbol.id);
    
    if (index < 0 || index >= _markerData.length) {
      return;
    }
    
    final data = _markerData[index];

    setState(() {
      _isModalShowing = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data['name'] ?? 'Không rõ tên',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(data['description'] ?? ''),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text('Chỉ đường bằng Google Maps'),
              onPressed: () {
                Navigator.pop(context);
                _openGoogleMaps(data['lat'] as double, data['lng'] as double);
              },
            ),
          ],
        ),
      ),
    ).then((_) {
      // Reset flag khi modal đóng
      setState(() {
        _isModalShowing = false;
      });
    });
  }

  // Để mở Google Maps bên ngoài, hãy thêm url_launcher vào pubspec.yaml.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cửa hàng gần bạn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),),),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _goongStyle,
            initialCameraPosition: const CameraPosition(
              target: LatLng(21.0263246, 105.8259997),
              zoom: 14.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
             onStyleLoadedCallback: () async {
               setState(() => _isStyleLoaded = true);
               await _addCustomImage();
               await _addMarkers();
             },
            myLocationEnabled: true,
            trackCameraPosition: true,
          ),
          if (!_isStyleLoaded)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              const LatLng(21.0263246, 105.8259997),
              14.0,
            ),
          );
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}