import '../../domain/entities/store_entity.dart';

class StoreModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String deliveryAddress;
  final List<String> tags;
  final bool isFavorite;
  final String phoneNumber;
  final String address;
  final List<String> workingHours;
  final double deliveryFee;
  final double minOrderAmount;

  const StoreModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryAddress,
    required this.tags,
    this.isFavorite = false,
    required this.phoneNumber,
    required this.address,
    required this.workingHours,
    required this.deliveryFee,
    required this.minOrderAmount,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      deliveryTime: json['deliveryTime'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      tags: List<String>.from(json['tags'] as List),
      isFavorite: json['isFavorite'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      workingHours: List<String>.from(json['workingHours'] as List),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'deliveryTime': deliveryTime,
      'deliveryAddress': deliveryAddress,
      'tags': tags,
      'isFavorite': isFavorite,
      'phoneNumber': phoneNumber,
      'address': address,
      'workingHours': workingHours,
      'deliveryFee': deliveryFee,
      'minOrderAmount': minOrderAmount,
    };
  }

  StoreEntity toEntity() {
    return StoreEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      rating: rating,
      reviewCount: reviewCount,
      deliveryTime: deliveryTime,
      deliveryAddress: deliveryAddress,
      tags: tags,
      isFavorite: isFavorite,
      phoneNumber: phoneNumber,
      address: address,
      workingHours: workingHours,
      deliveryFee: deliveryFee,
      minOrderAmount: minOrderAmount,
    );
  }
}
