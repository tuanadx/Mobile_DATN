class StoreInfo {
  final String id;
  final String name;
  final String avatar;

  const StoreInfo({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

class FoodModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final String distance;
  final String deliveryTime;
  final List<String> tags;
  final double? discountPercentage;
  final double price;
  final String category;
  final String idStore; // Thêm idStore để liên kết với cửa hàng
  final DateTime? expirationDate; // Thêm trường ngày hết hạn
  final StoreInfo? store; // Thông tin cửa hàng được embed

  const FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    required this.deliveryTime,
    required this.tags,
    this.discountPercentage,
    required this.price,
    required this.category,
    required this.idStore,
    this.expirationDate,
    this.store,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: (json['id'] ?? json['ID']).toString(),
      name: (json['name'] ?? json['Name']).toString(),
      description: (json['description'] ?? json['Description']).toString(),
      imageUrl: (json['imageUrl'] ?? json['imageurl'] ?? json['imageURL'] ?? '').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] ?? '').toString(),
      deliveryTime: (json['deliveryTime'] ?? json['time'] ?? '').toString(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: (json['category'] ?? '').toString(),
      idStore: (json['idStore'] ?? json['idstore'] ?? json['store']?['id'] ?? '').toString(),
      expirationDate: json['expirationDate'] != null && (json['expirationDate'] as String).isNotEmpty
          ? DateTime.tryParse(json['expirationDate'] as String)
          : null,
      store: json['store'] != null ? StoreInfo.fromJson(json['store'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'distance': distance,
      'deliveryTime': deliveryTime,
      'tags': tags,
      'discountPercentage': discountPercentage,
      'price': price,
      'category': category,
      'idStore': idStore,
      'expirationDate': expirationDate?.toIso8601String(),
      'store': store?.toJson(),
    };
  }
}
