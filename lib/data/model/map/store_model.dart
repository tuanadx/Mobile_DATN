class Store {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? image;
  final double? distance;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.image,
    this.distance,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    print('🏪 Store.fromJson: Parsing store data: $json');
    
    try {
      final store = Store(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        latitude: double.parse(json['latitude'].toString()),
        longitude: double.parse(json['longitude'].toString()),
        phoneNumber: json['phone_number'],
        image: json['image'],
        distance: json['distance'] != null 
            ? double.parse(json['distance'].toString()) 
            : null,
      );
      
      print('✅ Store.fromJson: Tạo store thành công - ${store.name} tại (${store.latitude}, ${store.longitude})');
      return store;
    } catch (e) {
      print('❌ Store.fromJson: Lỗi khi parse store: $e');
      print('❌ Store.fromJson: JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'image': image,
      'distance': distance,
    };
  }

  // Copy with method
  Store copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? image,
    double? distance,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      image: image ?? this.image,
      distance: distance ?? this.distance,
    );
  }
}