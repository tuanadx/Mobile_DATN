class FoodEntity {
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

  const FoodEntity({
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
  });
}
